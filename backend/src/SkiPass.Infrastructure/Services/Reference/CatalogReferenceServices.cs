using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Caching.Memory;
using Microsoft.Extensions.Logging;
using SkiPass.Application.DTOs.Common;
using SkiPass.Application.DTOs.Reference;
using SkiPass.Application.Exceptions;
using SkiPass.Application.Services.Interfaces;
using SkiPass.Domain.Entities;
using SkiPass.Infrastructure.Data;

namespace SkiPass.Infrastructure.Services.Reference;

public class TrailDifficultyService
    : ReferenceCrudServiceBase<TrailDifficulty, TrailDifficultyDto, TrailDifficultyUpsertDto, TrailDifficultySearchDto>,
      ITrailDifficultyService
{
    public TrailDifficultyService(ApplicationDbContext context, IMemoryCache cache, ILogger<TrailDifficultyService> logger)
        : base(context, cache, logger)
    {
    }

    protected override string EntityName => "Tezina staze";

    protected override IQueryable<TrailDifficulty> BaseQuery() => Context.TrailDifficulties.Include(d => d.Trails);

    protected override IQueryable<LookupDto> LookupQuery() =>
        Context.TrailDifficulties
            .Where(d => !d.IsDeleted)
            .OrderBy(d => d.SortOrder)
            .Select(d => new LookupDto { Id = d.Id, Name = d.Name });

    protected override IQueryable<TrailDifficulty> ApplyFilters(IQueryable<TrailDifficulty> query, TrailDifficultySearchDto request)
    {
        if (!string.IsNullOrWhiteSpace(request.Query))
        {
            var term = request.Query.Trim();
            query = query.Where(d => d.Name.Contains(term));
        }

        return query;
    }

    protected override IQueryable<TrailDifficulty> ApplyDefaultSort(IQueryable<TrailDifficulty> query) =>
        query.OrderBy(d => d.SortOrder);

    protected override IQueryable<TrailDifficulty>? ApplySort(IQueryable<TrailDifficulty> query, string sortBy, bool descending) =>
        sortBy.ToLowerInvariant() switch
        {
            "name" => descending ? query.OrderByDescending(d => d.Name) : query.OrderBy(d => d.Name),
            "sortorder" => descending ? query.OrderByDescending(d => d.SortOrder) : query.OrderBy(d => d.SortOrder),
            _ => null
        };

    protected override TrailDifficultyDto MapToDto(TrailDifficulty e) => new()
    {
        Id = e.Id,
        Name = e.Name,
        Description = e.Description,
        ColorHex = e.ColorHex,
        SortOrder = e.SortOrder,
        TrailCount = e.Trails.Count(t => !t.IsDeleted)
    };

    protected override async Task MapAsync(TrailDifficulty entity, TrailDifficultyUpsertDto dto, CancellationToken cancellationToken)
    {
        var duplicate = await Context.TrailDifficulties
            .AnyAsync(d => d.Id != entity.Id && !d.IsDeleted && d.Name == dto.Name, cancellationToken);
        if (duplicate)
        {
            throw new ValidationException(nameof(dto.Name), "Tezina staze sa ovim nazivom vec postoji.");
        }

        entity.Name = dto.Name.Trim();
        entity.Description = dto.Description?.Trim();
        entity.ColorHex = dto.ColorHex.Trim().ToUpperInvariant();
        entity.SortOrder = dto.SortOrder;
    }

    protected override async Task EnsureCanDeleteAsync(TrailDifficulty entity, CancellationToken cancellationToken)
    {
        var trailCount = await Context.Trails.CountAsync(t => t.TrailDifficultyId == entity.Id && !t.IsDeleted, cancellationToken);
        EnsureNotReferenced(EntityName, "Ski staze", trailCount);
    }
}

