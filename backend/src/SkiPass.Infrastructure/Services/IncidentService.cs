using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;
using SkiPass.Application.Common;
using SkiPass.Application.DTOs.Incidents;
using SkiPass.Application.Exceptions;
using SkiPass.Application.Services.Interfaces;
using SkiPass.Domain.Entities;
using SkiPass.Domain.Enums;
using SkiPass.Domain.Interfaces;
using SkiPass.Domain.Rules;
using SkiPass.Infrastructure.Data;

namespace SkiPass.Infrastructure.Services;

public class IncidentService : IIncidentService
{
    private const string EntityName = "Incident";

    private readonly ApplicationDbContext _context;
    private readonly ICurrentUserService _currentUserService;
    private readonly IUnitOfWork _unitOfWork;
    private readonly ILogger<IncidentService> _logger;

    public IncidentService(
        ApplicationDbContext context,
        ICurrentUserService currentUserService,
        IUnitOfWork unitOfWork,
        ILogger<IncidentService> logger)
    {
        _context = context;
        _currentUserService = currentUserService;
        _unitOfWork = unitOfWork;
        _logger = logger;
    }

    public async Task<PagedResult<IncidentDto>> SearchAsync(IncidentSearchDto request, CancellationToken cancellationToken = default)
    {
        var query = BaseQuery().Where(i => !i.IsDeleted);

        // Skijas vidi samo incidente koje je sam prijavio.
        if (!_currentUserService.IsStaffOrAdmin)
        {
            var currentUserId = _currentUserService.GetRequiredUserId();
            query = query.Where(i => i.ReportedByUserId == currentUserId);
        }
        else if (request.ReportedByUserId.HasValue)
        {
            query = query.Where(i => i.ReportedByUserId == request.ReportedByUserId.Value);
        }

        if (!string.IsNullOrWhiteSpace(request.Query))
        {
            var term = request.Query.Trim();
            query = query.Where(i =>
                i.Description.Contains(term) ||
                (i.ResolutionNote != null && i.ResolutionNote.Contains(term)) ||
                i.ReportedByUser.FirstName.Contains(term) ||
                i.ReportedByUser.LastName.Contains(term));
        }

        if (request.IncidentTypeId.HasValue)
        {
            query = query.Where(i => i.IncidentTypeId == request.IncidentTypeId.Value);
        }

        if (request.TrailId.HasValue)
        {
            query = query.Where(i => i.TrailId == request.TrailId.Value);
        }

        if (request.SkiLiftId.HasValue)
        {
            query = query.Where(i => i.SkiLiftId == request.SkiLiftId.Value);
        }

        if (request.SkiResortId.HasValue)
        {
            var resortId = request.SkiResortId.Value;
            query = query.Where(i =>
                (i.Trail != null && i.Trail.SkiResortId == resortId) ||
                (i.SkiLift != null && i.SkiLift.SkiResortId == resortId));
        }

        if (!string.IsNullOrWhiteSpace(request.Status))
        {
            var status = ParseStatus(request.Status, nameof(request.Status));
            query = query.Where(i => i.Status == status);
        }

        if (request.IsUrgent.HasValue)
        {
            query = query.Where(i => i.IsUrgent == request.IsUrgent.Value);
        }

        if (request.ReportedFrom.HasValue)
        {
            query = query.Where(i => i.ReportedAt >= request.ReportedFrom.Value);
        }

        if (request.ReportedTo.HasValue)
        {
            query = query.Where(i => i.ReportedAt <= request.ReportedTo.Value);
        }

        var totalCount = await query.CountAsync(cancellationToken);

        var entities = await query
            .OrderByDescending(i => i.IsUrgent)
            .ThenByDescending(i => i.ReportedAt)
            .Skip((request.Page - 1) * request.PageSize)
            .Take(request.PageSize)
            .AsNoTracking()
            .ToListAsync(cancellationToken);

        return entities.Select(MapToDto).ToList().ToPagedResult(totalCount, request);
    }

