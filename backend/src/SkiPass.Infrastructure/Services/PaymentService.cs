using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;
using SkiPass.Application.Common;
using SkiPass.Application.DTOs.Payments;
using SkiPass.Application.Exceptions;
using SkiPass.Application.Services.Interfaces;
using SkiPass.Domain.Entities;
using SkiPass.Domain.Enums;
using SkiPass.Domain.Interfaces;
using SkiPass.Domain.Rules;
using SkiPass.Infrastructure.Data;
using Stripe;

namespace SkiPass.Infrastructure.Services;

/// <summary>
/// Evidencija placanja narudzbi. Iznos i finalizacija se uvijek odredjuju na serveru;
/// klijent nikada ne salje cijenu niti sam evidentira uspjesno placanje.
///
/// Online placanje ide preko Stripe-a (test/sandbox nalog): InitiateAsync otvara
/// PaymentIntent i vraca client secret koji mobilna aplikacija koristi sa Stripe
/// PaymentSheet-om, a finalizacija se desava iskljucivo preko HandleStripeWebhookAsync -
/// klijent nikada ne moze sam sebi oznaciti placanje kao uspjesno.
/// </summary>
public class PaymentService : IPaymentService
{
    private const string EntityName = "Placanje";

    /// <summary>
    /// BAM je fiksno vezan za EUR preko valutnog odbora (Currency Board) po ovom kursu -
    /// Stripe ne podrzava BAM direktno, pa se online placanja obradjuju u EUR.
    /// </summary>
    private const decimal BamToEurRate = 1.95583m;

    private readonly ApplicationDbContext _context;
    private readonly ICurrentUserService _currentUserService;
    private readonly IUnitOfWork _unitOfWork;
    private readonly IConfiguration _configuration;
    private readonly ILogger<PaymentService> _logger;

    public PaymentService(
        ApplicationDbContext context,
        ICurrentUserService currentUserService,
        IUnitOfWork unitOfWork,
        IConfiguration configuration,
        ILogger<PaymentService> logger)
    {
        _context = context;
        _currentUserService = currentUserService;
        _unitOfWork = unitOfWork;
        _configuration = configuration;
        _logger = logger;
    }

    public async Task<PagedResult<PaymentDto>> SearchAsync(PaymentSearchDto request, CancellationToken cancellationToken = default)
    {
        var query = BaseQuery().Where(p => !p.IsDeleted);

        if (!_currentUserService.IsStaffOrAdmin)
        {
            var currentUserId = _currentUserService.GetRequiredUserId();
            query = query.Where(p => p.SkiPassOrder.UserId == currentUserId);
        }
        else if (request.UserId.HasValue)
        {
            query = query.Where(p => p.SkiPassOrder.UserId == request.UserId.Value);
        }

        if (!string.IsNullOrWhiteSpace(request.Query))
        {
            var term = request.Query.Trim();
            query = query.Where(p =>
                p.SkiPassOrder.OrderNumber.Contains(term) ||
                (p.TransactionId != null && p.TransactionId.Contains(term)) ||
                p.SkiPassOrder.User.FirstName.Contains(term) ||
                p.SkiPassOrder.User.LastName.Contains(term));
        }

        if (request.SkiPassOrderId.HasValue)
        {
            query = query.Where(p => p.SkiPassOrderId == request.SkiPassOrderId.Value);
        }

        if (request.PaymentMethodId.HasValue)
        {
            query = query.Where(p => p.PaymentMethodId == request.PaymentMethodId.Value);
        }

        if (!string.IsNullOrWhiteSpace(request.Status))
        {
            var status = ParseStatus(request.Status, nameof(request.Status));
            query = query.Where(p => p.Status == status);
        }

        if (request.PaidFrom.HasValue)
        {
            query = query.Where(p => p.PaidAt >= request.PaidFrom.Value);
        }

        if (request.PaidTo.HasValue)
        {
            query = query.Where(p => p.PaidAt <= request.PaidTo.Value);
        }

        var totalCount = await query.CountAsync(cancellationToken);

        var entities = await query
            .OrderByDescending(p => p.CreatedAt)
            .Skip((request.Page - 1) * request.PageSize)
            .Take(request.PageSize)
            .AsNoTracking()
            .ToListAsync(cancellationToken);

        return entities.Select(MapToDto).ToList().ToPagedResult(totalCount, request);
    }

