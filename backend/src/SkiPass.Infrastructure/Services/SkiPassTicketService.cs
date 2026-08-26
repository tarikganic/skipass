using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;
using SkiPass.Application.Common;
using SkiPass.Application.DTOs.Tickets;
using SkiPass.Application.Exceptions;
using SkiPass.Application.Services.Interfaces;
using SkiPass.Domain.Entities;
using SkiPass.Domain.Enums;
using SkiPass.Domain.Interfaces;
using SkiPass.Domain.Rules;
using SkiPass.Infrastructure.Data;

namespace SkiPass.Infrastructure.Services;

public class SkiPassTicketService : ISkiPassTicketService
{
    private const string EntityName = "Ski pass karta";

    /// <summary>
    /// Ista karta se ne racuna kao nova voznja ako se skenira ponovo na istom liftu
    /// unutar ovog perioda. Sprjecava dvostruko brojanje pri ponovljenom skeniranju.
    /// </summary>
    private static readonly TimeSpan RescanWindow = TimeSpan.FromMinutes(2);

    private readonly ApplicationDbContext _context;
    private readonly ICurrentUserService _currentUserService;
    private readonly IUnitOfWork _unitOfWork;
    private readonly ILogger<SkiPassTicketService> _logger;

    public SkiPassTicketService(
        ApplicationDbContext context,
        ICurrentUserService currentUserService,
        IUnitOfWork unitOfWork,
        ILogger<SkiPassTicketService> logger)
    {
        _context = context;
        _currentUserService = currentUserService;
        _unitOfWork = unitOfWork;
        _logger = logger;
    }

    public async Task<PagedResult<SkiPassTicketDto>> SearchAsync(SkiPassTicketSearchDto request, CancellationToken cancellationToken = default)
    {
        var query = BaseQuery().Where(t => !t.IsDeleted);

        if (!_currentUserService.IsStaffOrAdmin)
        {
            var currentUserId = _currentUserService.GetRequiredUserId();
            query = query.Where(t => t.SkiPassOrder.UserId == currentUserId);
        }
        else if (request.UserId.HasValue)
        {
            query = query.Where(t => t.SkiPassOrder.UserId == request.UserId.Value);
        }

        if (!string.IsNullOrWhiteSpace(request.Query))
        {
            var term = request.Query.Trim();
            query = query.Where(t =>
                t.QrCode.Contains(term) ||
                t.HolderFirstName.Contains(term) ||
                t.HolderLastName.Contains(term) ||
                t.SkiPassOrder.OrderNumber.Contains(term));
        }

        if (request.SkiPassOrderId.HasValue)
        {
            query = query.Where(t => t.SkiPassOrderId == request.SkiPassOrderId.Value);
        }

        if (request.TicketTypeId.HasValue)
        {
            query = query.Where(t => t.TicketTypeId == request.TicketTypeId.Value);
        }

        if (request.SkiResortId.HasValue)
        {
            query = query.Where(t => t.TicketType.SkiResortId == request.SkiResortId.Value);
        }

        if (!string.IsNullOrWhiteSpace(request.Status))
        {
            var status = ParseTicketStatus(request.Status, nameof(request.Status));
            query = query.Where(t => t.Status == status);
        }

        if (request.ValidOnDate.HasValue)
        {
            var date = request.ValidOnDate.Value;
            query = query.Where(t => t.ValidFrom <= date && t.ValidTo >= date);
        }

        if (request.ValidFromDate.HasValue)
        {
            query = query.Where(t => t.ValidFrom >= request.ValidFromDate.Value);
        }

        if (request.ValidToDate.HasValue)
        {
            query = query.Where(t => t.ValidTo <= request.ValidToDate.Value);
        }

        var totalCount = await query.CountAsync(cancellationToken);

        var entities = await query
            .OrderByDescending(t => t.ValidFrom)
            .ThenBy(t => t.HolderLastName)
            .Skip((request.Page - 1) * request.PageSize)
            .Take(request.PageSize)
            .AsNoTracking()
            .ToListAsync(cancellationToken);

        return entities.Select(MapTicket).ToList().ToPagedResult(totalCount, request);
    }

    public async Task<SkiPassTicketDto> GetByIdAsync(int id, CancellationToken cancellationToken = default)
    {
        var entity = await BaseQuery()
            .AsNoTracking()
            .FirstOrDefaultAsync(t => t.Id == id && !t.IsDeleted, cancellationToken)
            ?? throw NotFoundException.For(EntityName, id);

        _currentUserService.EnsureCanAccessUser(entity.SkiPassOrder.UserId);

        return MapTicket(entity);
    }

