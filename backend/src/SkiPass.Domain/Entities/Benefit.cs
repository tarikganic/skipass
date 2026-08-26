namespace SkiPass.Domain.Entities;

/// <summary>
/// Dodatna pogodnost ili partnerska usluga (iznajmljivanje opreme, ugostiteljstvo, skola skijanja).
/// Atributi kategorije i brenda koriste se kao ulaz u content-based sistem preporuke.
/// </summary>
public class Benefit : BaseEntity
{
    public string Name { get; set; } = string.Empty;
    public string Description { get; set; } = string.Empty;
    public string? ImageUrl { get; set; }

    public decimal Price { get; set; }
    public decimal DiscountPercentage { get; set; }

    /// <summary>Brend opreme - signal za preporuku prema preferiranim brendovima korisnika.</summary>
    public string? Brand { get; set; }
    public bool IsActive { get; set; } = true;

    /// <summary>Prosjecna ocjena izracunata iz korisnickih recenzija.</summary>
    public double AverageRating { get; set; }
    public int RatingCount { get; set; }

    public int BenefitCategoryId { get; set; }
    public BenefitCategory BenefitCategory { get; set; } = null!;

    public int SkiResortId { get; set; }
    public SkiResort SkiResort { get; set; } = null!;

    public int? PartnerId { get; set; }
    public Partner? Partner { get; set; }

    public virtual ICollection<BenefitPurchase> Purchases { get; set; } = new List<BenefitPurchase>();
    public virtual ICollection<BenefitView> Views { get; set; } = new List<BenefitView>();
    public virtual ICollection<Review> Reviews { get; set; } = new List<Review>();
}