public class LiftTypeService
    : ReferenceCrudServiceBase<LiftType, LiftTypeDto, LiftTypeUpsertDto, LiftTypeSearchDto>, ILiftTypeService
{
    public LiftTypeService(ApplicationDbContext context, IMemoryCache cache, ILogger<LiftTypeService> logger)
        : base(context, cache, logger)
    {
    }

    protected override string EntityName => "Tip ski lifta";

    protected override IQueryable<LiftType> BaseQuery() => Context.LiftTypes.Include(t => t.SkiLifts);

    protected override IQueryable<LookupDto> LookupQuery() =>
        Context.LiftTypes
            .Where(t => !t.IsDeleted)
            .OrderBy(t => t.Name)
            .Select(t => new LookupDto { Id = t.Id, Name = t.Name });

    protected override IQueryable<LiftType> ApplyFilters(IQueryable<LiftType> query, LiftTypeSearchDto request)
    {
        if (!string.IsNullOrWhiteSpace(request.Query))
        {
            var term = request.Query.Trim();
            query = query.Where(t => t.Name.Contains(term));
        }

        return query;
    }

    protected override IQueryable<LiftType> ApplyDefaultSort(IQueryable<LiftType> query) => query.OrderBy(t => t.Name);

    protected override LiftTypeDto MapToDto(LiftType e) => new()
    {
        Id = e.Id,
        Name = e.Name,
        Description = e.Description,
        SkiLiftCount = e.SkiLifts.Count(l => !l.IsDeleted)
    };

    protected override async Task MapAsync(LiftType entity, LiftTypeUpsertDto dto, CancellationToken cancellationToken)
    {
        var duplicate = await Context.LiftTypes
            .AnyAsync(t => t.Id != entity.Id && !t.IsDeleted && t.Name == dto.Name, cancellationToken);
        if (duplicate)
        {
            throw new ValidationException(nameof(dto.Name), "Tip lifta sa ovim nazivom vec postoji.");
        }

        entity.Name = dto.Name.Trim();
        entity.Description = dto.Description?.Trim();
    }

    protected override async Task EnsureCanDeleteAsync(LiftType entity, CancellationToken cancellationToken)
    {
        var liftCount = await Context.SkiLifts.CountAsync(l => l.LiftTypeId == entity.Id && !l.IsDeleted, cancellationToken);
        EnsureNotReferenced(EntityName, "Ski liftovi", liftCount);
    }
}

public class IncidentTypeService
    : ReferenceCrudServiceBase<IncidentType, IncidentTypeDto, IncidentTypeUpsertDto, IncidentTypeSearchDto>,
      IIncidentTypeService
{
    public IncidentTypeService(ApplicationDbContext context, IMemoryCache cache, ILogger<IncidentTypeService> logger)
        : base(context, cache, logger)
    {
    }

    protected override string EntityName => "Tip incidenta";

    protected override IQueryable<IncidentType> BaseQuery() => Context.IncidentTypes.Include(t => t.Incidents);

    protected override IQueryable<LookupDto> LookupQuery() =>
        Context.IncidentTypes
            .Where(t => !t.IsDeleted)
            .OrderBy(t => t.Name)
            .Select(t => new LookupDto { Id = t.Id, Name = t.Name });

    protected override IQueryable<IncidentType> ApplyFilters(IQueryable<IncidentType> query, IncidentTypeSearchDto request)
    {
        if (!string.IsNullOrWhiteSpace(request.Query))
        {
            var term = request.Query.Trim();
            query = query.Where(t => t.Name.Contains(term));
        }

        if (request.IsUrgentByDefault.HasValue)
        {
            query = query.Where(t => t.IsUrgentByDefault == request.IsUrgentByDefault.Value);
        }

        return query;
    }

    protected override IQueryable<IncidentType> ApplyDefaultSort(IQueryable<IncidentType> query) => query.OrderBy(t => t.Name);

    protected override IncidentTypeDto MapToDto(IncidentType e) => new()
    {
        Id = e.Id,
        Name = e.Name,
        Description = e.Description,
        IsUrgentByDefault = e.IsUrgentByDefault,
        IncidentCount = e.Incidents.Count(i => !i.IsDeleted)
    };

    protected override async Task MapAsync(IncidentType entity, IncidentTypeUpsertDto dto, CancellationToken cancellationToken)
    {
        var duplicate = await Context.IncidentTypes
            .AnyAsync(t => t.Id != entity.Id && !t.IsDeleted && t.Name == dto.Name, cancellationToken);
        if (duplicate)
        {
            throw new ValidationException(nameof(dto.Name), "Tip incidenta sa ovim nazivom vec postoji.");
        }

        entity.Name = dto.Name.Trim();
        entity.Description = dto.Description?.Trim();
        entity.IsUrgentByDefault = dto.IsUrgentByDefault;
    }

    protected override async Task EnsureCanDeleteAsync(IncidentType entity, CancellationToken cancellationToken)
    {
        var incidentCount = await Context.Incidents.CountAsync(i => i.IncidentTypeId == entity.Id && !i.IsDeleted, cancellationToken);
        EnsureNotReferenced(EntityName, "Incidenti", incidentCount);
    }
}