    public async Task<IncidentDto> GetByIdAsync(int id, CancellationToken cancellationToken = default)
    {
        var entity = await BaseQuery()
            .AsNoTracking()
            .FirstOrDefaultAsync(i => i.Id == id && !i.IsDeleted, cancellationToken)
            ?? throw NotFoundException.For(EntityName, id);

        _currentUserService.EnsureCanAccessUser(entity.ReportedByUserId);

        return MapToDto(entity);
    }

    public async Task<IncidentDto> CreateAsync(IncidentCreateDto dto, int reportedByUserId, CancellationToken cancellationToken = default)
    {
        var incidentType = await _context.IncidentTypes
            .FirstOrDefaultAsync(t => t.Id == dto.IncidentTypeId && !t.IsDeleted, cancellationToken)
            ?? throw new ValidationException(nameof(dto.IncidentTypeId), "Odabrani tip incidenta ne postoji.");

        if (dto.TrailId.HasValue)
        {
            var trailExists = await _context.Trails.AnyAsync(t => t.Id == dto.TrailId.Value && !t.IsDeleted, cancellationToken);
            if (!trailExists)
            {
                throw new ValidationException(nameof(dto.TrailId), "Odabrana staza ne postoji.");
            }
        }

        if (dto.SkiLiftId.HasValue)
        {
            var liftExists = await _context.SkiLifts.AnyAsync(l => l.Id == dto.SkiLiftId.Value && !l.IsDeleted, cancellationToken);
            if (!liftExists)
            {
                throw new ValidationException(nameof(dto.SkiLiftId), "Odabrani ski lift ne postoji.");
            }
        }

        var incident = new Incident
        {
            ReportedAt = DateTime.UtcNow,
            Description = dto.Description.Trim(),
            ImageUrl = dto.ImageUrl?.Trim(),
            Latitude = dto.Latitude,
            Longitude = dto.Longitude,
            Status = IncidentStatus.Reported,
            IsUrgent = incidentType.IsUrgentByDefault,
            ReportedByUserId = reportedByUserId,
            IncidentTypeId = dto.IncidentTypeId,
            TrailId = dto.TrailId,
            SkiLiftId = dto.SkiLiftId
        };

        _context.Incidents.Add(incident);
        await _context.SaveChangesAsync(cancellationToken);

        _logger.LogInformation(
            "Prijavljen incident {IncidentId} tipa {IncidentType} od korisnika {UserId}.",
            incident.Id, incidentType.Name, reportedByUserId);

        return await LoadAsync(incident.Id, cancellationToken);
    }

    public async Task<IncidentDto> UpdateStatusAsync(int id, IncidentStatusUpdateDto dto, int handledByUserId, CancellationToken cancellationToken = default)
    {
        var incident = await _context.Incidents
            .FirstOrDefaultAsync(i => i.Id == id && !i.IsDeleted, cancellationToken)
            ?? throw NotFoundException.For(EntityName, id);

        var newStatus = ParseStatus(dto.Status, nameof(dto.Status));

        if (!IncidentStatusRules.CanTransition(incident.Status, newStatus))
        {
            throw new BusinessException(
                $"Prelaz iz statusa \"{incident.Status}\" u status \"{newStatus}\" nije dozvoljen.");
        }

        if (IncidentStatusRules.RequiresNote(newStatus) && string.IsNullOrWhiteSpace(dto.ResolutionNote))
        {
            throw new ValidationException(
                nameof(dto.ResolutionNote),
                newStatus == IncidentStatus.Rejected
                    ? "Razlog odbijanja prijave je obavezan."
                    : "Obrazlozenje rjesavanja incidenta je obavezno.");
        }

        await _unitOfWork.BeginTransactionAsync(cancellationToken);
        try
        {
            incident.Status = newStatus;
            incident.ResolutionNote = dto.ResolutionNote?.Trim();
            incident.HandledByUserId = handledByUserId;
            incident.HandledAt = DateTime.UtcNow;

            await _context.SaveChangesAsync(cancellationToken);

            _context.Notifications.Add(new Notification
            {
                UserId = incident.ReportedByUserId,
                Title = "Status prijave incidenta",
                Message = newStatus == IncidentStatus.Rejected
                    ? $"Vasa prijava je odbijena. Razlog: {incident.ResolutionNote}"
                    : $"Status vase prijave je promijenjen u \"{newStatus}\".",
                Type = NotificationType.IncidentStatusChanged,
                TargetRoute = $"/incidents/{incident.Id}"
            });
            await _context.SaveChangesAsync(cancellationToken);

            await _unitOfWork.CommitTransactionAsync(cancellationToken);

            _logger.LogInformation("Incident {IncidentId} je prebacen u status {Status}.", id, newStatus);
            return await LoadAsync(id, cancellationToken);
        }
        catch
        {
            await _unitOfWork.RollbackTransactionAsync(cancellationToken);
            throw;
        }
    }

