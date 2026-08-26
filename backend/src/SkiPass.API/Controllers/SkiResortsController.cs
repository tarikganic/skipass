using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using SkiPass.Application.Common;
using SkiPass.Application.DTOs.Common;
using SkiPass.Application.DTOs.Resorts;
using SkiPass.Application.DTOs.Weather;
using SkiPass.Application.Services.Interfaces;
using SkiPass.Domain.Constants;

namespace SkiPass.API.Controllers;

[ApiController]
[Route("api/[controller]")]
[Authorize]
[Produces("application/json")]
public class SkiResortsController : ControllerBase
{
    private readonly ISkiResortService _skiResortService;
    private readonly IWeatherLogService _weatherLogService;

    public SkiResortsController(ISkiResortService skiResortService, IWeatherLogService weatherLogService)
    {
        _skiResortService = skiResortService;
        _weatherLogService = weatherLogService;
    }

    [HttpGet]
    public async Task<ActionResult<PagedResult<SkiResortDto>>> Search([FromQuery] SkiResortSearchDto request, CancellationToken cancellationToken) =>
        Ok(await _skiResortService.SearchAsync(request, cancellationToken));

    [HttpGet("lookup")]
    public async Task<ActionResult<List<LookupDto>>> Lookup(CancellationToken cancellationToken) =>
        Ok(await _skiResortService.GetLookupAsync(cancellationToken));

    [HttpGet("{id:int}")]
    public async Task<ActionResult<SkiResortDto>> GetById(int id, CancellationToken cancellationToken) =>
        Ok(await _skiResortService.GetByIdAsync(id, cancellationToken));

    /// <summary>Posljednje evidentirano stanje vremenskih uslova na skijalistu.</summary>
    [HttpGet("{id:int}/weather/latest")]
    public async Task<ActionResult<WeatherLogDto>> GetLatestWeather(int id, CancellationToken cancellationToken)
    {
        var weather = await _weatherLogService.GetLatestAsync(id, cancellationToken);
        return weather is null
            ? NotFound(new { message = "Za odabrano skijaliste jos nisu evidentirani vremenski uslovi." })
            : Ok(weather);
    }

    [HttpPost]
    [Authorize(Roles = Roles.Admin)]
    public async Task<ActionResult<SkiResortDto>> Create([FromBody] SkiResortUpsertDto dto, CancellationToken cancellationToken)
    {
        var created = await _skiResortService.CreateAsync(dto, cancellationToken);
        return CreatedAtAction(nameof(GetById), new { id = created.Id }, created);
    }

    [HttpPut("{id:int}")]
    [Authorize(Roles = Roles.Admin)]
    public async Task<ActionResult<SkiResortDto>> Update(int id, [FromBody] SkiResortUpsertDto dto, CancellationToken cancellationToken) =>
        Ok(await _skiResortService.UpdateAsync(id, dto, cancellationToken));

    [HttpDelete("{id:int}")]
    [Authorize(Roles = Roles.Admin)]
    public async Task<IActionResult> Delete(int id, CancellationToken cancellationToken)
    {
        await _skiResortService.DeleteAsync(id, cancellationToken);
        return Ok(new { message = "Skijaliste je uspjesno obrisano." });
    }
}