    /// <summary>
    /// Validira QR kod karte na ulazu na ski lift. Svaki pokusaj se evidentira,
    /// ukljucujuci i neuspjesne, kako bi se mogla pratiti zloupotreba karata.
    /// </summary>
    public async Task<TicketValidationDto> ValidateAsync(TicketValidationRequestDto dto, int validatedByUserId, CancellationToken cancellationToken = default)
    {
        var lift = await _context.SkiLifts
            .FirstOrDefaultAsync(l => l.Id == dto.SkiLiftId && !l.IsDeleted, cancellationToken)
            ?? throw new ValidationException(nameof(dto.SkiLiftId), "Odabrani ski lift ne postoji.");

        var qrCode = dto.QrCode.Trim();
        var ticket = await _context.SkiPassTickets
            .Include(t => t.TicketType)
            .Include(t => t.SkiPassOrder)
            .FirstOrDefaultAsync(t => t.QrCode == qrCode && !t.IsDeleted, cancellationToken);

        if (ticket is null)
        {
            throw new NotFoundException("Karta sa unesenim QR kodom nije pronadjena.");
        }

        var failureReason = DetermineFailureReason(ticket, lift);

        await _unitOfWork.BeginTransactionAsync(cancellationToken);
        try
        {
            var validation = new TicketValidation
            {
                ValidatedAt = DateTime.UtcNow,
                IsSuccessful = failureReason is null,
                FailureReason = failureReason,
                SkiPassTicketId = ticket.Id,
                SkiLiftId = lift.Id,
                ValidatedByUserId = validatedByUserId
            };

            _context.TicketValidations.Add(validation);

            if (failureReason is null)
            {
                var rescanThreshold = DateTime.UtcNow - RescanWindow;
                var isRescan = await _context.TicketValidations.AnyAsync(
                    v => v.SkiPassTicketId == ticket.Id
                         && v.SkiLiftId == lift.Id
                         && v.IsSuccessful
                         && !v.IsDeleted
                         && v.ValidatedAt >= rescanThreshold,
                    cancellationToken);

                if (!isRescan)
                {
                    lift.CurrentRiders++;
                }

                if (TicketStatusRules.CanTransition(ticket.Status, TicketStatus.Used))
                {
                    ticket.Status = TicketStatus.Used;
                }
            }

            await _context.SaveChangesAsync(cancellationToken);
            await _unitOfWork.CommitTransactionAsync(cancellationToken);

            if (failureReason is null)
            {
                _logger.LogInformation("Karta {TicketId} je uspjesno validirana na liftu {SkiLiftId}.", ticket.Id, lift.Id);
            }
            else
            {
                _logger.LogWarning(
                    "Validacija karte {TicketId} na liftu {SkiLiftId} je odbijena: {Reason}",
                    ticket.Id, lift.Id, failureReason);
            }

            return await LoadValidationAsync(validation.Id, cancellationToken);
        }
        catch
        {
            await _unitOfWork.RollbackTransactionAsync(cancellationToken);
            throw;
        }
    }

    public async Task<PagedResult<TicketValidationDto>> SearchValidationsAsync(TicketValidationSearchDto request, CancellationToken cancellationToken = default)
    {
        var query = ValidationQuery().Where(v => !v.IsDeleted);

        if (!string.IsNullOrWhiteSpace(request.Query))
        {
            var term = request.Query.Trim();
            query = query.Where(v =>
                v.SkiPassTicket.HolderFirstName.Contains(term) ||
                v.SkiPassTicket.HolderLastName.Contains(term) ||
                v.SkiLift.Name.Contains(term) ||
                (v.FailureReason != null && v.FailureReason.Contains(term)));
        }

        if (request.SkiPassTicketId.HasValue)
        {
            query = query.Where(v => v.SkiPassTicketId == request.SkiPassTicketId.Value);
        }

        if (request.SkiLiftId.HasValue)
        {
            query = query.Where(v => v.SkiLiftId == request.SkiLiftId.Value);
        }

        if (request.SkiResortId.HasValue)
        {
            query = query.Where(v => v.SkiLift.SkiResortId == request.SkiResortId.Value);
        }

        if (request.IsSuccessful.HasValue)
        {
            query = query.Where(v => v.IsSuccessful == request.IsSuccessful.Value);
        }

        if (request.ValidatedFrom.HasValue)
        {
            query = query.Where(v => v.ValidatedAt >= request.ValidatedFrom.Value);
        }

        if (request.ValidatedTo.HasValue)
        {
            query = query.Where(v => v.ValidatedAt <= request.ValidatedTo.Value);
        }

        var totalCount = await query.CountAsync(cancellationToken);

        var entities = await query
            .OrderByDescending(v => v.ValidatedAt)
            .Skip((request.Page - 1) * request.PageSize)
            .Take(request.PageSize)
            .AsNoTracking()
            .ToListAsync(cancellationToken);

        return entities.Select(MapValidation).ToList().ToPagedResult(totalCount, request);
    }

