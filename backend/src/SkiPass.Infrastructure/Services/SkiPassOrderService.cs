using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;
using SkiPass.Application.Common;
using SkiPass.Application.DTOs.Orders;
using SkiPass.Application.DTOs.Tickets;
using SkiPass.Application.Exceptions;
using SkiPass.Application.Services.Interfaces;
using SkiPass.Domain.Entities;
using SkiPass.Domain.Enums;
using SkiPass.Domain.Interfaces;
using SkiPass.Domain.Rules;
using SkiPass.Infrastructure.Data;

namespace SkiPass.Infrastructure.Services;

public class SkiPassOrderService : ISkiPassOrderService
{
    private const string EntityName = "Narudzba";

    private readonly ApplicationDbContext _context;
    private readonly ICurrentUserService _currentUserService;
    private readonly IUnitOfWork _unitOfWork;
    private readonly ILogger<SkiPassOrderService> _logger;

    public SkiPassOrderService(
        ApplicationDbContext context,
        ICurrentUserService currentUserService,
        IUnitOfWork unitOfWork,
        ILogger<SkiPassOrderService> logger)
    {
        _context = context;
        _currentUserService = currentUserService;
        _unitOfWork = unitOfWork;
        _logger = logger;
    }

    public async Task<PagedResult<SkiPassOrderDto>> SearchAsync(SkiPassOrderSearchDto request, CancellationToken cancellationToken = default)
    {
        var query = BaseQuery().Where(o => !o.IsDeleted);

        // Skijas vidi iskljucivo vlastite narudzbe, bez obzira na poslani filter.
        if (!_currentUserService.IsStaffOrAdmin)
        {
            var currentUserId = _currentUserService.GetRequiredUserId();
            query = query.Where(o => o.UserId == currentUserId);
        }
        else if (request.UserId.HasValue)
        {
            query = query.Where(o => o.UserId == request.UserId.Value);
        }

        if (!string.IsNullOrWhiteSpace(request.Query))
        {
            var term = request.Query.Trim();
            query = query.Where(o =>
                o.OrderNumber.Contains(term) ||
                o.User.FirstName.Contains(term) ||
                o.User.LastName.Contains(term) ||
                o.User.Email.Contains(term));
        }

        if (!string.IsNullOrWhiteSpace(request.Status))
        {
            var status = ParseStatus(request.Status, nameof(request.Status));
            query = query.Where(o => o.Status == status);
        }

        if (request.PaymentMethodId.HasValue)
        {
            query = query.Where(o => o.PaymentMethodId == request.PaymentMethodId.Value);
        }

        if (request.IsPaid.HasValue)
        {
            query = request.IsPaid.Value
                ? query.Where(o => o.Payments.Any(p => !p.IsDeleted && p.Status == PaymentStatus.Completed))
                : query.Where(o => !o.Payments.Any(p => !p.IsDeleted && p.Status == PaymentStatus.Completed));
        }

        if (request.OrderedFrom.HasValue)
        {
            query = query.Where(o => o.OrderDate >= request.OrderedFrom.Value);
        }

        if (request.OrderedTo.HasValue)
        {
            query = query.Where(o => o.OrderDate <= request.OrderedTo.Value);
        }

        if (request.MinTotalAmount.HasValue)
        {
            query = query.Where(o => o.TotalAmount >= request.MinTotalAmount.Value);
        }

        if (request.MaxTotalAmount.HasValue)
        {
            query = query.Where(o => o.TotalAmount <= request.MaxTotalAmount.Value);
        }

        var totalCount = await query.CountAsync(cancellationToken);

        var entities = await query
            .OrderByDescending(o => o.OrderDate)
            .Skip((request.Page - 1) * request.PageSize)
            .Take(request.PageSize)
            .AsNoTracking()
            .ToListAsync(cancellationToken);

        return entities.Select(MapSummary).ToList().ToPagedResult(totalCount, request);
    }

