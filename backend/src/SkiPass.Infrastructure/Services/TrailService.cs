using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;
using SkiPass.Application.DTOs.Common;
using SkiPass.Application.DTOs.Trails;
using SkiPass.Application.Exceptions;
using SkiPass.Application.Services.Interfaces;
using SkiPass.Domain.Entities;
using SkiPass.Domain.Enums;
using SkiPass.Infrastructure.Data;

namespace SkiPass.Infrastructure.Services;

public class TrailService
    : CrudServiceBase<Trail, TrailDto, TrailUpsertDto, TrailSearchDto>, ITrailService
{
    public TrailService(ApplicationDbContext context, ILogger<TrailService> logger)
        : base(context, logger)
    {
    }

    protected override string EntityName => "Ski staza";

    protected override IQueryable<Trail> BaseQuery() =>
        Context.Trails
            .Include(t => t.SkiResort)
            .Include(t => t.TrailDifficulty)
            .Include(t => t.ConditionLogs)
            .Include(t => t.Reviews)
            .Include(t => t.Incidents);

    public async Task<List<LookupDto>> GetLookupAsync(CancellationToken cancellationToken = default) =>
        await Context.Trails
            .Where(t => !t.IsDeleted)
            .OrderBy(t => t.Name)
            .Select(t => new LookupDto { Id = t.Id, Name = t.Name })
            .AsNoTracking()
            .ToListAsync(cancellationToken);

    protected override IQueryable<Trail> ApplyFilters(IQueryable<Trail> query, TrailSearchDto request)
    {
        if (!string.IsNullOrWhiteSpace(request.Query))
        {
            var term = request.Query.Trim();
            query = query.Where(t =>
                t.Name.Contains(term) ||
                t.Code.Contains(term) ||
                (t.Description != null && t.Description.Contains(term)));
        }

        if (request.SkiResortId.HasValue)
        {
            query = query.Where(t => t.SkiResortId == request.SkiResortId.Value);
        }

        if (request.TrailDifficultyId.HasValue)
        {
            query = query.Where(t => t.TrailDifficultyId == request.TrailDifficultyId.Value);
        }

        if (request.IsOpen.HasValue)
        {
            query = query.Where(t => t.IsOpen == request.IsOpen.Value);
        }

        if (request.HasNightSkiing.HasValue)
        {
            query = query.Where(t => t.HasNightSkiing == request.HasNightSkiing.Value);
        }

        if (request.MinLengthMeters.HasValue)
        {
            query = query.Where(t => t.LengthMeters >= request.MinLengthMeters.Value);
        }

        if (request.MaxLengthMeters.HasValue)
        {
            query = query.Where(t => t.LengthMeters <= request.MaxLengthMeters.Value);
        }

        return query;
    }

    protected override IQueryable<Trail> ApplyDefaultSort(IQueryable<Trail> query) =>
        query.OrderBy(t => t.TrailDifficulty.SortOrder).ThenBy(t => t.Name);

    protected override IQueryable<Trail>? ApplySort(IQueryable<Trail> query, string sortBy, bool descending) =>
        sortBy.ToLowerInvariant() switch
        {
            "name" => descending ? query.OrderByDescending(t => t.Name) : query.OrderBy(t => t.Name),
            "length" => descending ? query.OrderByDescending(t => t.LengthMeters) : query.OrderBy(t => t.LengthMeters),
            "difficulty" => descending
                ? query.OrderByDescending(t => t.TrailDifficulty.SortOrder)
                : query.OrderBy(t => t.TrailDifficulty.SortOrder),
            _ => null
        };

    protected override TrailDto MapToDto(Trail e)
    {
        var latestCondition = e.ConditionLogs
            .Where(c => !c.IsDeleted)
            .OrderByDescending(c => c.RecordedAt)
            .FirstOrDefault();

        var reviews = e.Reviews.Where(r => !r.IsDeleted).ToList();

        return new TrailDto
        {
            Id = e.Id,
            Name = e.Name,
            Code = e.Code,
            Description = e.Description,
            ImageUrl = e.ImageUrl,
            LengthMeters = e.LengthMeters,
            VerticalDropMeters = e.VerticalDropMeters,
            IsOpen = e.IsOpen,
            HasNightSkiing = e.HasNightSkiing,
            HasSnowmaking = e.HasSnowmaking,
            EstimatedCrowdLevel = e.EstimatedCrowdLevel.ToString(),
            SkiResortId = e.SkiResortId,
            SkiResortName = e.SkiResort.Name,
            TrailDifficultyId = e.TrailDifficultyId,
            TrailDifficultyName = e.TrailDifficulty.Name,
            TrailDifficultyColorHex = e.TrailDifficulty.ColorHex,
            LatestSnowDepthCm = latestCondition?.SnowDepthCm,
            LatestConditionNote = latestCondition?.ConditionNote,
            LatestConditionRecordedAt = latestCondition?.RecordedAt,
            AverageRating = reviews.Count == 0 ? 0 : Math.Round(reviews.Average(r => r.Rating), 2),
            ReviewCount = reviews.Count,
            OpenIncidentCount = e.Incidents.Count(i =>
                !i.IsDeleted && (i.Status == IncidentStatus.Reported || i.Status == IncidentStatus.InProgress))
        };
    }

    protected override async Task MapAsync(Trail entity, TrailUpsertDto dto, CancellationToken cancellationToken)
    {
        var code = dto.Code.Trim().ToUpperInvariant();

        var resortExists = await Context.SkiResorts.AnyAsync(r => r.Id == dto.SkiResortId && !r.IsDeleted, cancellationToken);
        if (!resortExists)
        {
            throw new ValidationException(nameof(dto.SkiResortId), "Odabrano skijaliste ne postoji.");
        }

        var difficultyExists = await Context.TrailDifficulties
            .AnyAsync(d => d.Id == dto.TrailDifficultyId && !d.IsDeleted, cancellationToken);
        if (!difficultyExists)
        {
            throw new ValidationException(nameof(dto.TrailDifficultyId), "Odabrana tezina staze ne postoji.");
        }

        var duplicate = await Context.Trails.AnyAsync(
            t => t.Id != entity.Id && !t.IsDeleted && t.SkiResortId == dto.SkiResortId && t.Code == code,
            cancellationToken);
        if (duplicate)
        {
            throw new ValidationException(nameof(dto.Code), "Staza sa ovom oznakom vec postoji na odabranom skijalistu.");
        }

        if (dto.VerticalDropMeters > dto.LengthMeters)
        {
            throw new ValidationException(
                nameof(dto.VerticalDropMeters),
                "Visinska razlika ne moze biti veca od duzine staze.");
        }

        entity.Name = dto.Name.Trim();
        entity.Code = code;
        entity.Description = dto.Description?.Trim();
        entity.ImageUrl = dto.ImageUrl?.Trim();
        entity.LengthMeters = dto.LengthMeters;
        entity.VerticalDropMeters = dto.VerticalDropMeters;
        entity.IsOpen = dto.IsOpen;
        entity.HasNightSkiing = dto.HasNightSkiing;
        entity.HasSnowmaking = dto.HasSnowmaking;
        entity.SkiResortId = dto.SkiResortId;
        entity.TrailDifficultyId = dto.TrailDifficultyId;
    }

    public async Task<TrailDto> UpdateStatusAsync(int id, TrailStatusUpdateDto dto, CancellationToken cancellationToken = default)
    {
        var entity = await Context.Trails.FirstOrDefaultAsync(t => t.Id == id && !t.IsDeleted, cancellationToken)
            ?? throw NotFoundException.For(EntityName, id);

        entity.IsOpen = dto.IsOpen;
        entity.EstimatedCrowdLevel = ParseEnum<CrowdLevel>(dto.EstimatedCrowdLevel, nameof(dto.EstimatedCrowdLevel));

        await Context.SaveChangesAsync(cancellationToken);

        Logger.LogInformation("Staza {TrailId} je postavljena na status otvorena={IsOpen}.", id, dto.IsOpen);
        return await GetByIdAsync(id, cancellationToken);
    }

    protected override async Task EnsureCanDeleteAsync(Trail entity, CancellationToken cancellationToken)
    {
        var incidentCount = await Context.Incidents.CountAsync(i => i.TrailId == entity.Id && !i.IsDeleted, cancellationToken);
        EnsureNotReferenced(EntityName, "Incidenti", incidentCount);

        var reviewCount = await Context.Reviews.CountAsync(r => r.TrailId == entity.Id && !r.IsDeleted, cancellationToken);
        EnsureNotReferenced(EntityName, "Ocjene korisnika", reviewCount);
    }
}

