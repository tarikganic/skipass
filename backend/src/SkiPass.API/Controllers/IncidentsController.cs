using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using SkiPass.Application.Common;
using SkiPass.Application.DTOs.Incidents;
using SkiPass.Application.Services.Interfaces;
using SkiPass.Domain.Constants;

namespace SkiPass.API.Controllers;

[ApiController]
[Route("api/[controller]")]
[Authorize]
[Produces("application/json")]
public class IncidentsController : ControllerBase
{
    private readonly IIncidentService _incidentService;
    private readonly ICurrentUserService _currentUserService;

    public IncidentsController(IIncidentService incidentService, ICurrentUserService currentUserService)
    {
        _incidentService = incidentService;
        _currentUserService = currentUserService;
    }

    /// <summary>
    /// Pregled incidenata. Skijas vidi samo prijave koje je sam podnio,
    /// dok osoblje i administratori vide sve prijave.
    /// </summary>
    [HttpGet]
    public async Task<ActionResult<PagedResult<IncidentDto>>> Search(
        [FromQuery] IncidentSearchDto request,
        CancellationToken cancellationToken) =>
        Ok(await _incidentService.SearchAsync(request, cancellationToken));

    [HttpGet("{id:int}")]
    public async Task<ActionResult<IncidentDto>> GetById(int id, CancellationToken cancellationToken) =>
        Ok(await _incidentService.GetByIdAsync(id, cancellationToken));

    /// <summary>Prijava incidenta sa mobilne aplikacije.</summary>
    [HttpPost]
    public async Task<ActionResult<IncidentDto>> Create([FromBody] IncidentCreateDto dto, CancellationToken cancellationToken)
    {
        var userId = _currentUserService.GetRequiredUserId();
        var created = await _incidentService.CreateAsync(dto, userId, cancellationToken);
        return CreatedAtAction(nameof(GetById), new { id = created.Id }, created);
    }

    /// <summary>
    /// Promjena statusa prijave. Odbijanje i rjesavanje zahtijevaju obrazlozenje,
    /// koje se korisniku salje kroz notifikaciju.
    /// </summary>
    [HttpPatch("{id:int}/status")]
    [Authorize(Roles = Roles.StaffOrAdmin)]
    public async Task<ActionResult<IncidentDto>> UpdateStatus(
        int id,
        [FromBody] IncidentStatusUpdateDto dto,
        CancellationToken cancellationToken)
    {
        var userId = _currentUserService.GetRequiredUserId();
        return Ok(await _incidentService.UpdateStatusAsync(id, dto, userId, cancellationToken));
    }

    [HttpDelete("{id:int}")]
    [Authorize(Roles = Roles.Admin)]
    public async Task<IActionResult> Delete(int id, CancellationToken cancellationToken)
    {
        await _incidentService.DeleteAsync(id, cancellationToken);
        return Ok(new { message = "Incident je uspjesno obrisan." });
    }
}
