namespace SkiPass.Domain.Constants;

/// <summary>
/// Nazivi rola koriste se u seed podacima, JWT claim-ovima i [Authorize] atributima.
/// Vrijednosti moraju odgovarati clanovima <see cref="Enums.UserRole"/>.
/// </summary>
public static class Roles
{
    public const string Skier = nameof(Enums.UserRole.Skier);
    public const string Staff = nameof(Enums.UserRole.Staff);
    public const string Admin = nameof(Enums.UserRole.Admin);

    /// <summary>Osoblje i administratori - pristup administrativnim operacijama.</summary>
    public const string StaffOrAdmin = Staff + "," + Admin;

    public static readonly IReadOnlyList<string> All = [Skier, Staff, Admin];
}
