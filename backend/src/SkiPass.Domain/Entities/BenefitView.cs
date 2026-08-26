namespace SkiPass.Domain.Entities;

/// <summary>
/// Zapis pregleda pogodnosti u mobilnoj aplikaciji.
/// Historija pregleda je ulazni signal za sistem preporuke i upisuje se stvarno pri svakom pregledu.
/// </summary>
public class BenefitView : BaseEntity
{
    public DateTime ViewedAt { get; set; } = DateTime.UtcNow;

    /// <summary>Broj sekundi zadrzavanja na detaljima - tezinski faktor u scoringu.</summary>
    public int DurationSeconds { get; set; }

    public int UserId { get; set; }
    public User User { get; set; } = null!;

    public int BenefitId { get; set; }
    public Benefit Benefit { get; set; } = null!;
}
