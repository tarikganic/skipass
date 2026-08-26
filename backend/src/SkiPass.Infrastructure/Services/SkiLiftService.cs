using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;
using SkiPass.Application.DTOs.Common;
using SkiPass.Application.DTOs.Lifts;
using SkiPass.Application.Exceptions;
using SkiPass.Application.Services.Interfaces;
using SkiPass.Domain.Entities;
using SkiPass.Domain.Enums;
using SkiPass.Domain.Rules;
using SkiPass.Infrastructure.Data;

namespace SkiPass.Infrastructure.Services;

public class SkiLiftService
    : CrudServiceBase<SkiLift, SkiLiftDto, SkiLiftUpsertDto, SkiLiftSearchDto>, ISkiLiftService
{
    public SkiLiftService(ApplicationDbContext context, ILogger<SkiLiftService> logger)
        : base(context, logger)
    {
    }

    protected override string EntityName => "Ski lift";

    protected override IQueryable<SkiLift> BaseQuery() =>
        Context.SkiLifts
            .Include(l => l.SkiResort)
            .Include(l => l.LiftType)
            .Include(l => l.MaintenanceRecords);

    public async Task<List<LookupDto>> GetLookupAsync(CancellationToken cancellationToken = default) =>
        await Context.SkiLifts
            .Where(l => !l.IsDeleted)
            .OrderBy(l => l.Name)
            .Select(l => new LookupDto { Id = l.Id, Name = l.Name })
            .AsNoTracking()
            .ToListAsync(cancellationToken);

    protected override IQueryable<SkiLift> ApplyFilters(IQueryable<SkiLift> query, SkiLiftSearchDto request)
    {
        if (!string.IsNullOrWhiteSpace(request.Query))
        {
            var term = request.Query.Trim();
            query = query.Where(l =>
                l.Name.Contains(term) ||
                l.Code.Contains(term) ||
                (l.Description != null && l.Description.Contains(term)));
        }

        if (request.SkiResortId.HasValue)
        {
            query = query.Where(l => l.SkiResortId == request.SkiResortId.Value);
        }

        if (request.LiftTypeId.HasValue)
        {
            query = query.Where(l => l.LiftTypeId == request.LiftTypeId.Value);
        }

        if (request.IsOperational.HasValue)
        {
            query = query.Where(l => l.IsOperational == request.IsOperational.Value);
        }

        return query;
    }

    protected override IQueryable<SkiLift> ApplyDefaultSort(IQueryable<SkiLift> query) => query.OrderBy(l => l.Name);

    protected override IQueryable<SkiLift>? ApplySort(IQueryable<SkiLift> query, string sortBy, bool descending) =>
        sortBy.ToLowerInvariant() switch
        {
            "name" => descending ? query.OrderByDescending(l => l.Name) : query.OrderBy(l => l.Name),
            "capacity" => descending ? query.OrderByDescending(l => l.CapacityPerHour) : query.OrderBy(l => l.CapacityPerHour),
            "currentriders" => descending ? query.OrderByDescending(l => l.CurrentRiders) : query.OrderBy(l => l.CurrentRiders),
            _ => null
        };

    protected override SkiLiftDto MapToDto(SkiLift e) => new()
    {
        Id = e.Id,
        Name = e.Name,
        Code = e.Code,
        Description = e.Description,
        LengthMeters = e.LengthMeters,
        CapacityPerHour = e.CapacityPerHour,
        RideDurationMinutes = e.RideDurationMinutes,
        IsOperational = e.IsOperational,
        CurrentRiders = e.CurrentRiders,
        LastMaintenanceAt = e.LastMaintenanceAt,
        SkiResortId = e.SkiResortId,
        SkiResortName = e.SkiResort.Name,
        LiftTypeId = e.LiftTypeId,
        LiftTypeName = e.LiftType.Name,
        OpenMaintenanceCount = e.MaintenanceRecords.Count(m => !m.IsDeleted && MaintenanceStatusRules.IsOpen(m.Status))
    };

    protected override async Task MapAsync(SkiLift entity, SkiLiftUpsertDto dto, CancellationToken cancellationToken)
    {
        var code = dto.Code.Trim().ToUpperInvariant();

        var resortExists = await Context.SkiResorts.AnyAsync(r => r.Id == dto.SkiResortId && !r.IsDeleted, cancellationToken);
        if (!resortExists)
        {
            throw new ValidationException(nameof(dto.SkiResortId), "Odabrano skijaliste ne postoji.");
        }

        var liftTypeExists = await Context.LiftTypes.AnyAsync(t => t.Id == dto.LiftTypeId && !t.IsDeleted, cancellationToken);
        if (!liftTypeExists)
        {
            throw new ValidationException(nameof(dto.LiftTypeId), "Odabrani tip lifta ne postoji.");
        }

        var duplicate = await Context.SkiLifts.AnyAsync(
            l => l.Id != entity.Id && !l.IsDeleted && l.SkiResortId == dto.SkiResortId && l.Code == code,
            cancellationToken);
        if (duplicate)
        {
            throw new ValidationException(nameof(dto.Code), "Lift sa ovom oznakom vec postoji na odabranom skijalistu.");
        }

        entity.Name = dto.Name.Trim();
        entity.Code = code;
        entity.Description = dto.Description?.Trim();
        entity.LengthMeters = dto.LengthMeters;
        entity.CapacityPerHour = dto.CapacityPerHour;
        entity.RideDurationMinutes = dto.RideDurationMinutes;
        entity.IsOperational = dto.IsOperational;
        entity.SkiResortId = dto.SkiResortId;
        entity.LiftTypeId = dto.LiftTypeId;
    }

    public async Task<SkiLiftDto> UpdateStatusAsync(int id, SkiLiftStatusUpdateDto dto, CancellationToken cancellationToken = default)
    {
        var entity = await Context.SkiLifts
            .Include(l => l.MaintenanceRecords)
            .FirstOrDefaultAsync(l => l.Id == id && !l.IsDeleted, cancellationToken)
            ?? throw NotFoundException.For(EntityName, id);

        if (dto.IsOperational)
        {
            var blockingCount = entity.MaintenanceRecords
                .Count(m => !m.IsDeleted && m.RequiresShutdown && MaintenanceStatusRules.IsOpen(m.Status));

            if (blockingCount > 0)
            {
                throw new BusinessException(
                    $"Lift se ne moze pustiti u pogon jer postoji {blockingCount} nerijesenih kvarova koji zahtijevaju obustavu rada.");
            }
        }

        entity.IsOperational = dto.IsOperational;
        if (!dto.IsOperational)
        {
            entity.CurrentRiders = 0;
        }

        await Context.SaveChangesAsync(cancellationToken);

        Logger.LogInformation("Ski lift {SkiLiftId} je postavljen na status u pogonu={IsOperational}.", id, dto.IsOperational);
        return await GetByIdAsync(id, cancellationToken);
    }

    protected override async Task EnsureCanDeleteAsync(SkiLift entity, CancellationToken cancellationToken)
    {
        var validationCount = await Context.TicketValidations
            .CountAsync(v => v.SkiLiftId == entity.Id && !v.IsDeleted, cancellationToken);
        EnsureNotReferenced(EntityName, "Validacije karata", validationCount);

        var incidentCount = await Context.Incidents
            .CountAsync(i => i.SkiLiftId == entity.Id && !i.IsDeleted, cancellationToken);
        EnsureNotReferenced(EntityName, "Incidenti", incidentCount);
    }
}

