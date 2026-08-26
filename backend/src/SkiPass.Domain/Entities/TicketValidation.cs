namespace SkiPass.Domain.Entities;

/// <summary>
/// Zapis skeniranja QR koda karte na ulazu na ski lift.
/// Neuspjesni pokusaji se takodjer evidentiraju radi kontrole zloupotrebe.
/// </summary>
public class TicketValidation : BaseEntity
{
    public DateTime ValidatedAt { get; set; } = DateTime.UtcNow;
    public bool IsSuccessful { get; set; }

    /// <summary>Razlog odbijanja validacije, npr. "karta je istekla".</summary>
    public string? FailureReason { get; set; }

    public int SkiPassTicketId { get; set; }
    public SkiPassTicket SkiPassTicket { get; set; } = null!;

    public int SkiLiftId { get; set; }
    public SkiLift SkiLift { get; set; } = null!;

    /// <summary>Zaposlenik koji je izvrsio skeniranje.</summary>
    public int ValidatedByUserId { get; set; }
    public User ValidatedByUser { get; set; } = null!;
}
