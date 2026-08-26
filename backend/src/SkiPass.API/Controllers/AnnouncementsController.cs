using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using SkiPass.Application.Common;
using SkiPass.Application.DTOs.Announcements;
using SkiPass.Application.DTOs.Notifications;
using SkiPass.Application.DTOs.Weather;
using SkiPass.Application.Services.Interfaces;
using SkiPass.Domain.Constants;

namespace SkiPass.API.Controllers;

[ApiController]
[Route("api/[controller]")]
[Authorize]
[Produces("application/json")]
public class AnnouncementsController : ControllerBase
{
    private readonly IAnnouncementService _service;
    private readonly ICurrentUserService _currentUserService;

    public AnnouncementsController(IAnnouncementService service, ICurrentUserService currentUserService)
    {
        _service = service;
        _currentUserService = currentUserService;
    }

    [HttpGet]
    public async Task<ActionResult<PagedResult<AnnouncementDto>>> Search(
        [FromQuery] AnnouncementSearchDto request,
        CancellationToken cancellationToken) =>
        Ok(await _service.SearchAsync(request, cancellationToken));

    [HttpGet("{id:int}")]
    public async Task<ActionResult<AnnouncementDto>> GetById(int id, CancellationToken cancellationToken) =>
        Ok(await _service.GetByIdAsync(id, cancellationToken));

    [HttpPost]
    [Authorize(Roles = Roles.StaffOrAdmin)]
    public async Task<ActionResult<AnnouncementDto>> Create([FromBody] AnnouncementUpsertDto dto, CancellationToken cancellationToken)
    {
        var userId = _currentUserService.GetRequiredUserId();
        var created = await _service.CreateForUserAsync(dto, userId, cancellationToken);
        return CreatedAtAction(nameof(GetById), new { id = created.Id }, created);
    }

    [HttpPut("{id:int}")]
    [Authorize(Roles = Roles.StaffOrAdmin)]
    public async Task<ActionResult<AnnouncementDto>> Update(int id, [FromBody] AnnouncementUpsertDto dto, CancellationToken cancellationToken) =>
        Ok(await _service.UpdateAsync(id, dto, cancellationToken));

    [HttpDelete("{id:int}")]
    [Authorize(Roles = Roles.StaffOrAdmin)]
    public async Task<IActionResult> Delete(int id, CancellationToken cancellationToken)
    {
        await _service.DeleteAsync(id, cancellationToken);
        return Ok(new { message = "Obavijest je uspjesno obrisana." });
    }
}

[ApiController]
[Route("api/[controller]")]
[Authorize]
[Produces("application/json")]
public class NotificationsController : ControllerBase
{
    private readonly INotificationService _service;
    private readonly ICurrentUserService _currentUserService;

    public NotificationsController(INotificationService service, ICurrentUserService currentUserService)
    {
        _service = service;
        _currentUserService = currentUserService;
    }

    [HttpGet]
    public async Task<ActionResult<PagedResult<NotificationDto>>> Search(
        [FromQuery] NotificationSearchDto request,
        CancellationToken cancellationToken) =>
        Ok(await _service.SearchAsync(request, cancellationToken));

    /// <summary>Broj neprocitanih notifikacija - klijenti ga povlace periodicno.</summary>
    [HttpGet("unread-count")]
    public async Task<ActionResult<UnreadNotificationCountDto>> GetUnreadCount(CancellationToken cancellationToken)
    {
        var userId = _currentUserService.GetRequiredUserId();
        return Ok(await _service.GetUnreadCountAsync(userId, cancellationToken));
    }

    [HttpGet("{id:int}")]
    public async Task<ActionResult<NotificationDto>> GetById(int id, CancellationToken cancellationToken) =>
        Ok(await _service.GetByIdAsync(id, cancellationToken));

    [HttpPost]
    [Authorize(Roles = Roles.StaffOrAdmin)]
    public async Task<ActionResult<NotificationDto>> Create([FromBody] NotificationCreateDto dto, CancellationToken cancellationToken)
    {
        var created = await _service.CreateAsync(dto, cancellationToken);
        return CreatedAtAction(nameof(GetById), new { id = created.Id }, created);
    }

    [HttpPatch("{id:int}/read")]
    public async Task<ActionResult<NotificationDto>> MarkAsRead(int id, CancellationToken cancellationToken)
    {
        var userId = _currentUserService.GetRequiredUserId();
        return Ok(await _service.MarkAsReadAsync(id, userId, cancellationToken));
    }

    [HttpPatch("read-all")]
    public async Task<IActionResult> MarkAllAsRead(CancellationToken cancellationToken)
    {
        var userId = _currentUserService.GetRequiredUserId();
        var count = await _service.MarkAllAsReadAsync(userId, cancellationToken);
        return Ok(new { message = $"Oznaceno je {count} notifikacija kao procitano.", count });
    }

    [HttpDelete("{id:int}")]
    public async Task<IActionResult> Delete(int id, CancellationToken cancellationToken)
    {
        await _service.DeleteAsync(id, cancellationToken);
        return Ok(new { message = "Notifikacija je uspjesno obrisana." });
    }
}

[ApiController]
[Route("api/weather-logs")]
[Authorize]
[Produces("application/json")]
public class WeatherLogsController : ControllerBase
{
    private readonly IWeatherLogService _service;

    public WeatherLogsController(IWeatherLogService service)
    {
        _service = service;
    }

    [HttpGet]
    public async Task<ActionResult<PagedResult<WeatherLogDto>>> Search(
        [FromQuery] WeatherLogSearchDto request,
        CancellationToken cancellationToken) =>
        Ok(await _service.SearchAsync(request, cancellationToken));

    [HttpGet("{id:int}")]
    public async Task<ActionResult<WeatherLogDto>> GetById(int id, CancellationToken cancellationToken) =>
        Ok(await _service.GetByIdAsync(id, cancellationToken));

    [HttpPost]
    [Authorize(Roles = Roles.StaffOrAdmin)]
    public async Task<ActionResult<WeatherLogDto>> Create([FromBody] WeatherLogUpsertDto dto, CancellationToken cancellationToken)
    {
        var created = await _service.CreateAsync(dto, cancellationToken);
        return CreatedAtAction(nameof(GetById), new { id = created.Id }, created);
    }

    [HttpPut("{id:int}")]
    [Authorize(Roles = Roles.StaffOrAdmin)]
    public async Task<ActionResult<WeatherLogDto>> Update(int id, [FromBody] WeatherLogUpsertDto dto, CancellationToken cancellationToken) =>
        Ok(await _service.UpdateAsync(id, dto, cancellationToken));

    [HttpDelete("{id:int}")]
    [Authorize(Roles = Roles.StaffOrAdmin)]
    public async Task<IActionResult> Delete(int id, CancellationToken cancellationToken)
    {
        await _service.DeleteAsync(id, cancellationToken);
        return Ok(new { message = "Evidencija vremenskih uslova je uspjesno obrisana." });
    }
}
