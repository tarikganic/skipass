using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using SkiPass.Application.Common;
using SkiPass.Application.DTOs.Tickets;
using SkiPass.Application.Services.Interfaces;
using SkiPass.Domain.Constants;

namespace SkiPass.API.Controllers;

[ApiController]
[Route("api/[controller]")]
[Authorize]
[Produces("application/json")]
public class TicketsController : ControllerBase
{
    private readonly ISkiPassTicketService _ticketService;
    private readonly ICurrentUserService _currentUserService;

    public TicketsController(ISkiPassTicketService ticketService, ICurrentUserService currentUserService)
    {
        _ticketService = ticketService;
        _currentUserService = currentUserService;
    }

    [HttpGet]
    public async Task<ActionResult<PagedResult<SkiPassTicketDto>>> Search(
        [FromQuery] SkiPassTicketSearchDto request,
        CancellationToken cancellationToken) =>
        Ok(await _ticketService.SearchAsync(request, cancellationToken));

    [HttpGet("{id:int}")]
    public async Task<ActionResult<SkiPassTicketDto>> GetById(int id, CancellationToken cancellationToken) =>
        Ok(await _ticketService.GetByIdAsync(id, cancellationToken));

    /// <summary>
    /// Validacija QR koda karte na ulazu na ski lift. Dostupno samo osoblju skijalista.
    /// </summary>
    [HttpPost("validate")]
    [Authorize(Roles = Roles.StaffOrAdmin)]
    public async Task<ActionResult<TicketValidationDto>> Validate(
        [FromBody] TicketValidationRequestDto dto,
        CancellationToken cancellationToken)
    {
        var userId = _currentUserService.GetRequiredUserId();
        var result = await _ticketService.ValidateAsync(dto, userId, cancellationToken);

        return result.IsSuccessful
            ? Ok(result)
            : Conflict(new { message = result.FailureReason, validation = result });
    }

    /// <summary>Historija skeniranja karata na liftovima.</summary>
    [HttpGet("validations")]
    [Authorize(Roles = Roles.StaffOrAdmin)]
    public async Task<ActionResult<PagedResult<TicketValidationDto>>> SearchValidations(
        [FromQuery] TicketValidationSearchDto request,
        CancellationToken cancellationToken) =>
        Ok(await _ticketService.SearchValidationsAsync(request, cancellationToken));
}