    public async Task<PaymentDto> GetByIdAsync(int id, CancellationToken cancellationToken = default)
    {
        var entity = await BaseQuery()
            .AsNoTracking()
            .FirstOrDefaultAsync(p => p.Id == id && !p.IsDeleted, cancellationToken)
            ?? throw NotFoundException.For(EntityName, id);

        _currentUserService.EnsureCanAccessUser(entity.SkiPassOrder.UserId);

        return MapToDto(entity);
    }

    public async Task<PaymentDto> InitiateAsync(PaymentCreateDto dto, int userId, CancellationToken cancellationToken = default)
    {
        var order = await _context.SkiPassOrders
            .Include(o => o.Payments.Where(p => !p.IsDeleted))
            .FirstOrDefaultAsync(o => o.Id == dto.SkiPassOrderId && !o.IsDeleted, cancellationToken)
            ?? throw NotFoundException.For("Narudzba", dto.SkiPassOrderId);

        _currentUserService.EnsureCanAccessUser(order.UserId);

        if (!OrderStatusRules.IsOpen(order.Status))
        {
            throw new BusinessException($"Narudzba u statusu \"{order.Status}\" se vise ne moze platiti.");
        }

        // Sprjecava dvostruko placanje iste narudzbe.
        var existing = order.Payments.FirstOrDefault(p =>
            p.Status is PaymentStatus.Pending or PaymentStatus.Completed);

        if (existing is not null)
        {
            throw new BusinessException(existing.Status == PaymentStatus.Completed
                ? "Narudzba je vec placena."
                : "Za ovu narudzbu vec postoji zapoceto placanje. Zavrsite ga ili sacekajte da istekne.");
        }

        var paymentMethod = await _context.PaymentMethods
            .FirstOrDefaultAsync(p => p.Id == dto.PaymentMethodId && !p.IsDeleted && p.IsActive, cancellationToken)
            ?? throw new ValidationException(nameof(dto.PaymentMethodId), "Odabrani nacin placanja nije dostupan.");

        var payment = new Payment
        {
            // Iznos dolazi iz narudzbe, ne od klijenta.
            Amount = order.TotalAmount,
            Currency = "BAM",
            Status = PaymentStatus.Pending,
            SkiPassOrderId = order.Id,
            PaymentMethodId = paymentMethod.Id
        };

        _context.Payments.Add(payment);
        await _context.SaveChangesAsync(cancellationToken);

        string? stripeClientSecret = null;

        if (paymentMethod.IsOnline)
        {
            var intent = await CreateStripePaymentIntentAsync(payment, order, cancellationToken);

            // Client secret se ne cuva u bazi (jednokratno vazi za ovaj PaymentIntent), ali
            // PaymentIntent Id se cuva odmah - webhook kasnije pronalazi placanje preko njega.
            payment.TransactionId = intent.Id;
            await _context.SaveChangesAsync(cancellationToken);

            stripeClientSecret = intent.ClientSecret;
        }

        _logger.LogInformation(
            "Zapoceto placanje {PaymentId} za narudzbu {OrderId} u iznosu {Amount} (online: {IsOnline}).",
            payment.Id, order.Id, payment.Amount, paymentMethod.IsOnline);

        var resultDto = await GetByIdAsync(payment.Id, cancellationToken);
        resultDto.StripeClientSecret = stripeClientSecret;
        resultDto.StripePublishableKey = stripeClientSecret is null ? null : _configuration["Stripe:PublishableKey"];
        return resultDto;
    }