    public async Task<SkiPassOrderDetailsDto> GetByIdAsync(int id, CancellationToken cancellationToken = default)
    {
        var entity = await BaseQuery()
            .Include(o => o.Tickets.Where(t => !t.IsDeleted))
                .ThenInclude(t => t.TicketType)
                    .ThenInclude(t => t.SkiResort)
            .Include(o => o.Tickets.Where(t => !t.IsDeleted))
                .ThenInclude(t => t.Validations.Where(v => !v.IsDeleted))
            .AsNoTracking()
            .FirstOrDefaultAsync(o => o.Id == id && !o.IsDeleted, cancellationToken)
            ?? throw NotFoundException.For(EntityName, id);

        _currentUserService.EnsureCanAccessUser(entity.UserId);

        return MapDetails(entity);
    }

    /// <summary>
    /// Kreira narudzbu sa svim kartama. Cijene se racunaju iskljucivo na serveru
    /// iz vazeceg cjenovnika, a upisi su obuhvaceni jednom transakcijom.
    /// </summary>
    public async Task<SkiPassOrderDetailsDto> CreateAsync(SkiPassOrderCreateDto dto, int userId, CancellationToken cancellationToken = default)
    {
        var paymentMethod = await _context.PaymentMethods
            .FirstOrDefaultAsync(p => p.Id == dto.PaymentMethodId && !p.IsDeleted && p.IsActive, cancellationToken)
            ?? throw new ValidationException(nameof(dto.PaymentMethodId), "Odabrani nacin placanja nije dostupan.");

        var ticketTypeIds = dto.Items.Select(i => i.TicketTypeId).Distinct().ToList();
        var ticketTypes = await _context.TicketTypes
            .Where(t => ticketTypeIds.Contains(t.Id) && !t.IsDeleted && t.IsActive)
            .ToDictionaryAsync(t => t.Id, cancellationToken);

        var missingTypes = ticketTypeIds.Except(ticketTypes.Keys).ToList();
        if (missingTypes.Count > 0)
        {
            throw new ValidationException(nameof(dto.Items), "Jedan ili vise odabranih tipova karata nije dostupan za kupovinu.");
        }

        var today = DateOnly.FromDateTime(DateTime.UtcNow);

        await _unitOfWork.BeginTransactionAsync(cancellationToken);
        try
        {
            var order = new SkiPassOrder
            {
                OrderNumber = await CreateUniqueOrderNumberAsync(cancellationToken),
                OrderDate = DateTime.UtcNow,
                Status = OrderStatus.Pending,
                Note = dto.Note?.Trim(),
                UserId = userId,
                PaymentMethodId = dto.PaymentMethodId
            };

            foreach (var item in dto.Items)
            {
                var ticketType = ticketTypes[item.TicketTypeId];

                if (item.ValidFrom < today)
                {
                    throw new ValidationException(
                        nameof(item.ValidFrom),
                        "Datum pocetka vazenja karte ne moze biti u proslosti.");
                }

                if (item.NumberOfDays > ticketType.MaxDays)
                {
                    throw new ValidationException(
                        nameof(item.NumberOfDays),
                        $"Tip karte \"{ticketType.Name}\" dozvoljava najvise {ticketType.MaxDays} dana.");
                }

                order.Tickets.Add(new SkiPassTicket
                {
                    QrCode = await CreateUniqueQrCodeAsync(cancellationToken),
                    HolderFirstName = item.HolderFirstName.Trim(),
                    HolderLastName = item.HolderLastName.Trim(),
                    ValidFrom = item.ValidFrom,
                    // Karta na jedan dan vazi samo tog dana, pa se oduzima jedan dan.
                    ValidTo = item.ValidFrom.AddDays(item.NumberOfDays - 1),
                    NumberOfDays = item.NumberOfDays,
                    Price = CalculateTicketPrice(ticketType, item.NumberOfDays),
                    Status = TicketStatus.Pending,
                    TicketTypeId = ticketType.Id
                });
            }

            order.TotalAmount = order.Tickets.Sum(t => t.Price);

            _context.SkiPassOrders.Add(order);
            await _context.SaveChangesAsync(cancellationToken);

            _context.Notifications.Add(new Notification
            {
                UserId = userId,
                Title = "Narudzba je zaprimljena",
                Message = $"Vasa narudzba {order.OrderNumber} je zaprimljena. Ukupan iznos je {order.TotalAmount:0.00} BAM.",
                Type = NotificationType.General,
                TargetRoute = $"/orders/{order.Id}"
            });
            await _context.SaveChangesAsync(cancellationToken);

            await _unitOfWork.CommitTransactionAsync(cancellationToken);

            _logger.LogInformation(
                "Kreirana narudzba {OrderNumber} sa {TicketCount} karata za korisnika {UserId}.",
                order.OrderNumber, order.Tickets.Count, userId);

            return await GetByIdAsync(order.Id, cancellationToken);
        }
        catch
        {
            await _unitOfWork.RollbackTransactionAsync(cancellationToken);
            throw;
        }
    }

