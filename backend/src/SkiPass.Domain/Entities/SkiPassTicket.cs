using SkiPass.Domain.Enums;

namespace SkiPass.Domain.Entities;

/// <summary>
/// Pojedinacna ski pass karta sa jedinstvenim QR kodom koji se validira na ski liftu.
/// </summary>
public class SkiPassTicket : BaseEntity
{
    /// <summary>Jedinstveni sadrzaj QR koda. Generise se kriptografski sigurnim generatorom.</summary>
    public string QrCode { get; set; } = string.Empty;

    /// <summary>Ime nosioca karte - karta se moze kupiti za drugu osobu.</summary>
    public string HolderFirstName { get; set; } = string.Empty;
    public string HolderLastName { get; set; } = string.Empty;

    public DateOnly ValidFrom { get; set; }
    public DateOnly ValidTo { get; set; }
    public int NumberOfDays { get; set; }

    /// <summary>Cijena karte u trenutku kupovine, izracunata na serveru.</summary>
    public decimal Price { get; set; }
    public TicketStatus Status { get; set; } = TicketStatus.Pending;
    public DateTime? ActivatedAt { get; set; }
    public DateTime? CancelledAt { get; set; }

    public int SkiPassOrderId { get; set; }
    public SkiPassOrder SkiPassOrder { get; set; } = null!;

    public int TicketTypeId { get; set; }
    public TicketType TicketType { get; set; } = null!;

    public virtual ICollection<TicketValidation> Validations { get; set; } = new List<TicketValidation>();
}
