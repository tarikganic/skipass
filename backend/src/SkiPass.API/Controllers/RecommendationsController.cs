using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using SkiPass.Application.DTOs.Recommendations;
using SkiPass.Application.Services.Interfaces;

namespace SkiPass.API.Controllers;

[ApiController]
[Route("api/[controller]")]
[Authorize]
[Produces("application/json")]
public class RecommendationsController : ControllerBase
{
    private const int DefaultTake = 10;
    private const int MaxTake = 50;

    private readonly IRecommenderService _recommenderService;
    private readonly ICurrentUserService _currentUserService;

    public RecommendationsController(IRecommenderService recommenderService, ICurrentUserService currentUserService)
    {
        _recommenderService = recommenderService;
        _currentUserService = currentUserService;
    }

    [HttpGet("benefits")]
    public async Task<ActionResult<List<RecommendedBenefitDto>>> GetRecommendedBenefits(
        [FromQuery] int take,
        CancellationToken cancellationToken)
    {
        var userId = _currentUserService.GetRequiredUserId();
        var effectiveTake = take is < 1 or > MaxTake ? DefaultTake : take;
        return Ok(await _recommenderService.GetRecommendedBenefitsAsync(userId, effectiveTake, cancellationToken));
    }
}