    /// <summary>Otvara Stripe PaymentIntent za jedno placanje. Iznos se preracunava iz BAM u EUR.</summary>
    private async Task<PaymentIntent> CreateStripePaymentIntentAsync(Payment payment, SkiPassOrder order, CancellationToken cancellationToken)
    {
        var client = CreateStripeClient();
        var service = new PaymentIntentService(client);

        var options = new PaymentIntentCreateOptions
        {
            Amount = ToStripeMinorUnits(payment.Amount),
            Currency = "eur",
            AutomaticPaymentMethods = new PaymentIntentAutomaticPaymentMethodsOptions { Enabled = true },
            Description = $"SkiPass narudzba {order.OrderNumber}",
            Metadata = new Dictionary<string, string>
            {
                ["paymentId"] = payment.Id.ToString(),
                ["orderId"] = order.Id.ToString(),
                ["orderNumber"] = order.OrderNumber
            }
        };

        // Idempotencijski kljuc sprjecava da ponovljen zahtjev (npr. retry na mrezni tajmaut)
        // otvori dva PaymentIntent-a za isto placanje.
        var requestOptions = new RequestOptions { IdempotencyKey = $"payment-initiate-{payment.Id}" };

        try
        {
            return await service.CreateAsync(options, requestOptions, cancellationToken);
        }
        catch (StripeException ex)
        {
            _logger.LogError(ex, "Otvaranje Stripe PaymentIntent-a za placanje {PaymentId} nije uspjelo.", payment.Id);
            throw new BusinessException($"Placanje trenutno nije moguce pokrenuti: {ex.StripeError?.Message ?? ex.Message}");
        }
    }

    /// <summary>
    /// Finalizacija placanja na serverskoj strani. Idempotentna je: ponovni poziv nad
    /// vec zavrsenim placanjem ne ponavlja efekte, nego vraca postojece stanje.
    /// </summary>
    public async Task<PaymentDto> ConfirmAsync(int id, PaymentConfirmDto dto, CancellationToken cancellationToken = default)
    {
        var payment = await _context.Payments
            .Include(p => p.SkiPassOrder)
                .ThenInclude(o => o.Tickets.Where(t => !t.IsDeleted))
            .FirstOrDefaultAsync(p => p.Id == id && !p.IsDeleted, cancellationToken)
            ?? throw NotFoundException.For(EntityName, id);

        if (payment.Status == PaymentStatus.Completed)
        {
            _logger.LogInformation("Placanje {PaymentId} je vec zavrseno, zahtjev se ignorise.", id);
            return await GetByIdAsync(id, cancellationToken);
        }

        if (payment.Status is PaymentStatus.Refunded or PaymentStatus.PartiallyRefunded)
        {
            throw new BusinessException("Placanje sa izvrsenim povratom se ne moze ponovo potvrditi.");
        }

        var transactionId = dto.TransactionId.Trim();
        var transactionTaken = await _context.Payments
            .AnyAsync(p => p.Id != payment.Id && p.TransactionId == transactionId, cancellationToken);
        if (transactionTaken)
        {
            throw new ValidationException(nameof(dto.TransactionId), "Ovaj identifikator transakcije je vec evidentiran.");
        }

        await CompletePaymentAsync(payment, transactionId, cancellationToken);
        return await GetByIdAsync(id, cancellationToken);
    }

