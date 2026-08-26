using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;
using SkiPass.Application.DTOs.Common;
using SkiPass.Application.DTOs.Tickets;
using SkiPass.Application.Exceptions;
using SkiPass.Application.Services.Interfaces;
using SkiPass.Domain.Entities;
using SkiPass.Infrastructure.Data;

namespace SkiPass.Infrastructure.Services;

public class TicketTypeService
    : CrudServiceBase<TicketType, TicketTypeDto, TicketTypeUpsertDto, TicketTypeSearchDto>, ITicketTypeService
{
    public TicketTypeService(ApplicationDbContext context, ILogger<TicketTypeService> logger)
        : base(context, logger)
    {
    }

    protected override string EntityName => "Tip ski pass karte";

    protected override IQueryable<TicketType> BaseQuery() =>
        Context.TicketTypes
            .Include(t => t.SkiResort)
            .Include(t => t.Tickets);

    public async Task<List<LookupDto>> GetLookupAsync(CancellationToken cancellationToken = default) =>
        await Context.TicketTypes
            .Where(t => !t.IsDeleted && t.IsActive)
            .OrderBy(t => t.Name)
            .Select(t => new LookupDto { Id = t.Id, Name = t.Name })
            .AsNoTracking()
            .ToListAsync(cancellationToken);

    protected override IQueryable<TicketType> ApplyFilters(IQueryable<TicketType> query, TicketTypeSearchDto request)
    {
        if (!string.IsNullOrWhiteSpace(request.Query))
        {
            var term = request.Query.Trim();
            query = query.Where(t => t.Name.Contains(term) || (t.Description != null && t.Description.Contains(term)));
        }

        if (request.SkiResortId.HasValue)
        {
            query = query.Where(t => t.SkiResortId == request.SkiResortId.Value);
        }

        if (request.IsActive.HasValue)
        {
            query = query.Where(t => t.IsActive == request.IsActive.Value);
        }

        if (request.MinPricePerDay.HasValue)
        {
            query = query.Where(t => t.PricePerDay >= request.MinPricePerDay.Value);
        }

        if (request.MaxPricePerDay.HasValue)
        {
            query = query.Where(t => t.PricePerDay <= request.MaxPricePerDay.Value);
        }

        return query;
    }

    protected override IQueryable<TicketType> ApplyDefaultSort(IQueryable<TicketType> query) =>
        query.OrderBy(t => t.PricePerDay).ThenBy(t => t.Name);

    protected override IQueryable<TicketType>? ApplySort(IQueryable<TicketType> query, string sortBy, bool descending) =>
        sortBy.ToLowerInvariant() switch
        {
            "name" => descending ? query.OrderByDescending(t => t.Name) : query.OrderBy(t => t.Name),
            "price" => descending ? query.OrderByDescending(t => t.PricePerDay) : query.OrderBy(t => t.PricePerDay),
            _ => null
        };

    protected override TicketTypeDto MapToDto(TicketType e) => new()
    {
        Id = e.Id,
        Name = e.Name,
        Description = e.Description,
        PricePerDay = e.PricePerDay,
        MaxDays = e.MaxDays,
        DiscountPercentage = e.DiscountPercentage,
        MinAge = e.MinAge,
        MaxAge = e.MaxAge,
        IsActive = e.IsActive,
        SkiResortId = e.SkiResortId,
        SkiResortName = e.SkiResort.Name,
        SoldTicketCount = e.Tickets.Count(t => !t.IsDeleted)
    };

    protected override async Task MapAsync(TicketType entity, TicketTypeUpsertDto dto, CancellationToken cancellationToken)
    {
        var resortExists = await Context.SkiResorts.AnyAsync(r => r.Id == dto.SkiResortId && !r.IsDeleted, cancellationToken);
        if (!resortExists)
        {
            throw new ValidationException(nameof(dto.SkiResortId), "Odabrano skijaliste ne postoji.");
        }

        var duplicate = await Context.TicketTypes.AnyAsync(
            t => t.Id != entity.Id && !t.IsDeleted && t.SkiResortId == dto.SkiResortId && t.Name == dto.Name,
            cancellationToken);
        if (duplicate)
        {
            throw new ValidationException(nameof(dto.Name), "Tip karte sa ovim nazivom vec postoji na odabranom skijalistu.");
        }

        entity.Name = dto.Name.Trim();
        entity.Description = dto.Description?.Trim();
        entity.PricePerDay = dto.PricePerDay;
        entity.MaxDays = dto.MaxDays;
        entity.DiscountPercentage = dto.DiscountPercentage;
        entity.MinAge = dto.MinAge;
        entity.MaxAge = dto.MaxAge;
        entity.IsActive = dto.IsActive;
        entity.SkiResortId = dto.SkiResortId;
    }

    protected override async Task EnsureCanDeleteAsync(TicketType entity, CancellationToken cancellationToken)
    {
        var ticketCount = await Context.SkiPassTickets
            .CountAsync(t => t.TicketTypeId == entity.Id && !t.IsDeleted, cancellationToken);

        EnsureNotReferenced(EntityName, "Prodane ski pass karte", ticketCount);
    }
}