    private IQueryable<SkiPassTicket> BaseQuery() =>
        _context.SkiPassTickets
            .Include(t => t.SkiPassOrder)
                .ThenInclude(o => o.PaymentMethod)
            .Include(t => t.TicketType)
                .ThenInclude(t => t.SkiResort)
            .Include(t => t.Validations.Where(v => !v.IsDeleted));

    private IQueryable<TicketValidation> ValidationQuery() =>
        _context.TicketValidations
            .Include(v => v.SkiPassTicket)
                .ThenInclude(t => t.TicketType)
            .Include(v => v.SkiLift)
            .Include(v => v.ValidatedByUser);

    private async Task<TicketValidationDto> LoadValidationAsync(int id, CancellationToken cancellationToken)
    {
        var entity = await ValidationQuery()
            .AsNoTracking()
            .FirstOrDefaultAsync(v => v.Id == id, cancellationToken)
            ?? throw NotFoundException.For("Validacija karte", id);

        return MapValidation(entity);
    }

    /// <summary>Vraca razlog odbijanja validacije ili null ako je karta ispravna.</summary>
    private static string? DetermineFailureReason(SkiPassTicket ticket, SkiLift lift)
    {
        if (!lift.IsOperational)
        {
            return "Ski lift trenutno nije u pogonu.";
        }

        if (ticket.TicketType.SkiResortId != lift.SkiResortId)
        {
            return "Karta ne vazi na ovom skijalistu.";
        }

        if (!TicketStatusRules.IsValidatable(ticket.Status))
        {
            return ticket.Status switch
            {
                TicketStatus.Pending => "Karta jos nije aktivirana jer narudzba nije potvrdjena.",
                TicketStatus.Cancelled => "Karta je otkazana.",
                TicketStatus.Expired => "Karta je istekla.",
                _ => "Karta nije u statusu koji dozvoljava koristenje."
            };
        }

        var today = DateOnly.FromDateTime(DateTime.UtcNow);

        if (today < ticket.ValidFrom)
        {
            return $"Karta pocinje vaziti {ticket.ValidFrom:dd.MM.yyyy}.";
        }

        if (today > ticket.ValidTo)
        {
            return $"Karta je vazila do {ticket.ValidTo:dd.MM.yyyy}.";
        }

        return null;
    }

    private static SkiPassTicketDto MapTicket(SkiPassTicket t) => new()
    {
        Id = t.Id,
        QrCode = t.QrCode,
        HolderFirstName = t.HolderFirstName,
        HolderLastName = t.HolderLastName,
        HolderFullName = $"{t.HolderFirstName} {t.HolderLastName}",
        ValidFrom = t.ValidFrom,
        ValidTo = t.ValidTo,
        NumberOfDays = t.NumberOfDays,
        Price = t.Price,
        Status = t.Status.ToString(),
        ActivatedAt = t.ActivatedAt,
        CancelledAt = t.CancelledAt,
        SkiPassOrderId = t.SkiPassOrderId,
        OrderNumber = t.SkiPassOrder.OrderNumber,
        OrderStatus = t.SkiPassOrder.Status.ToString(),
        PaymentMethodId = t.SkiPassOrder.PaymentMethodId,
        PaymentMethodName = t.SkiPassOrder.PaymentMethod.Name,
        TicketTypeId = t.TicketTypeId,
        TicketTypeName = t.TicketType.Name,
        SkiResortId = t.TicketType.SkiResortId,
        SkiResortName = t.TicketType.SkiResort.Name,
        ValidationCount = t.Validations.Count(v => !v.IsDeleted && v.IsSuccessful),
        LastValidatedAt = t.Validations
            .Where(v => !v.IsDeleted && v.IsSuccessful)
            .Select(v => (DateTime?)v.ValidatedAt)
            .Max()
    };

    private static TicketValidationDto MapValidation(TicketValidation v) => new()
    {
        Id = v.Id,
        ValidatedAt = v.ValidatedAt,
        IsSuccessful = v.IsSuccessful,
        FailureReason = v.FailureReason,
        SkiPassTicketId = v.SkiPassTicketId,
        TicketHolderName = $"{v.SkiPassTicket.HolderFirstName} {v.SkiPassTicket.HolderLastName}",
        TicketTypeName = v.SkiPassTicket.TicketType.Name,
        SkiLiftId = v.SkiLiftId,
        SkiLiftName = v.SkiLift.Name,
        ValidatedByUserId = v.ValidatedByUserId,
        ValidatedByUserName = $"{v.ValidatedByUser.FirstName} {v.ValidatedByUser.LastName}"
    };

    private static TicketStatus ParseTicketStatus(string value, string field)
    {
        if (!Enum.TryParse<TicketStatus>(value, ignoreCase: true, out var parsed) || !Enum.IsDefined(parsed))
        {
            throw new ValidationException(
                field,
                $"Nepoznat status \"{value}\". Dozvoljene vrijednosti su: {string.Join(", ", Enum.GetNames<TicketStatus>())}.");
        }

        return parsed;
    }
}