    /// <summary>
    /// Stvarna finalizacija placanja od strane Stripe-a, primljena preko webhook-a
    /// (POST /api/Payments/webhook/stripe). Ovo je jedino mjesto gdje online placanje
    /// prelazi u Completed - klijent to nikada ne moze uraditi sam preko API-ja.
    /// Potpis zahtjeva se provjerava ovdje pomocu Stripe:WebhookSecret prije bilo kakve obrade.
    /// </summary>
    public async Task HandleStripeWebhookAsync(string jsonPayload, string stripeSignatureHeader, CancellationToken cancellationToken = default)
    {
        var webhookSecret = _configuration["Stripe:WebhookSecret"]!;

        Event stripeEvent;
        try
        {
            stripeEvent = EventUtility.ConstructEvent(jsonPayload, stripeSignatureHeader, webhookSecret);
        }
        catch (StripeException ex)
        {
            _logger.LogWarning(ex, "Stripe webhook potpis nije validan - zahtjev je odbijen.");
            throw new ValidationException("Signature", "Potpis Stripe webhook zahtjeva nije ispravan.");
        }

        switch (stripeEvent.Type)
        {
            case "payment_intent.succeeded":
            {
                var intent = (PaymentIntent)stripeEvent.Data.Object;
                var payment = await _context.Payments
                    .Include(p => p.SkiPassOrder)
                        .ThenInclude(o => o.Tickets.Where(t => !t.IsDeleted))
                    .FirstOrDefaultAsync(p => p.TransactionId == intent.Id && !p.IsDeleted, cancellationToken);

                if (payment is null)
                {
                    _logger.LogWarning("Stripe webhook: nema placanja za PaymentIntent {PaymentIntentId}.", intent.Id);
                    return;
                }

                await CompletePaymentAsync(payment, intent.Id, cancellationToken);
                break;
            }

            case "payment_intent.payment_failed":
            {
                var intent = (PaymentIntent)stripeEvent.Data.Object;
                var payment = await _context.Payments
                    .FirstOrDefaultAsync(p => p.TransactionId == intent.Id && !p.IsDeleted, cancellationToken);

                if (payment is null || payment.Status == PaymentStatus.Completed)
                {
                    break;
                }

                payment.Status = PaymentStatus.Failed;
                payment.FailureReason = intent.LastPaymentError?.Message ?? "Stripe je odbio placanje.";
                await _context.SaveChangesAsync(cancellationToken);

                _logger.LogWarning("Placanje {PaymentId} je neuspjesno: {Reason}", payment.Id, payment.FailureReason);
                break;
            }

            default:
                _logger.LogInformation("Stripe webhook dogadjaj {EventType} nije obradjen (nije relevantan).", stripeEvent.Type);
                break;
        }
    }

    /// <summary>
    /// Zajednicka logika finalizacije placanja - koriste je i rucna potvrda od strane
    /// osoblja (ConfirmAsync) i Stripe webhook (HandleStripeWebhookAsync). Idempotentna je:
    /// ponovni poziv nad vec zavrsenim placanjem ne ponavlja efekte.
    /// </summary>
    private async Task CompletePaymentAsync(Payment payment, string transactionId, CancellationToken cancellationToken)
    {
        if (payment.Status == PaymentStatus.Completed)
        {
            _logger.LogInformation("Placanje {PaymentId} je vec zavrseno, zahtjev se ignorise.", payment.Id);
            return;
        }

        if (payment.Status is PaymentStatus.Refunded or PaymentStatus.PartiallyRefunded)
        {
            throw new BusinessException("Placanje sa izvrsenim povratom se ne moze ponovo potvrditi.");
        }

        await _unitOfWork.BeginTransactionAsync(cancellationToken);
        try
        {
            payment.Status = PaymentStatus.Completed;
            payment.TransactionId = transactionId;
            payment.PaidAt = DateTime.UtcNow;
            payment.FailureReason = null;

            var order = payment.SkiPassOrder;
            if (OrderStatusRules.CanTransition(order.Status, OrderStatus.Confirmed))
            {
                order.Status = OrderStatus.Confirmed;
                order.ConfirmedAt = DateTime.UtcNow;

                foreach (var ticket in order.Tickets.Where(t => TicketStatusRules.CanTransition(t.Status, TicketStatus.Active)))
                {
                    ticket.Status = TicketStatus.Active;
                    ticket.ActivatedAt = DateTime.UtcNow;
                }
            }

            await _context.SaveChangesAsync(cancellationToken);

            _context.Notifications.Add(new Notification
            {
                UserId = order.UserId,
                Title = "Placanje je uspjesno",
                Message = $"Placanje narudzbe {order.OrderNumber} u iznosu {payment.Amount:0.00} {payment.Currency} je evidentirano. Karte su aktivne.",
                Type = NotificationType.PaymentCompleted,
                TargetRoute = $"/orders/{order.Id}"
            });
            await _context.SaveChangesAsync(cancellationToken);

            await _unitOfWork.CommitTransactionAsync(cancellationToken);

            _logger.LogInformation("Placanje {PaymentId} je zavrseno, narudzba {OrderId} je potvrdjena.", payment.Id, order.Id);
        }
        catch
        {
            await _unitOfWork.RollbackTransactionAsync(cancellationToken);
            throw;
        }
    }

