using Microsoft.AspNetCore.Identity;

namespace SkiPass.Domain.Entities;

/// <summary>
/// ASP.NET Identity korisnik. Cuva samo kredencijale i sigurnosne podatke,
/// dok se poslovni podaci nalaze na povezanom <see cref="User"/> zapisu.
/// </summary>
public class ApplicationUser : IdentityUser<int>
{
}
