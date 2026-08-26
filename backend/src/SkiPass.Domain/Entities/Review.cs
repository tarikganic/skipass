using SkiPass.Domain.Enums;

namespace SkiPass.Domain.Entities;

/// <summary>
/// Ocjena i komentar korisnika za stazu, pogodnost ili skijaliste u cjelini.
/// </summary>
public class Review : BaseEntity
{
    /// <summary>Ocjena u rasponu od 1 do 5.</summary>
    public int Rating { get; set; }
    public string? Comment { get; set; }
    public ReviewTargetType TargetType { get; set; }

    public int UserId { get; set; }
    public User User { get; set; } = null!;

    public int? TrailId { get; set; }
    public Trail? Trail { get; set; }

    public int? BenefitId { get; set; }
    public Benefit? Benefit { get; set; }

    public int? SkiResortId { get; set; }
    public SkiResort? SkiResort { get; set; }
}
