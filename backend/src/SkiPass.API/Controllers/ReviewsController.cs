using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using SkiPass.Application.Common;
using SkiPass.Application.DTOs.Reviews;
using SkiPass.Application.Services.Interfaces;

namespace SkiPass.API.Controllers;

[ApiController]
[Route("api/[controller]")]
[Authorize]
[Produces("application/json")]
public class ReviewsController : ControllerBase
{
    private readonly IReviewService _service;
    private readonly ICurrentUserService _currentUserService;

    public ReviewsController(IReviewService service, ICurrentUserService currentUserService)
    {
        _service = service;
        _currentUserService = currentUserService;
    }

    [HttpGet]
    public async Task<ActionResult<PagedResult<ReviewDto>>> Search([FromQuery] ReviewSearchDto request, CancellationToken cancellationToken) =>
        Ok(await _service.SearchAsync(request, cancellationToken));

    [HttpGet("{id:int}")]
    public async Task<ActionResult<ReviewDto>> GetById(int id, CancellationToken cancellationToken) =>
        Ok(await _service.GetByIdAsync(id, cancellationToken));

    [HttpPost]
    public async Task<ActionResult<ReviewDto>> Create([FromBody] ReviewCreateDto dto, CancellationToken cancellationToken)
    {
        var userId = _currentUserService.GetRequiredUserId();
        var created = await _service.CreateAsync(dto, userId, cancellationToken);
        return CreatedAtAction(nameof(GetById), new { id = created.Id }, created);
    }

    /// <summary>Korisnik moze uredjivati samo vlastitu ocjenu; administrator sve.</summary>
    [HttpPut("{id:int}")]
    public async Task<ActionResult<ReviewDto>> Update(int id, [FromBody] ReviewUpdateDto dto, CancellationToken cancellationToken)
    {
        var userId = _currentUserService.GetRequiredUserId();
        return Ok(await _service.UpdateAsync(id, dto, userId, _currentUserService.IsAdmin, cancellationToken));
    }

    [HttpDelete("{id:int}")]
    public async Task<IActionResult> Delete(int id, CancellationToken cancellationToken)
    {
        var userId = _currentUserService.GetRequiredUserId();
        await _service.DeleteAsync(id, userId, _currentUserService.IsAdmin, cancellationToken);
        return Ok(new { message = "Ocjena je uspjesno obrisana." });
    }
}