    public async Task<SkiPassOrderDetailsDto> UpdateStatusAsync(int id, SkiPassOrderStatusUpdateDto dto, int actingUserId, CancellationToken cancellationToken = default)
    {
        var order = await _context.SkiPassOrders
            .Include(o => o.Tickets.Where(t => !t.IsDeleted))
            .Include(o => o.Payments.Where(p => !p.IsDeleted))
            .FirstOrDefaultAsync(o => o.Id == id && !o.IsDeleted, cancellationToken)
            ?? throw NotFoundException.For(EntityName, id);

        _currentUserService.EnsureCanAccessUser(order.UserId);

        var newStatus = ParseStatus(dto.Status, nameof(dto.Status));

        if (!OrderStatusRules.CanTransition(order.Status, newStatus))
        {
            var allowed = OrderStatusRules.GetAllowedTransitions(order.Status);
            var allowedText = allowed.Count == 0
                ? "narudzba je u zavrsnom statusu"
                : $"dozvoljeni statusi su: {string.Join(", ", allowed)}";

            throw new BusinessException($"Prelaz iz statusa \"{order.Status}\" u status \"{newStatus}\" nije dozvoljen - {allowedText}.");
        }

        if (newStatus == OrderStatus.Cancelled && string.IsNullOrWhiteSpace(dto.CancellationReason))
        {
            throw new ValidationException(nameof(dto.CancellationReason), "Razlog otkazivanja je obavezan.");
        }

        var hasCompletedPayment = order.Payments.Any(p => p.Status == PaymentStatus.Completed && p.RefundedAmount < p.Amount);
        if (newStatus == OrderStatus.Cancelled && hasCompletedPayment)
        {
            throw new BusinessException(
                "Placenu narudzbu nije moguce otkazati direktno. Prvo izvrsite povrat sredstava kroz evidenciju placanja.");
        }

        // Potvrda narudzbe smije uslijediti samo nakon stvarno evidentiranog placanja
        // (PaymentsController.Confirm), nikada direktno preko ovog opsteg endpointa.
        if (newStatus == OrderStatus.Confirmed)
        {
            if (!_currentUserService.IsStaffOrAdmin)
            {
                throw new ForbiddenAccessException("Narudzbu moze potvrditi samo osoblje, nakon evidentiranog placanja.");
            }

            if (!hasCompletedPayment)
            {
                throw new BusinessException("Narudzba se ne moze potvrditi bez evidentiranog placanja.");
            }
        }

        await _unitOfWork.BeginTransactionAsync(cancellationToken);
        try
        {
            order.Status = newStatus;
            order.StatusChangedByUserId = actingUserId;

            switch (newStatus)
            {
                case OrderStatus.Confirmed:
                    order.ConfirmedAt = DateTime.UtcNow;
                    ActivateTickets(order);
                    break;

                case OrderStatus.Cancelled:
                    order.CancelledAt = DateTime.UtcNow;
                    order.CancellationReason = dto.CancellationReason?.Trim();
                    CancelTickets(order);
                    break;
            }

            await _context.SaveChangesAsync(cancellationToken);

            _context.Notifications.Add(new Notification
            {
                UserId = order.UserId,
                Title = $"Narudzba {order.OrderNumber}",
                Message = newStatus == OrderStatus.Cancelled
                    ? $"Narudzba je otkazana. Razlog: {order.CancellationReason}"
                    : $"Status narudzbe je promijenjen u \"{newStatus}\".",
                Type = newStatus == OrderStatus.Cancelled ? NotificationType.OrderCancelled : NotificationType.OrderConfirmed,
                TargetRoute = $"/orders/{order.Id}"
            });
            await _context.SaveChangesAsync(cancellationToken);

            await _unitOfWork.CommitTransactionAsync(cancellationToken);

            _logger.LogInformation("Narudzba {OrderId} je prebacena u status {Status}.", id, newStatus);
            return await GetByIdAsync(id, cancellationToken);
        }
        catch
        {
            await _unitOfWork.RollbackTransactionAsync(cancellationToken);
            throw;
        }
    }

