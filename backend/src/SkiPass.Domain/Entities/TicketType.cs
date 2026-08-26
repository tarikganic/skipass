namespace SkiPass.Domain.Entities;

/// <summary>
/// Tip ski pass karte sa cjenovnikom. Osoblje moze dodavati nove tipove i mijenjati cijene.
/// Server je jedini izvor cijene prilikom kupovine.
/// </summary>
public class TicketType : BaseEntity
{
    public string Name { get; set; } = string.Empty;
    public string? Description { get; set; }

    /// <summary>Cijena za jedan dan skijanja.</summary>
    public decimal PricePerDay { get; set; }

    /// <summary>Maksimalan broj dana koji se moze kupiti pod ovim tipom karte.</summary>
    public int MaxDays { get; set; } = 7;

    /// <summary>Popust u procentima koji se primjenjuje na ukupnu cijenu (npr. djecija karta).</summary>
    public decimal DiscountPercentage { get; set; }

    public int? MinAge { get; set; }
    public int? MaxAge { get; set; }
    public bool IsActive { get; set; } = true;

    public int SkiResortId { get; set; }
    public SkiResort SkiResort { get; set; } = null!;

    public virtual ICollection<SkiPassTicket> Tickets { get; set; } = new List<SkiPassTicket>();
}
