using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using SkiPass.Application.Common;
using SkiPass.Application.DTOs.Common;
using SkiPass.Application.DTOs.Lifts;
using SkiPass.Application.Services.Interfaces;
using SkiPass.Domain.Constants;

namespace SkiPass.API.Controllers;

[ApiController]
[Route("api/[controller]")]
[Authorize]
[Produces("application/json")]
public class SkiLiftsController : ControllerBase
{
    private readonly ISkiLiftService _skiLiftService;
    private readonly ILiftMaintenanceService _maintenanceService;

    public SkiLiftsController(ISkiLiftService skiLiftService, ILiftMaintenanceService maintenanceService)
    {
        _skiLiftService = skiLiftService;
        _maintenanceService = maintenanceService;
    }

    [HttpGet]
    public async Task<ActionResult<PagedResult<SkiLiftDto>>> Search([FromQuery] SkiLiftSearchDto request, CancellationToken cancellationToken) =>
        Ok(await _skiLiftService.SearchAsync(request, cancellationToken));

    [HttpGet("lookup")]
    public async Task<ActionResult<List<LookupDto>>> Lookup(CancellationToken cancellationToken) =>
        Ok(await _skiLiftService.GetLookupAsync(cancellationToken));

    [HttpGet("{id:int}")]
    public async Task<ActionResult<SkiLiftDto>> GetById(int id, CancellationToken cancellationToken) =>
        Ok(await _skiLiftService.GetByIdAsync(id, cancellationToken));

    /// <summary>Evidencija kvarova odabranog lifta - master-details prikaz.</summary>
    [HttpGet("{id:int}/maintenance")]
    [Authorize(Roles = Roles.StaffOrAdmin)]
    public async Task<ActionResult<PagedResult<LiftMaintenanceRecordDto>>> GetMaintenance(
        int id,
        [FromQuery] LiftMaintenanceSearchDto request,
        CancellationToken cancellationToken)
    {
        request.SkiLiftId = id;
        return Ok(await _maintenanceService.SearchAsync(request, cancellationToken));
    }

    [HttpPost]
    [Authorize(Roles = Roles.StaffOrAdmin)]
    public async Task<ActionResult<SkiLiftDto>> Create([FromBody] SkiLiftUpsertDto dto, CancellationToken cancellationToken)
    {
        var created = await _skiLiftService.CreateAsync(dto, cancellationToken);
        return CreatedAtAction(nameof(GetById), new { id = created.Id }, created);
    }

    [HttpPut("{id:int}")]
    [Authorize(Roles = Roles.StaffOrAdmin)]
    public async Task<ActionResult<SkiLiftDto>> Update(int id, [FromBody] SkiLiftUpsertDto dto, CancellationToken cancellationToken) =>
        Ok(await _skiLiftService.UpdateAsync(id, dto, cancellationToken));

    /// <summary>Promjena statusa rada lifta.</summary>
    [HttpPatch("{id:int}/status")]
    [Authorize(Roles = Roles.StaffOrAdmin)]
    public async Task<ActionResult<SkiLiftDto>> UpdateStatus(int id, [FromBody] SkiLiftStatusUpdateDto dto, CancellationToken cancellationToken) =>
        Ok(await _skiLiftService.UpdateStatusAsync(id, dto, cancellationToken));

    [HttpDelete("{id:int}")]
    [Authorize(Roles = Roles.Admin)]
    public async Task<IActionResult> Delete(int id, CancellationToken cancellationToken)
    {
        await _skiLiftService.DeleteAsync(id, cancellationToken);
        return Ok(new { message = "Ski lift je uspjesno obrisan." });
    }
}

[ApiController]
[Route("api/lift-maintenance")]
[Authorize(Roles = Roles.StaffOrAdmin)]
[Produces("application/json")]
public class LiftMaintenanceController : ControllerBase
{
    private readonly ILiftMaintenanceService _service;

    public LiftMaintenanceController(ILiftMaintenanceService service)
    {
        _service = service;
    }

    [HttpGet]
    public async Task<ActionResult<PagedResult<LiftMaintenanceRecordDto>>> Search(
        [FromQuery] LiftMaintenanceSearchDto request,
        CancellationToken cancellationToken) =>
        Ok(await _service.SearchAsync(request, cancellationToken));

    [HttpGet("{id:int}")]
    public async Task<ActionResult<LiftMaintenanceRecordDto>> GetById(int id, CancellationToken cancellationToken) =>
        Ok(await _service.GetByIdAsync(id, cancellationToken));

    [HttpPost]
    public async Task<ActionResult<LiftMaintenanceRecordDto>> Create(
        [FromBody] LiftMaintenanceRecordCreateDto dto,
        CancellationToken cancellationToken)
    {
        var created = await _service.CreateAsync(dto, cancellationToken);
        return CreatedAtAction(nameof(GetById), new { id = created.Id }, created);
    }

    [HttpPut("{id:int}")]
    public async Task<ActionResult<LiftMaintenanceRecordDto>> Update(
        int id,
        [FromBody] LiftMaintenanceRecordCreateDto dto,
        CancellationToken cancellationToken) =>
        Ok(await _service.UpdateAsync(id, dto, cancellationToken));

    /// <summary>Promjena statusa kvara uz obavezno obrazlozenje pri zatvaranju.</summary>
    [HttpPatch("{id:int}/status")]
    public async Task<ActionResult<LiftMaintenanceRecordDto>> UpdateStatus(
        int id,
        [FromBody] LiftMaintenanceStatusUpdateDto dto,
        CancellationToken cancellationToken) =>
        Ok(await _service.UpdateStatusAsync(id, dto, cancellationToken));

    [HttpDelete("{id:int}")]
    [Authorize(Roles = Roles.Admin)]
    public async Task<IActionResult> Delete(int id, CancellationToken cancellationToken)
    {
        await _service.DeleteAsync(id, cancellationToken);
        return Ok(new { message = "Evidencija kvara je uspjesno obrisana." });
    }
}