    public async Task DeleteAsync(int id, CancellationToken cancellationToken = default)
    {
        var order = await _context.SkiPassOrders
            .Include(o => o.Tickets.Where(t => !t.IsDeleted))
            .Include(o => o.Payments.Where(p => !p.IsDeleted))
            .FirstOrDefaultAsync(o => o.Id == id && !o.IsDeleted, cancellationToken)
            ?? throw NotFoundException.For(EntityName, id);

        if (order.Payments.Any(p => p.Status is PaymentStatus.Completed or PaymentStatus.PartiallyRefunded))
        {
            throw new BusinessException("Narudzba sa evidentiranim placanjem se ne moze obrisati jer predstavlja finansijski zapis.");
        }

        var validationCount = await _context.TicketValidations
            .CountAsync(v => v.SkiPassTicket.SkiPassOrderId == id && !v.IsDeleted, cancellationToken);
        if (validationCount > 0)
        {
            throw new ReferencedEntityException(EntityName, "Validacije karata", validationCount);
        }

        // Soft delete postuje FK redoslijed: prvo karte, zatim narudzba.
        foreach (var ticket in order.Tickets)
        {
            ticket.IsDeleted = true;
        }

        order.IsDeleted = true;
        await _context.SaveChangesAsync(cancellationToken);

        _logger.LogInformation("Obrisana narudzba {OrderId}.", id);
    }

    private IQueryable<SkiPassOrder> BaseQuery() =>
        _context.SkiPassOrders
            .Include(o => o.User)
            .Include(o => o.PaymentMethod)
            .Include(o => o.StatusChangedByUser)
            .Include(o => o.Tickets.Where(t => !t.IsDeleted))
            .Include(o => o.Payments.Where(p => !p.IsDeleted))
                .ThenInclude(p => p.PaymentMethod);

    /// <summary>Cijena karte: cijena po danu puta broj dana, umanjena za popust tipa karte.</summary>
    private static decimal CalculateTicketPrice(TicketType ticketType, int numberOfDays)
    {
        var gross = ticketType.PricePerDay * numberOfDays;
        var net = gross * (1 - ticketType.DiscountPercentage / 100m);
        return Math.Round(net, 2, MidpointRounding.AwayFromZero);
    }

    private static void ActivateTickets(SkiPassOrder order)
    {
        foreach (var ticket in order.Tickets.Where(t => TicketStatusRules.CanTransition(t.Status, TicketStatus.Active)))
        {
            ticket.Status = TicketStatus.Active;
            ticket.ActivatedAt = DateTime.UtcNow;
        }
    }

    private static void CancelTickets(SkiPassOrder order)
    {
        foreach (var ticket in order.Tickets.Where(t => TicketStatusRules.CanTransition(t.Status, TicketStatus.Cancelled)))
        {
            ticket.Status = TicketStatus.Cancelled;
            ticket.CancelledAt = DateTime.UtcNow;
        }
    }

    private async Task<string> CreateUniqueOrderNumberAsync(CancellationToken cancellationToken)
    {
        for (var attempt = 0; attempt < 5; attempt++)
        {
            var candidate = SecureCodeGenerator.CreateOrderNumber(DateTime.UtcNow);
            if (!await _context.SkiPassOrders.AnyAsync(o => o.OrderNumber == candidate, cancellationToken))
            {
                return candidate;
            }
        }

        throw new BusinessException("Generisanje broja narudzbe nije uspjelo. Molimo pokusajte ponovo.");
    }

    private async Task<string> CreateUniqueQrCodeAsync(CancellationToken cancellationToken)
    {
        for (var attempt = 0; attempt < 5; attempt++)
        {
            var candidate = SecureCodeGenerator.CreateQrCode();
            if (!await _context.SkiPassTickets.AnyAsync(t => t.QrCode == candidate, cancellationToken))
            {
                return candidate;
            }
        }

        throw new BusinessException("Generisanje QR koda nije uspjelo. Molimo pokusajte ponovo.");
    }

