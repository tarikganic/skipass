using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;
using SkiPass.Application.DTOs.Common;
using SkiPass.Application.DTOs.Resorts;
using SkiPass.Application.Exceptions;
using SkiPass.Application.Services.Interfaces;
using SkiPass.Domain.Entities;
using SkiPass.Infrastructure.Data;

namespace SkiPass.Infrastructure.Services;

public class SkiResortService
    : CrudServiceBase<SkiResort, SkiResortDto, SkiResortUpsertDto, SkiResortSearchDto>, ISkiResortService
{
    public SkiResortService(ApplicationDbContext context, ILogger<SkiResortService> logger)
        : base(context, logger)
    {
    }

    protected override string EntityName => "Skijaliste";

    protected override IQueryable<SkiResort> BaseQuery() =>
        Context.SkiResorts
            .Include(r => r.City)
            .Include(r => r.Trails)
            .Include(r => r.SkiLifts);

    public async Task<List<LookupDto>> GetLookupAsync(CancellationToken cancellationToken = default) =>
        await Context.SkiResorts
            .Where(r => !r.IsDeleted && r.IsActive)
            .OrderBy(r => r.Name)
            .Select(r => new LookupDto { Id = r.Id, Name = r.Name })
            .AsNoTracking()
            .ToListAsync(cancellationToken);

    protected override IQueryable<SkiResort> ApplyFilters(IQueryable<SkiResort> query, SkiResortSearchDto request)
    {
        if (!string.IsNullOrWhiteSpace(request.Query))
        {
            var term = request.Query.Trim();
            query = query.Where(r => r.Name.Contains(term) || r.Description.Contains(term));
        }

        if (request.CityId.HasValue)
        {
            query = query.Where(r => r.CityId == request.CityId.Value);
        }

        if (request.IsActive.HasValue)
        {
            query = query.Where(r => r.IsActive == request.IsActive.Value);
        }

        return query;
    }

    protected override IQueryable<SkiResort> ApplyDefaultSort(IQueryable<SkiResort> query) => query.OrderBy(r => r.Name);

    protected override IQueryable<SkiResort>? ApplySort(IQueryable<SkiResort> query, string sortBy, bool descending) =>
        sortBy.ToLowerInvariant() switch
        {
            "name" => descending ? query.OrderByDescending(r => r.Name) : query.OrderBy(r => r.Name),
            "city" => descending ? query.OrderByDescending(r => r.City.Name) : query.OrderBy(r => r.City.Name),
            "peakaltitude" => descending
                ? query.OrderByDescending(r => r.PeakAltitudeMeters)
                : query.OrderBy(r => r.PeakAltitudeMeters),
            _ => null
        };

    protected override SkiResortDto MapToDto(SkiResort e) => new()
    {
        Id = e.Id,
        Name = e.Name,
        Description = e.Description,
        LogoUrl = e.LogoUrl,
        ContactEmail = e.ContactEmail,
        ContactPhone = e.ContactPhone,
        Latitude = e.Latitude,
        Longitude = e.Longitude,
        BaseAltitudeMeters = e.BaseAltitudeMeters,
        PeakAltitudeMeters = e.PeakAltitudeMeters,
        OpeningTime = e.OpeningTime,
        ClosingTime = e.ClosingTime,
        IsActive = e.IsActive,
        CityId = e.CityId,
        CityName = e.City.Name,
        TrailCount = e.Trails.Count(t => !t.IsDeleted),
        OpenTrailCount = e.Trails.Count(t => !t.IsDeleted && t.IsOpen),
        SkiLiftCount = e.SkiLifts.Count(l => !l.IsDeleted),
        OperationalLiftCount = e.SkiLifts.Count(l => !l.IsDeleted && l.IsOperational)
    };

    protected override async Task MapAsync(SkiResort entity, SkiResortUpsertDto dto, CancellationToken cancellationToken)
    {
        var cityExists = await Context.Cities.AnyAsync(c => c.Id == dto.CityId && !c.IsDeleted, cancellationToken);
        if (!cityExists)
        {
            throw new ValidationException(nameof(dto.CityId), "Odabrani grad ne postoji.");
        }

        var duplicate = await Context.SkiResorts
            .AnyAsync(r => r.Id != entity.Id && !r.IsDeleted && r.Name == dto.Name, cancellationToken);
        if (duplicate)
        {
            throw new ValidationException(nameof(dto.Name), "Skijaliste sa ovim nazivom vec postoji.");
        }

        entity.Name = dto.Name.Trim();
        entity.Description = dto.Description.Trim();
        entity.LogoUrl = dto.LogoUrl?.Trim();
        entity.ContactEmail = dto.ContactEmail?.Trim();
        entity.ContactPhone = dto.ContactPhone?.Trim();
        entity.Latitude = dto.Latitude;
        entity.Longitude = dto.Longitude;
        entity.BaseAltitudeMeters = dto.BaseAltitudeMeters;
        entity.PeakAltitudeMeters = dto.PeakAltitudeMeters;
        entity.OpeningTime = dto.OpeningTime;
        entity.ClosingTime = dto.ClosingTime;
        entity.CityId = dto.CityId;
        entity.IsActive = dto.IsActive;
    }

    protected override async Task EnsureCanDeleteAsync(SkiResort entity, CancellationToken cancellationToken)
    {
        var trailCount = await Context.Trails.CountAsync(t => t.SkiResortId == entity.Id && !t.IsDeleted, cancellationToken);
        EnsureNotReferenced(EntityName, "Ski staze", trailCount);

        var liftCount = await Context.SkiLifts.CountAsync(l => l.SkiResortId == entity.Id && !l.IsDeleted, cancellationToken);
        EnsureNotReferenced(EntityName, "Ski liftovi", liftCount);

        var ticketTypeCount = await Context.TicketTypes.CountAsync(t => t.SkiResortId == entity.Id && !t.IsDeleted, cancellationToken);
        EnsureNotReferenced(EntityName, "Tipovi karata", ticketTypeCount);

        var benefitCount = await Context.Benefits.CountAsync(b => b.SkiResortId == entity.Id && !b.IsDeleted, cancellationToken);
        EnsureNotReferenced(EntityName, "Pogodnosti", benefitCount);
    }
}