public class TrailConditionLogService
    : CrudServiceBase<TrailConditionLog, TrailConditionLogDto, TrailConditionLogCreateDto, TrailConditionLogSearchDto>,
      ITrailConditionLogService
{
    private readonly ICurrentUserService _currentUserService;

    public TrailConditionLogService(
        ApplicationDbContext context,
        ICurrentUserService currentUserService,
        ILogger<TrailConditionLogService> logger)
        : base(context, logger)
    {
        _currentUserService = currentUserService;
    }

    protected override string EntityName => "Evidencija stanja staze";

    protected override IQueryable<TrailConditionLog> BaseQuery() =>
        Context.TrailConditionLogs
            .Include(c => c.Trail)
            .Include(c => c.RecordedByUser);

    protected override IQueryable<TrailConditionLog> ApplyFilters(IQueryable<TrailConditionLog> query, TrailConditionLogSearchDto request)
    {
        if (!string.IsNullOrWhiteSpace(request.Query))
        {
            var term = request.Query.Trim();
            query = query.Where(c => c.ConditionNote.Contains(term) || c.Trail.Name.Contains(term));
        }

        if (request.TrailId.HasValue)
        {
            query = query.Where(c => c.TrailId == request.TrailId.Value);
        }

        if (request.SkiResortId.HasValue)
        {
            query = query.Where(c => c.Trail.SkiResortId == request.SkiResortId.Value);
        }

        if (request.RecordedFrom.HasValue)
        {
            query = query.Where(c => c.RecordedAt >= request.RecordedFrom.Value);
        }

        if (request.RecordedTo.HasValue)
        {
            query = query.Where(c => c.RecordedAt <= request.RecordedTo.Value);
        }

        return query;
    }

    protected override IQueryable<TrailConditionLog> ApplyDefaultSort(IQueryable<TrailConditionLog> query) =>
        query.OrderByDescending(c => c.RecordedAt);

    protected override TrailConditionLogDto MapToDto(TrailConditionLog e) => new()
    {
        Id = e.Id,
        RecordedAt = e.RecordedAt,
        SnowDepthCm = e.SnowDepthCm,
        ConditionNote = e.ConditionNote,
        IsTrailOpen = e.IsTrailOpen,
        TrailId = e.TrailId,
        TrailName = e.Trail.Name,
        RecordedByUserId = e.RecordedByUserId,
        RecordedByUserName = $"{e.RecordedByUser.FirstName} {e.RecordedByUser.LastName}"
    };

    /// <summary>
    /// Evidentiranje stanja istovremeno postavlja i status staze,
    /// kako prikaz u mobilnoj aplikaciji ne bi odstupao od zadnje evidencije.
    /// </summary>
    protected override async Task MapAsync(TrailConditionLog entity, TrailConditionLogCreateDto dto, CancellationToken cancellationToken)
    {
        var trail = await Context.Trails.FirstOrDefaultAsync(t => t.Id == dto.TrailId && !t.IsDeleted, cancellationToken)
            ?? throw new ValidationException(nameof(dto.TrailId), "Odabrana staza ne postoji.");

        entity.TrailId = dto.TrailId;
        entity.SnowDepthCm = dto.SnowDepthCm;
        entity.ConditionNote = dto.ConditionNote.Trim();
        entity.IsTrailOpen = dto.IsTrailOpen;

        if (entity.Id == 0)
        {
            entity.RecordedAt = DateTime.UtcNow;
            entity.RecordedByUserId = _currentUserService.GetRequiredUserId();
        }

        trail.IsOpen = dto.IsTrailOpen;
    }
}
