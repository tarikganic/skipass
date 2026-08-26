using System.Security.Claims;
using Microsoft.AspNetCore.Http;
using SkiPass.Application.Exceptions;
using SkiPass.Application.Services.Interfaces;
using SkiPass.Domain.Constants;

namespace SkiPass.Infrastructure.Services;

/// <summary>
/// Cita podatke o prijavljenom korisniku iz JWT tokena preko IHttpContextAccessor-a,
/// umjesto da se token rucno parsira na svakom mjestu u kodu.
/// </summary>
public class CurrentUserService : ICurrentUserService
{
    private readonly IHttpContextAccessor _httpContextAccessor;

    public CurrentUserService(IHttpContextAccessor httpContextAccessor)
    {
        _httpContextAccessor = httpContextAccessor;
    }

    private ClaimsPrincipal? Principal => _httpContextAccessor.HttpContext?.User;

    public int? UserId =>
        int.TryParse(Principal?.FindFirstValue(ClaimTypes.NameIdentifier), out var id) ? id : null;

    public string? Username => Principal?.FindFirstValue(ClaimTypes.Name);

    public string? Role => Principal?.FindFirstValue(ClaimTypes.Role);

    public bool IsAuthenticated => Principal?.Identity?.IsAuthenticated == true;

    public bool IsAdmin => Principal?.IsInRole(Roles.Admin) == true;

    public bool IsStaffOrAdmin => IsAdmin || Principal?.IsInRole(Roles.Staff) == true;

    public int GetRequiredUserId() =>
        UserId ?? throw new ForbiddenAccessException("Zahtjev nije autentifikovan.");

    public void EnsureCanAccessUser(int targetUserId)
    {
        if (IsStaffOrAdmin)
        {
            return;
        }

        if (GetRequiredUserId() != targetUserId)
        {
            throw new ForbiddenAccessException("Mozete pristupati samo vlastitim podacima.");
        }
    }
}
