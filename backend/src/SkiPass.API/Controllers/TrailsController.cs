using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using SkiPass.Application.Common;
using SkiPass.Application.DTOs.Common;
using SkiPass.Application.DTOs.Trails;
using SkiPass.Application.Services.Interfaces;
using SkiPass.Domain.Constants;

namespace SkiPass.API.Controllers;

[ApiController]
[Route("api/[controller]")]
[Authorize]
[Produces("application/json")]
public class TrailsController : ControllerBase
{
    private readonly ITrailService _trailService;
    private readonly ITrailConditionLogService _conditionLogService;

    public TrailsController(ITrailService trailService, ITrailConditionLogService conditionLogService)
    {
        _trailService = trailService;
        _conditionLogService = conditionLogService;
    }

    [HttpGet]
    public async Task<ActionResult<PagedResult<TrailDto>>> Search([FromQuery] TrailSearchDto request, CancellationToken cancellationToken) =>
        Ok(await _trailService.SearchAsync(request, cancellationToken));

    [HttpGet("lookup")]
    public async Task<ActionResult<List<LookupDto>>> Lookup(CancellationToken cancellationToken) =>
        Ok(await _trailService.GetLookupAsync(cancellationToken));

    [HttpGet("{id:int}")]
    public async Task<ActionResult<TrailDto>> GetById(int id, CancellationToken cancellationToken) =>
        Ok(await _trailService.GetByIdAsync(id, cancellationToken));

    /// <summary>Historija evidentiranih uslova na stazi - master-details prikaz.</summary>
    [HttpGet("{id:int}/conditions")]
    public async Task<ActionResult<PagedResult<TrailConditionLogDto>>> GetConditions(
        int id,
        [FromQuery] TrailConditionLogSearchDto request,
        CancellationToken cancellationToken)
    {
        request.TrailId = id;
        return Ok(await _conditionLogService.SearchAsync(request, cancellationToken));
    }

    [HttpPost]
    [Authorize(Roles = Roles.StaffOrAdmin)]
    public async Task<ActionResult<TrailDto>> Create([FromBody] TrailUpsertDto dto, CancellationToken cancellationToken)
    {
        var created = await _trailService.CreateAsync(dto, cancellationToken);
        return CreatedAtAction(nameof(GetById), new { id = created.Id }, created);
    }

    [HttpPut("{id:int}")]
    [Authorize(Roles = Roles.StaffOrAdmin)]
    public async Task<ActionResult<TrailDto>> Update(int id, [FromBody] TrailUpsertDto dto, CancellationToken cancellationToken) =>
        Ok(await _trailService.UpdateAsync(id, dto, cancellationToken));

    /// <summary>Brza promjena statusa staze i procijenjene guzve.</summary>
    [HttpPatch("{id:int}/status")]
    [Authorize(Roles = Roles.StaffOrAdmin)]
    public async Task<ActionResult<TrailDto>> UpdateStatus(int id, [FromBody] TrailStatusUpdateDto dto, CancellationToken cancellationToken) =>
        Ok(await _trailService.UpdateStatusAsync(id, dto, cancellationToken));

    [HttpDelete("{id:int}")]
    [Authorize(Roles = Roles.Admin)]
    public async Task<IActionResult> Delete(int id, CancellationToken cancellationToken)
    {
        await _trailService.DeleteAsync(id, cancellationToken);
        return Ok(new { message = "Ski staza je uspjesno obrisana." });
    }
}

[ApiController]
[Route("api/trail-conditions")]
[Authorize]
[Produces("application/json")]
public class TrailConditionsController : ControllerBase
{
    private readonly ITrailConditionLogService _service;

    public TrailConditionsController(ITrailConditionLogService service)
    {
        _service = service;
    }

    [HttpGet]
    public async Task<ActionResult<PagedResult<TrailConditionLogDto>>> Search(
        [FromQuery] TrailConditionLogSearchDto request,
        CancellationToken cancellationToken) =>
        Ok(await _service.SearchAsync(request, cancellationToken));

    [HttpGet("{id:int}")]
    public async Task<ActionResult<TrailConditionLogDto>> GetById(int id, CancellationToken cancellationToken) =>
        Ok(await _service.GetByIdAsync(id, cancellationToken));

    [HttpPost]
    [Authorize(Roles = Roles.StaffOrAdmin)]
    public async Task<ActionResult<TrailConditionLogDto>> Create(
        [FromBody] TrailConditionLogCreateDto dto,
        CancellationToken cancellationToken)
    {
        var created = await _service.CreateAsync(dto, cancellationToken);
        return CreatedAtAction(nameof(GetById), new { id = created.Id }, created);
    }

    [HttpPut("{id:int}")]
    [Authorize(Roles = Roles.StaffOrAdmin)]
    public async Task<ActionResult<TrailConditionLogDto>> Update(
        int id,
        [FromBody] TrailConditionLogCreateDto dto,
        CancellationToken cancellationToken) =>
        Ok(await _service.UpdateAsync(id, dto, cancellationToken));

    [HttpDelete("{id:int}")]
    [Authorize(Roles = Roles.StaffOrAdmin)]
    public async Task<IActionResult> Delete(int id, CancellationToken cancellationToken)
    {
        await _service.DeleteAsync(id, cancellationToken);
        return Ok(new { message = "Evidencija stanja staze je uspjesno obrisana." });
    }
}
