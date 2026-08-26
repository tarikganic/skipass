using SkiPass.Domain.Enums;

namespace SkiPass.Domain.Entities;

/// <summary>
/// Kupljena pogodnost. Predstavlja najjaci signal za content-based sistem preporuke.
/// </summary>
public class BenefitPurchase : BaseEntity
{
    public DateTime PurchasedAt { get; set; } = DateTime.UtcNow;
    public int Quantity { get; set; } = 1;

    /// <summary>Ukupna cijena izracunata na serveru u trenutku kupovine.</summary>
    public decimal TotalPrice { get; set; }
    public OrderStatus Status { get; set; } = OrderStatus.Pending;
    public string? CancellationReason { get; set; }

    public int UserId { get; set; }
    public User User { get; set; } = null!;

    public int BenefitId { get; set; }
    public Benefit Benefit { get; set; } = null!;
}