    /// <summary>Povrat se racuna iz stvarno naplacenog iznosa, a ne iz kalkulisane cijene narudzbe.</summary>
    public async Task<PaymentDto> RefundAsync(int id, PaymentRefundDto dto, CancellationToken cancellationToken = default)
    {
        var payment = await _context.Payments
            .Include(p => p.SkiPassOrder)
                .ThenInclude(o => o.Tickets.Where(t => !t.IsDeleted))
            .FirstOrDefaultAsync(p => p.Id == id && !p.IsDeleted, cancellationToken)
            ?? throw NotFoundException.For(EntityName, id);

        if (payment.Status is not (PaymentStatus.Completed or PaymentStatus.PartiallyRefunded))
        {
            throw new BusinessException($"Povrat je moguc samo za zavrseno placanje. Trenutni status je \"{payment.Status}\".");
        }

        var refundable = payment.Amount - payment.RefundedAmount;
        if (refundable <= 0)
        {
            throw new BusinessException("Cjelokupan naplaceni iznos je vec vracen.");
        }

        var amount = dto.Amount ?? refundable;
        if (amount > refundable)
        {
            throw new ValidationException(
                nameof(dto.Amount),
                $"Iznos povrata ne moze biti veci od preostalog naplacenog iznosa ({refundable:0.00} {payment.Currency}).");
        }

        // Placanja obradjena preko Stripe-a imaju PaymentIntent Id kao TransactionId (prefiks "pi_").
        // Povrat se prvo stvarno izvrsava kod Stripe-a - lokalni zapis se azurira tek ako to uspije,
        // kako se u bazi nikad ne bi evidentirao povrat koji se stvarno nije desio.
        if (payment.TransactionId is { } transactionId && transactionId.StartsWith("pi_", StringComparison.Ordinal))
        {
            await CreateStripeRefundAsync(payment, transactionId, amount, cancellationToken);
        }

        await _unitOfWork.BeginTransactionAsync(cancellationToken);
        try
        {
            payment.RefundedAmount += amount;
            payment.RefundedAt = DateTime.UtcNow;
            payment.Status = payment.RefundedAmount >= payment.Amount
                ? PaymentStatus.Refunded
                : PaymentStatus.PartiallyRefunded;

            var order = payment.SkiPassOrder;

            // Puni povrat otkazuje narudzbu i sve njene karte.
            if (payment.Status == PaymentStatus.Refunded && OrderStatusRules.CanTransition(order.Status, OrderStatus.Cancelled))
            {
                order.Status = OrderStatus.Cancelled;
                order.CancelledAt = DateTime.UtcNow;
                order.CancellationReason = dto.Reason.Trim();

                foreach (var ticket in order.Tickets.Where(t => TicketStatusRules.CanTransition(t.Status, TicketStatus.Cancelled)))
                {
                    ticket.Status = TicketStatus.Cancelled;
                    ticket.CancelledAt = DateTime.UtcNow;
                }
            }

            await _context.SaveChangesAsync(cancellationToken);

            _context.Notifications.Add(new Notification
            {
                UserId = order.UserId,
                Title = "Povrat sredstava",
                Message = $"Za narudzbu {order.OrderNumber} evidentiran je povrat od {amount:0.00} {payment.Currency}. Razlog: {dto.Reason.Trim()}",
                Type = NotificationType.PaymentRefunded,
                TargetRoute = $"/orders/{order.Id}"
            });
            await _context.SaveChangesAsync(cancellationToken);

            await _unitOfWork.CommitTransactionAsync(cancellationToken);

            _logger.LogInformation("Evidentiran povrat {Amount} za placanje {PaymentId}.", amount, id);
            return await GetByIdAsync(id, cancellationToken);
        }
        catch
        {
            await _unitOfWork.RollbackTransactionAsync(cancellationToken);
            throw;
        }
    }

