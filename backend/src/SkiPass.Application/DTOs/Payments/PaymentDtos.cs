using System.ComponentModel.DataAnnotations;
using SkiPass.Application.Common;

namespace SkiPass.Application.DTOs.Payments;

public class PaymentDto
{
    public int Id { get; set; }
    public decimal Amount { get; set; }
    public string Currency { get; set; } = string.Empty;
    public string Status { get; set; } = string.Empty;
    public string? TransactionId { get; set; }
    public DateTime? PaidAt { get; set; }
    public decimal RefundedAmount { get; set; }
    public DateTime? RefundedAt { get; set; }
    public string? FailureReason { get; set; }

    public int SkiPassOrderId { get; set; }
    public string OrderNumber { get; set; } = string.Empty;

    public int PaymentMethodId { get; set; }
    public string PaymentMethodName { get; set; } = string.Empty;

    public int UserId { get; set; }
    public string UserFullName { get; set; } = string.Empty;

    public DateTime CreatedAt { get; set; }

    /// <summary>
    /// Postavljeno samo u odgovoru na zapocinjanje online placanja (InitiateAsync).
    /// Mobilna aplikacija ovo prosljedjuje Stripe PaymentSheet-u da prikaze formu za placanje
    /// unutar aplikacije - placanje se finalizira iskljucivo preko Stripe webhook-a na serveru.
    /// </summary>
    public string? StripeClientSecret { get; set; }
    public string? StripePublishableKey { get; set; }
}

/// <summary>
/// Iniciranje placanja narudzbe. Iznos se ne prima od klijenta - server ga racuna iz narudzbe.
/// </summary>
public class PaymentCreateDto
{
    [Range(1, int.MaxValue, ErrorMessage = "Odaberite narudzbu za koju se vrsi placanje.")]
    public int SkiPassOrderId { get; set; }

    [Range(1, int.MaxValue, ErrorMessage = "Odaberite nacin placanja iz padajuce liste.")]
    public int PaymentMethodId { get; set; }
}

/// <summary>
/// Serverska finalizacija placanja. Operacija je idempotentna - ponovni poziv
/// nad vec zavrsenom transakcijom ne mijenja stanje sistema.
/// </summary>
public class PaymentConfirmDto
{
    [Required(ErrorMessage = "Identifikator transakcije je obavezan.")]
    [StringLength(128, MinimumLength = 3, ErrorMessage = "Identifikator transakcije mora imati izmedju 3 i 128 znakova.")]
    public string TransactionId { get; set; } = string.Empty;
}

public class PaymentRefundDto
{
    /// <summary>
    /// Iznos povrata. Ako se ne navede, vraca se cjelokupan stvarno naplacen iznos.
    /// </summary>
    [Range(0.01, 1000000, ErrorMessage = "Iznos povrata mora biti izmedju 0.01 i 1000000.")]
    public decimal? Amount { get; set; }

    [Required(ErrorMessage = "Razlog povrata sredstava je obavezan.")]
    [StringLength(500, MinimumLength = 3, ErrorMessage = "Razlog mora imati izmedju 3 i 500 znakova.")]
    public string Reason { get; set; } = string.Empty;
}

public class PaymentSearchDto : PagedRequest
{
    /// <summary>Pretraga po broju narudzbe, identifikatoru transakcije ili imenu korisnika.</summary>
    public string? Query { get; set; }
    public int? SkiPassOrderId { get; set; }
    public int? UserId { get; set; }
    public int? PaymentMethodId { get; set; }
    public string? Status { get; set; }
    public DateTime? PaidFrom { get; set; }
    public DateTime? PaidTo { get; set; }
}
