namespace SkiPass.Domain.Entities;

/// <summary>Referentna tabela - nacin placanja (PayPal, kartica, gotovina na blagajni).</summary>
public class PaymentMethod : BaseEntity
{
    public string Name { get; set; } = string.Empty;

    /// <summary>Interna oznaka koju koristi integracija placanja, npr. "PAYPAL".</summary>
    public string Code { get; set; } = string.Empty;

    /// <summary>Da li je nacin placanja dostupan u mobilnoj aplikaciji.</summary>
    public bool IsOnline { get; set; }
    public bool IsActive { get; set; } = true;

    public virtual ICollection<SkiPassOrder> Orders { get; set; } = new List<SkiPassOrder>();
    public virtual ICollection<Payment> Payments { get; set; } = new List<Payment>();
}
