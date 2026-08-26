using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using SkiPass.Application.DTOs.Reports;
using SkiPass.Application.Services.Interfaces;
using SkiPass.Domain.Constants;

namespace SkiPass.API.Controllers;

/// <summary>
/// Izvjestaji za desktop administraciju. Dostupno samo osoblju i administratorima.
/// </summary>
[ApiController]
[Route("api/[controller]")]
[Authorize(Roles = Roles.StaffOrAdmin)]
[Produces("application/json")]
public class ReportsController : ControllerBase
{
    private readonly IReportService _reportService;

    public ReportsController(IReportService reportService)
    {
        _reportService = reportService;
    }

    /// <summary>Graf prodaje po danima - broj prodatih karata i ostvareni prihod.</summary>
    [HttpGet("sales-by-day")]
    public async Task<ActionResult<SalesReportDto>> GetSalesByDay(
        [FromQuery] SalesReportRequestDto request,
        CancellationToken cancellationToken) =>
        Ok(await _reportService.GetSalesByDayAsync(request, cancellationToken));

    /// <summary>Top korisnici po broju kupljenih karata. Fiksan obim rezultata, bez potrebe za pretragom.</summary>
    [HttpGet("top-users")]
    public async Task<ActionResult<TopUsersReportDto>> GetTopUsers(
        [FromQuery] int top,
        CancellationToken cancellationToken)
    {
        var effectiveTop = top <= 0 ? 5 : top;
        return Ok(await _reportService.GetTopUsersAsync(effectiveTop, cancellationToken));
    }
}
