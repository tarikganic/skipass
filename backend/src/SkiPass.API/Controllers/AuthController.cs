using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using SkiPass.Application.DTOs.Auth;
using SkiPass.Application.DTOs.Users;
using SkiPass.Application.Services.Interfaces;

namespace SkiPass.API.Controllers;

[ApiController]
[Route("api/[controller]")]
[Authorize]
[Produces("application/json")]
public class AuthController : ControllerBase
{
    private readonly IAuthService _authService;
    private readonly IUserService _userService;
    private readonly ICurrentUserService _currentUserService;

    public AuthController(IAuthService authService, IUserService userService, ICurrentUserService currentUserService)
    {
        _authService = authService;
        _userService = userService;
        _currentUserService = currentUserService;
    }

    /// <summary>Prijava korisnika. Kredencijali se salju u tijelu zahtjeva.</summary>
    [HttpPost("login")]
    [AllowAnonymous]
    public async Task<ActionResult<AuthResponseDto>> Login([FromBody] LoginRequestDto request, CancellationToken cancellationToken) =>
        Ok(await _authService.LoginAsync(request, cancellationToken));

    /// <summary>Registracija novog skijasa. Rola se dodjeljuje na serveru i ne prima se od klijenta.</summary>
    [HttpPost("register")]
    [AllowAnonymous]
    public async Task<ActionResult<AuthResponseDto>> Register([FromBody] RegisterRequestDto request, CancellationToken cancellationToken) =>
        Ok(await _authService.RegisterAsync(request, cancellationToken));

    /// <summary>Podaci o trenutno prijavljenom korisniku.</summary>
    [HttpGet("me")]
    public async Task<ActionResult<UserDto>> Me(CancellationToken cancellationToken) =>
        Ok(await _userService.GetProfileAsync(_currentUserService.GetRequiredUserId(), cancellationToken));

    [HttpPut("me")]
    public async Task<ActionResult<UserDto>> UpdateProfile([FromBody] UserProfileUpdateDto dto, CancellationToken cancellationToken)
    {
        var userId = _currentUserService.GetRequiredUserId();
        return Ok(await _userService.UpdateProfileAsync(userId, dto, cancellationToken));
    }

    /// <summary>Promjena vlastite lozinke uz obaveznu potvrdu trenutne lozinke.</summary>
    [HttpPost("change-password")]
    public async Task<IActionResult> ChangePassword([FromBody] ChangePasswordRequestDto request, CancellationToken cancellationToken)
    {
        await _authService.ChangePasswordAsync(_currentUserService.GetRequiredUserId(), request, cancellationToken);
        return Ok(new { message = "Lozinka je uspjesno promijenjena. Prijavite se ponovo." });
    }

    /// <summary>Salje kod za reset lozinke na registrovanu e-mail adresu.</summary>
    [HttpPost("forgot-password")]
    [AllowAnonymous]
    public async Task<ActionResult<ForgotPasswordResponseDto>> ForgotPassword([FromBody] ForgotPasswordRequestDto request, CancellationToken cancellationToken) =>
        Ok(await _authService.ForgotPasswordAsync(request, cancellationToken));

    /// <summary>Postavlja novu lozinku na osnovu koda za reset.</summary>
    [HttpPost("reset-password")]
    [AllowAnonymous]
    public async Task<IActionResult> ResetPassword([FromBody] ResetPasswordRequestDto request, CancellationToken cancellationToken)
    {
        await _authService.ResetPasswordAsync(request, cancellationToken);
        return Ok(new { message = "Lozinka je uspjesno promijenjena. Sada se mozete prijaviti." });
    }

    /// <summary>Odjava invalidira izdati token na serverskoj strani.</summary>
    [HttpPost("logout")]
    public async Task<IActionResult> Logout(CancellationToken cancellationToken)
    {
        await _authService.LogoutAsync(_currentUserService.GetRequiredUserId(), cancellationToken);
        return Ok(new { message = "Uspjesno ste odjavljeni." });
    }
}