public class LiftMaintenanceService
    : CrudServiceBase<LiftMaintenanceRecord, LiftMaintenanceRecordDto, LiftMaintenanceRecordCreateDto, LiftMaintenanceSearchDto>,
      ILiftMaintenanceService
{
    private readonly ICurrentUserService _currentUserService;

    public LiftMaintenanceService(
        ApplicationDbContext context,
        ICurrentUserService currentUserService,
        ILogger<LiftMaintenanceService> logger)
        : base(context, logger)
    {
        _currentUserService = currentUserService;
    }

    protected override string EntityName => "Evidencija kvara lifta";

    protected override IQueryable<LiftMaintenanceRecord> BaseQuery() =>
        Context.LiftMaintenanceRecords
            .Include(m => m.SkiLift)
            .Include(m => m.ReportedByUser)
            .Include(m => m.ResolvedByUser);

    protected override IQueryable<LiftMaintenanceRecord> ApplyFilters(IQueryable<LiftMaintenanceRecord> query, LiftMaintenanceSearchDto request)
    {
        if (!string.IsNullOrWhiteSpace(request.Query))
        {
            var term = request.Query.Trim();
            query = query.Where(m =>
                m.Description.Contains(term) ||
                (m.ResolutionNote != null && m.ResolutionNote.Contains(term)) ||
                m.SkiLift.Name.Contains(term));
        }

        if (request.SkiLiftId.HasValue)
        {
            query = query.Where(m => m.SkiLiftId == request.SkiLiftId.Value);
        }

        if (request.SkiResortId.HasValue)
        {
            query = query.Where(m => m.SkiLift.SkiResortId == request.SkiResortId.Value);
        }

        if (!string.IsNullOrWhiteSpace(request.Status))
        {
            var status = ParseEnum<MaintenanceStatus>(request.Status, nameof(request.Status));
            query = query.Where(m => m.Status == status);
        }

        if (request.RequiresShutdown.HasValue)
        {
            query = query.Where(m => m.RequiresShutdown == request.RequiresShutdown.Value);
        }

        if (request.ReportedFrom.HasValue)
        {
            query = query.Where(m => m.ReportedAt >= request.ReportedFrom.Value);
        }

        if (request.ReportedTo.HasValue)
        {
            query = query.Where(m => m.ReportedAt <= request.ReportedTo.Value);
        }

        return query;
    }

    protected override IQueryable<LiftMaintenanceRecord> ApplyDefaultSort(IQueryable<LiftMaintenanceRecord> query) =>
        query.OrderByDescending(m => m.ReportedAt);

    protected override LiftMaintenanceRecordDto MapToDto(LiftMaintenanceRecord e) => new()
    {
        Id = e.Id,
        ReportedAt = e.ReportedAt,
        ResolvedAt = e.ResolvedAt,
        Description = e.Description,
        ResolutionNote = e.ResolutionNote,
        Status = e.Status.ToString(),
        RequiresShutdown = e.RequiresShutdown,
        SkiLiftId = e.SkiLiftId,
        SkiLiftName = e.SkiLift.Name,
        ReportedByUserId = e.ReportedByUserId,
        ReportedByUserName = $"{e.ReportedByUser.FirstName} {e.ReportedByUser.LastName}",
        ResolvedByUserId = e.ResolvedByUserId,
        ResolvedByUserName = e.ResolvedByUser == null
            ? null
            : $"{e.ResolvedByUser.FirstName} {e.ResolvedByUser.LastName}",
        AllowedNextStatuses = MaintenanceStatusRules.OpenStatuses
            .Concat([MaintenanceStatus.Completed, MaintenanceStatus.Cancelled])
            .Distinct()
            .Where(s => MaintenanceStatusRules.CanTransition(e.Status, s))
            .Select(s => s.ToString())
            .ToList()
    };

    protected override async Task MapAsync(LiftMaintenanceRecord entity, LiftMaintenanceRecordCreateDto dto, CancellationToken cancellationToken)
    {
        var lift = await Context.SkiLifts.FirstOrDefaultAsync(l => l.Id == dto.SkiLiftId && !l.IsDeleted, cancellationToken)
            ?? throw new ValidationException(nameof(dto.SkiLiftId), "Odabrani ski lift ne postoji.");

        entity.SkiLiftId = dto.SkiLiftId;
        entity.Description = dto.Description.Trim();
        entity.RequiresShutdown = dto.RequiresShutdown;

        if (entity.Id == 0)
        {
            entity.ReportedAt = DateTime.UtcNow;
            entity.ReportedByUserId = _currentUserService.GetRequiredUserId();
            entity.Status = MaintenanceStatus.Reported;
        }

        // Kvar koji zahtijeva obustavu odmah zaustavlja lift.
        if (dto.RequiresShutdown)
        {
            lift.IsOperational = false;
            lift.CurrentRiders = 0;
        }
    }

    public async Task<LiftMaintenanceRecordDto> UpdateStatusAsync(int id, LiftMaintenanceStatusUpdateDto dto, CancellationToken cancellationToken = default)
    {
        var entity = await Context.LiftMaintenanceRecords
            .Include(m => m.SkiLift)
            .FirstOrDefaultAsync(m => m.Id == id && !m.IsDeleted, cancellationToken)
            ?? throw NotFoundException.For(EntityName, id);

        var newStatus = ParseEnum<MaintenanceStatus>(dto.Status, nameof(dto.Status));

        if (!MaintenanceStatusRules.CanTransition(entity.Status, newStatus))
        {
            throw new BusinessException(
                $"Prelaz iz statusa \"{entity.Status}\" u status \"{newStatus}\" nije dozvoljen.");
        }

        if (newStatus is MaintenanceStatus.Completed or MaintenanceStatus.Cancelled
            && string.IsNullOrWhiteSpace(dto.ResolutionNote))
        {
            throw new ValidationException(
                nameof(dto.ResolutionNote),
                "Obrazlozenje je obavezno pri zatvaranju ili otkazivanju zapisa o kvaru.");
        }

        entity.Status = newStatus;
        entity.ResolutionNote = dto.ResolutionNote?.Trim();

        if (newStatus is MaintenanceStatus.Completed or MaintenanceStatus.Cancelled)
        {
            entity.ResolvedAt = DateTime.UtcNow;
            entity.ResolvedByUserId = _currentUserService.GetRequiredUserId();
            entity.SkiLift.LastMaintenanceAt = DateTime.UtcNow;
        }

        await Context.SaveChangesAsync(cancellationToken);

        Logger.LogInformation("Kvar lifta {MaintenanceId} je prebacen u status {Status}.", id, newStatus);
        return await GetByIdAsync(id, cancellationToken);
    }
}