    private static OrderStatus ParseStatus(string value, string field)
    {
        if (!Enum.TryParse<OrderStatus>(value, ignoreCase: true, out var parsed) || !Enum.IsDefined(parsed))
        {
            throw new ValidationException(
                field,
                $"Nepoznat status \"{value}\". Dozvoljene vrijednosti su: {string.Join(", ", Enum.GetNames<OrderStatus>())}.");
        }

        return parsed;
    }

    private static SkiPassOrderDto MapSummary(SkiPassOrder e) => Fill(new SkiPassOrderDto(), e);

    private static SkiPassOrderDetailsDto MapDetails(SkiPassOrder e)
    {
        var dto = Fill(new SkiPassOrderDetailsDto(), e);

        dto.Tickets = e.Tickets
            .Where(t => !t.IsDeleted)
            .OrderBy(t => t.ValidFrom)
            .Select(t => new SkiPassTicketDto
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
                OrderNumber = e.OrderNumber,
                OrderStatus = e.Status.ToString(),
                PaymentMethodId = e.PaymentMethodId,
                PaymentMethodName = e.PaymentMethod.Name,
                TicketTypeId = t.TicketTypeId,
                TicketTypeName = t.TicketType.Name,
                SkiResortId = t.TicketType.SkiResortId,
                SkiResortName = t.TicketType.SkiResort.Name,
                ValidationCount = t.Validations.Count(v => !v.IsDeleted && v.IsSuccessful),
                LastValidatedAt = t.Validations
                    .Where(v => !v.IsDeleted && v.IsSuccessful)
                    .Select(v => (DateTime?)v.ValidatedAt)
                    .Max()
            })
            .ToList();

        dto.Payments = e.Payments
            .Where(p => !p.IsDeleted)
            .OrderByDescending(p => p.CreatedAt)
            .Select(p => new PaymentSummaryDto
            {
                Id = p.Id,
                Amount = p.Amount,
                Currency = p.Currency,
                Status = p.Status.ToString(),
                PaymentMethodName = p.PaymentMethod.Name,
                PaidAt = p.PaidAt,
                RefundedAmount = p.RefundedAmount,
                RefundedAt = p.RefundedAt
            })
            .ToList();

        return dto;
    }

    private static T Fill<T>(T dto, SkiPassOrder e) where T : SkiPassOrderDto
    {
        var activePayments = e.Payments.Where(p => !p.IsDeleted).ToList();

        dto.Id = e.Id;
        dto.OrderNumber = e.OrderNumber;
        dto.OrderDate = e.OrderDate;
        dto.TotalAmount = e.TotalAmount;
        dto.Status = e.Status.ToString();
        dto.Note = e.Note;
        dto.ConfirmedAt = e.ConfirmedAt;
        dto.CancelledAt = e.CancelledAt;
        dto.CancellationReason = e.CancellationReason;
        dto.StatusChangedByUserName = e.StatusChangedByUser == null
            ? null
            : $"{e.StatusChangedByUser.FirstName} {e.StatusChangedByUser.LastName}";
        dto.UserId = e.UserId;
        dto.UserFullName = $"{e.User.FirstName} {e.User.LastName}";
        dto.UserEmail = e.User.Email;
        dto.PaymentMethodId = e.PaymentMethodId;
        dto.PaymentMethodName = e.PaymentMethod.Name;
        dto.TicketCount = e.Tickets.Count(t => !t.IsDeleted);
        dto.PaidAmount = activePayments.Where(p => p.Status == PaymentStatus.Completed).Sum(p => p.Amount);
        dto.RefundedAmount = activePayments.Sum(p => p.RefundedAmount);
        dto.IsPaid = dto.PaidAmount - dto.RefundedAmount >= e.TotalAmount && e.TotalAmount > 0;
        dto.AllowedNextStatuses = OrderStatusRules.GetAllowedTransitions(e.Status).Select(s => s.ToString()).ToList();

        return dto;
    }
}
