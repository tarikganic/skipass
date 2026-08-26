using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using SkiPass.Application.DTOs.Home;
using SkiPass.Application.Services.Interfaces;

namespace SkiPass.API.Controllers;

/// <summary>
/// Pocetna stranica mobilne aplikacije. Vraca sve potrebne podatke jednim pozivom.
/// </summary>
[ApiController]
[Route("api/[controller]")]
[Authorize]
[Produces("application/json")]
public class HomeController : ControllerBase
{
    private readonly IHomeService _homeService;
    private readonly ICurrentUserService _currentUserService;

    public HomeController(IHomeService homeService, ICurrentUserService currentUserService)
    {
        _homeService = homeService;
        _currentUserService = currentUserService;
    }

    [HttpGet("summary")]
    public async Task<ActionResult<HomeSummaryDto>> GetSummary(
        [FromQuery] int? skiResortId,
        CancellationToken cancellationToken)
    {
        var userId = _currentUserService.GetRequiredUserId();
        return Ok(await _homeService.GetSummaryAsync(userId, skiResortId, cancellationToken));
    }
}
