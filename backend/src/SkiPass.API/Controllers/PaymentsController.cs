using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using SkiPass.Application.Common;
using SkiPass.Application.DTOs.Payments;
using SkiPass.Application.Services.Interfaces;
using SkiPass.Domain.Constants;

namespace SkiPass.API.Controllers;

[ApiController]
[Route("api/[controller]")]
[Authorize]
[Produces("application/json")]
public class PaymentsController : ControllerBase
{
    private readonly IPaymentService _paymentService;
    private readonly ICurrentUserService _currentUserService;

    public PaymentsController(IPaymentService paymentService, ICurrentUserService currentUserService)
    {
        _paymentService = paymentService;
        _currentUserService = currentUserService;
    }

    [HttpGet]
    public async Task<ActionResult<PagedResult<PaymentDto>>> Search(
        [FromQuery] PaymentSearchDto request,
        CancellationToken cancellationToken) =>
        Ok(await _paymentService.SearchAsync(request, cancellationToken));

    [HttpGet("{id:int}")]
    public async Task<ActionResult<PaymentDto>> GetById(int id, CancellationToken cancellationToken) =>
        Ok(await _paymentService.GetByIdAsync(id, cancellationToken));

    /// <summary>
    /// Zapocinje placanje narudzbe. Iznos odredjuje server iz narudzbe -
    /// klijent nikada ne salje cijenu.
    /// </summary>
    [HttpPost]
    public async Task<ActionResult<PaymentDto>> Initiate([FromBody] PaymentCreateDto dto, CancellationToken cancellationToken)
    {
        var userId = _currentUserService.GetRequiredUserId();
        var created = await _paymentService.InitiateAsync(dto, userId, cancellationToken);
        return CreatedAtAction(nameof(GetById), new { id = created.Id }, created);
    }

    /// <summary>
    /// Serverska finalizacija placanja. Operacija je idempotentna: ponovni poziv nad
    /// vec zavrsenim placanjem ne mijenja stanje sistema.
    /// </summary>
    [HttpPost("{id:int}/confirm")]
    [Authorize(Roles = Roles.StaffOrAdmin)]
    public async Task<ActionResult<PaymentDto>> Confirm(int id, [FromBody] PaymentConfirmDto dto, CancellationToken cancellationToken) =>
        Ok(await _paymentService.ConfirmAsync(id, dto, cancellationToken));

    /// <summary>Povrat sredstava na osnovu stvarno naplacenog iznosa.</summary>
    [HttpPost("{id:int}/refund")]
    [Authorize(Roles = Roles.Admin)]
    public async Task<ActionResult<PaymentDto>> Refund(int id, [FromBody] PaymentRefundDto dto, CancellationToken cancellationToken) =>
        Ok(await _paymentService.RefundAsync(id, dto, cancellationToken));

    /// <summary>
    /// Stripe poziva ovu rutu direktno (server-to-server), bez JWT tokena - zato je anonimna,
    /// a autentifikacija zahtjeva se svodi na provjeru Stripe-ovog potpisa (Stripe:WebhookSecret)
    /// unutar PaymentService.HandleStripeWebhookAsync. Ovo je jedino mjesto gdje se online
    /// placanje stvarno finalizira; klijent to nikad ne moze uraditi preko API-ja.
    /// </summary>
    [HttpPost("webhook/stripe")]
    [AllowAnonymous]
    public async Task<IActionResult> StripeWebhook(CancellationToken cancellationToken)
    {
        using var reader = new StreamReader(Request.Body);
        var json = await reader.ReadToEndAsync(cancellationToken);

        await _paymentService.HandleStripeWebhookAsync(json, Request.Headers["Stripe-Signature"]!, cancellationToken);
        return Ok();
    }
}
