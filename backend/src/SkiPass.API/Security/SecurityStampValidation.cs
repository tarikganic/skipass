using System.Security.Claims;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.EntityFrameworkCore;
using SkiPass.Domain.Entities;
using SkiPass.Infrastructure.Data;
using SkiPass.Infrastructure.Services;

namespace SkiPass.API.Security;

/// <summary>
/// Provjerava da sigurnosni pecat iz tokena odgovara aktuelnom pecatu korisnika.
/// Time se odjava i promjena lozinke stvarno invalidiraju token na serverskoj strani,
/// umjesto da se token samo obrise na klijentu. Provjera se namjerno ne kesira
/// kako bi odjava imala trenutni efekat; radi se o jednom upitu po primarnom kljucu.
/// </summary>
public static class SecurityStampValidation
{
    public static JwtBearerEvents CreateEvents() => new()
    {
        OnTokenValidated = async context =>
        {
            var principal = context.Principal;
            var tokenStamp = principal?.FindFirst(JwtTokenService.SecurityStampClaimType)?.Value;
            var userIdValue = principal?.FindFirst(ClaimTypes.NameIdentifier)?.Value;

            if (string.IsNullOrWhiteSpace(tokenStamp) || !int.TryParse(userIdValue, out var userId))
            {
                context.Fail("Token ne sadrzi potrebne podatke o korisniku.");
                return;
            }

            var dbContext = context.HttpContext.RequestServices.GetRequiredService<ApplicationDbContext>();

            var currentStamp = await dbContext.Set<ApplicationUser>()
                .Where(u => u.Id == userId)
                .Select(u => u.SecurityStamp)
                .FirstOrDefaultAsync(context.HttpContext.RequestAborted);

            if (currentStamp is null || currentStamp != tokenStamp)
            {
                context.Fail("Token vise nije vazeci. Molimo prijavite se ponovo.");
            }
        }
    };
}
