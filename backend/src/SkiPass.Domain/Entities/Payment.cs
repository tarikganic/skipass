using SkiPass.Domain.Enums;

namespace SkiPass.Domain.Entities;

/// <summary>
/// Transakcija placanja narudzbe. Finalizacija se vrsi iskljucivo na serverskoj strani.
/// </summary>
public class Payment : BaseEntity
{
    public decimal Amount { get; set; }
    public string Currency { get; set; } = "BAM";
    public PaymentStatus Status { get; set; } = PaymentStatus.Pending;

    /// <summary>Identifikator transakcije kod pruzaoca usluge placanja.</summary>
    public string? TransactionId { get; set; }
    public DateTime? PaidAt { get; set; }

    /// <summary>Stvarno vracen iznos - osnova za refund logiku.</summary>
    public decimal RefundedAmount { get; set; }
    public DateTime? RefundedAt { get; set; }
    public string? FailureReason { get; set; }

    public int SkiPassOrderId { get; set; }
    public SkiPassOrder SkiPassOrder { get; set; } = null!;

    public int PaymentMethodId { get; set; }
    public PaymentMethod PaymentMethod { get; set; } = null!;
}
