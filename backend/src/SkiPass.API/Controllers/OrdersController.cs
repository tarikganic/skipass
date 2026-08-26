using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using SkiPass.Application.Common;
using SkiPass.Application.DTOs.Orders;
using SkiPass.Application.DTOs.Tickets;
using SkiPass.Application.Services.Interfaces;
using SkiPass.Domain.Constants;

namespace SkiPass.API.Controllers;

[ApiController]
[Route("api/[controller]")]
[Authorize]
[Produces("application/json")]
public class OrdersController : ControllerBase
{
    private readonly ISkiPassOrderService _orderService;
    private readonly ISkiPassTicketService _ticketService;
    private readonly ICurrentUserService _currentUserService;

    public OrdersController(
        ISkiPassOrderService orderService,
        ISkiPassTicketService ticketService,
        ICurrentUserService currentUserService)
    {
        _orderService = orderService;
        _ticketService = ticketService;
        _currentUserService = currentUserService;
    }

    /// <summary>
    /// Pregled narudzbi. Skijas uvijek vidi samo vlastite narudzbe,
    /// dok osoblje i administratori vide sve.
    /// </summary>
    [HttpGet]
    public async Task<ActionResult<PagedResult<SkiPassOrderDto>>> Search(
        [FromQuery] SkiPassOrderSearchDto request,
        CancellationToken cancellationToken) =>
        Ok(await _orderService.SearchAsync(request, cancellationToken));

    [HttpGet("{id:int}")]
    public async Task<ActionResult<SkiPassOrderDetailsDto>> GetById(int id, CancellationToken cancellationToken) =>
        Ok(await _orderService.GetByIdAsync(id, cancellationToken));

    /// <summary>Karte pojedinacne narudzbe - master-details prikaz.</summary>
    [HttpGet("{id:int}/tickets")]
    public async Task<ActionResult<PagedResult<SkiPassTicketDto>>> GetTickets(
        int id,
        [FromQuery] SkiPassTicketSearchDto request,
        CancellationToken cancellationToken)
    {
        request.SkiPassOrderId = id;
        return Ok(await _ticketService.SearchAsync(request, cancellationToken));
    }

    /// <summary>
    /// Kreiranje narudzbe za jednu ili vise karata. Identifikator korisnika se uvijek
    /// preuzima iz tokena, nikada iz tijela zahtjeva.
    /// </summary>
    [HttpPost]
    public async Task<ActionResult<SkiPassOrderDetailsDto>> Create(
        [FromBody] SkiPassOrderCreateDto dto,
        CancellationToken cancellationToken)
    {
        var userId = _currentUserService.GetRequiredUserId();
        var created = await _orderService.CreateAsync(dto, userId, cancellationToken);
        return CreatedAtAction(nameof(GetById), new { id = created.Id }, created);
    }

    /// <summary>Promjena statusa narudzbe uz provjeru dozvoljenih prelaza.</summary>
    [HttpPatch("{id:int}/status")]
    public async Task<ActionResult<SkiPassOrderDetailsDto>> UpdateStatus(
        int id,
        [FromBody] SkiPassOrderStatusUpdateDto dto,
        CancellationToken cancellationToken)
    {
        var userId = _currentUserService.GetRequiredUserId();
        return Ok(await _orderService.UpdateStatusAsync(id, dto, userId, cancellationToken));
    }

    [HttpDelete("{id:int}")]
    [Authorize(Roles = Roles.Admin)]
    public async Task<IActionResult> Delete(int id, CancellationToken cancellationToken)
    {
        await _orderService.DeleteAsync(id, cancellationToken);
        return Ok(new { message = "Narudzba je uspjesno obrisana." });
    }
}
