using SkiPass.Domain.Enums;

namespace SkiPass.Domain.Entities;

/// <summary>
/// Narudzba ski pass karata. Jedna narudzba moze sadrzavati vise karata
/// (kupovina za porodicu ili grupu korisnika).
/// </summary>
public class SkiPassOrder : BaseEntity
{
    public string OrderNumber { get; set; } = string.Empty;
    public DateTime OrderDate { get; set; } = DateTime.UtcNow;
    public decimal TotalAmount { get; set; }
    public OrderStatus Status { get; set; } = OrderStatus.Pending;
    public string? Note { get; set; }

    public DateTime? ConfirmedAt { get; set; }
    public DateTime? CancelledAt { get; set; }

    /// <summary>Razlog otkazivanja - obavezan pri prelasku u status Cancelled.</summary>
    public string? CancellationReason { get; set; }

    /// <summary>Audit trag: ko je posljednji promijenio status narudzbe.</summary>
    public int? StatusChangedByUserId { get; set; }
    public User? StatusChangedByUser { get; set; }

    public int UserId { get; set; }
    public User User { get; set; } = null!;

    public int PaymentMethodId { get; set; }
    public PaymentMethod PaymentMethod { get; set; } = null!;

    public virtual ICollection<SkiPassTicket> Tickets { get; set; } = new List<SkiPassTicket>();
    public virtual ICollection<Payment> Payments { get; set; } = new List<Payment>();
}