    private async Task CreateStripeRefundAsync(Payment payment, string paymentIntentId, decimal amount, CancellationToken cancellationToken)
    {
        var client = CreateStripeClient();
        var service = new RefundService(client);

        var options = new RefundCreateOptions
        {
            PaymentIntent = paymentIntentId,
            Amount = ToStripeMinorUnits(amount)
        };

        var requestOptions = new RequestOptions { IdempotencyKey = $"payment-refund-{payment.Id}-{amount:0.00}" };

        try
        {
            await service.CreateAsync(options, requestOptions, cancellationToken);
        }
        catch (StripeException ex)
        {
            _logger.LogError(ex, "Stripe povrat za placanje {PaymentId} nije uspio.", payment.Id);
            throw new BusinessException($"Povrat sredstava nije uspio kod Stripe-a: {ex.StripeError?.Message ?? ex.Message}");
        }
    }

    private StripeClient CreateStripeClient()
    {
        var secretKey = _configuration["Stripe:SecretKey"];
        if (string.IsNullOrWhiteSpace(secretKey))
        {
            throw new InvalidOperationException("Stripe:SecretKey nije konfigurisan (STRIPE_SECRET_KEY u .env).");
        }

        return new StripeClient(secretKey);
    }

    /// <summary>BAM iznos u najmanju jedinicu EUR-a (centi) za Stripe API, preko fiksnog kursa valutnog odbora.</summary>
    private static long ToStripeMinorUnits(decimal bamAmount) =>
        (long)Math.Round(bamAmount / BamToEurRate * 100m, MidpointRounding.AwayFromZero);

    private IQueryable<Payment> BaseQuery() =>
        _context.Payments
            .Include(p => p.PaymentMethod)
            .Include(p => p.SkiPassOrder)
                .ThenInclude(o => o.User);

    private static PaymentDto MapToDto(Payment e) => new()
    {
        Id = e.Id,
        Amount = e.Amount,
        Currency = e.Currency,
        Status = e.Status.ToString(),
        TransactionId = e.TransactionId,
        PaidAt = e.PaidAt,
        RefundedAmount = e.RefundedAmount,
        RefundedAt = e.RefundedAt,
        FailureReason = e.FailureReason,
        SkiPassOrderId = e.SkiPassOrderId,
        OrderNumber = e.SkiPassOrder.OrderNumber,
        PaymentMethodId = e.PaymentMethodId,
        PaymentMethodName = e.PaymentMethod.Name,
        UserId = e.SkiPassOrder.UserId,
        UserFullName = $"{e.SkiPassOrder.User.FirstName} {e.SkiPassOrder.User.LastName}",
        CreatedAt = e.CreatedAt
    };

    private static PaymentStatus ParseStatus(string value, string field)
    {
        if (!Enum.TryParse<PaymentStatus>(value, ignoreCase: true, out var parsed) || !Enum.IsDefined(parsed))
        {
            throw new ValidationException(
                field,
                $"Nepoznat status \"{value}\". Dozvoljene vrijednosti su: {string.Join(", ", Enum.GetNames<PaymentStatus>())}.");
        }

        return parsed;
    }
}