    public async Task DeleteAsync(int id, CancellationToken cancellationToken = default)
    {
        var incident = await _context.Incidents
            .FirstOrDefaultAsync(i => i.Id == id && !i.IsDeleted, cancellationToken)
            ?? throw NotFoundException.For(EntityName, id);

        if (incident.Status == IncidentStatus.InProgress)
        {
            throw new BusinessException("Incident koji je u obradi se ne moze obrisati. Prvo ga rijesite ili odbijte.");
        }

        incident.IsDeleted = true;
        await _context.SaveChangesAsync(cancellationToken);

        _logger.LogInformation("Obrisan incident {IncidentId}.", id);
    }

    private async Task<IncidentDto> LoadAsync(int id, CancellationToken cancellationToken)
    {
        var entity = await BaseQuery().AsNoTracking().FirstAsync(i => i.Id == id, cancellationToken);
        return MapToDto(entity);
    }

    private IQueryable<Incident> BaseQuery() =>
        _context.Incidents
            .Include(i => i.ReportedByUser)
            .Include(i => i.HandledByUser)
            .Include(i => i.IncidentType)
            .Include(i => i.Trail)
            .Include(i => i.SkiLift);

    private static IncidentDto MapToDto(Incident e) => new()
    {
        Id = e.Id,
        ReportedAt = e.ReportedAt,
        Description = e.Description,
        ImageUrl = e.ImageUrl,
        Latitude = e.Latitude,
        Longitude = e.Longitude,
        Status = e.Status.ToString(),
        IsUrgent = e.IsUrgent,
        ResolutionNote = e.ResolutionNote,
        HandledAt = e.HandledAt,
        ReportedByUserId = e.ReportedByUserId,
        ReportedByUserName = $"{e.ReportedByUser.FirstName} {e.ReportedByUser.LastName}",
        ReportedByUserPhone = e.ReportedByUser.Phone ?? string.Empty,
        HandledByUserId = e.HandledByUserId,
        HandledByUserName = e.HandledByUser == null
            ? null
            : $"{e.HandledByUser.FirstName} {e.HandledByUser.LastName}",
        IncidentTypeId = e.IncidentTypeId,
        IncidentTypeName = e.IncidentType.Name,
        TrailId = e.TrailId,
        TrailName = e.Trail?.Name,
        SkiLiftId = e.SkiLiftId,
        SkiLiftName = e.SkiLift?.Name,
        AllowedNextStatuses = Enum.GetValues<IncidentStatus>()
            .Where(s => IncidentStatusRules.CanTransition(e.Status, s))
            .Select(s => s.ToString())
            .ToList()
    };

    private static IncidentStatus ParseStatus(string value, string field)
    {
        if (!Enum.TryParse<IncidentStatus>(value, ignoreCase: true, out var parsed) || !Enum.IsDefined(parsed))
        {
            throw new ValidationException(
                field,
                $"Nepoznat status \"{value}\". Dozvoljene vrijednosti su: {string.Join(", ", Enum.GetNames<IncidentStatus>())}.");
        }

        return parsed;
    }
}
