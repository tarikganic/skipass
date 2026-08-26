using SkiPass.Domain.Enums;

namespace SkiPass.Domain.Entities;

/// <summary>
/// Poslovni profil korisnika (skijas, osoblje ili administrator).
/// Autentifikacija se vrsi preko povezanog <see cref="ApplicationUser"/> zapisa.
/// </summary>
public class User : BaseEntity
{
    public int? IdentityUserId { get; set; }
    public ApplicationUser? IdentityUser { get; set; }

    public string FirstName { get; set; } = string.Empty;
    public string LastName { get; set; } = string.Empty;
    public string Email { get; set; } = string.Empty;
    public string? Phone { get; set; }
    public DateTime? BirthDate { get; set; }
    public string? ProfileImageUrl { get; set; }
    public UserRole Role { get; set; } = UserRole.Skier;
    public bool IsActive { get; set; } = true;
    public DateTime? LastLoginAt { get; set; }

    public int? CityId { get; set; }
    public City? City { get; set; }

    public virtual ICollection<SkiPassOrder> Orders { get; set; } = new List<SkiPassOrder>();
    public virtual ICollection<BenefitPurchase> BenefitPurchases { get; set; } = new List<BenefitPurchase>();
    public virtual ICollection<BenefitView> BenefitViews { get; set; } = new List<BenefitView>();
    public virtual ICollection<Incident> ReportedIncidents { get; set; } = new List<Incident>();
    public virtual ICollection<Notification> Notifications { get; set; } = new List<Notification>();
    public virtual ICollection<Review> Reviews { get; set; } = new List<Review>();
}
