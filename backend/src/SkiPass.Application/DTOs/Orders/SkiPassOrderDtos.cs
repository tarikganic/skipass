using System.ComponentModel.DataAnnotations;
using SkiPass.Application.Common;
using SkiPass.Application.DTOs.Tickets;

namespace SkiPass.Application.DTOs.Orders;

public class SkiPassOrderDto
{
    public int Id { get; set; }
    public string OrderNumber { get; set; } = string.Empty;
    public DateTime OrderDate { get; set; }
    public decimal TotalAmount { get; set; }
    public string Status { get; set; } = string.Empty;
    public string? Note { get; set; }
    public DateTime? ConfirmedAt { get; set; }
    public DateTime? CancelledAt { get; set; }
    public string? CancellationReason { get; set; }
    public string? StatusChangedByUserName { get; set; }

    public int UserId { get; set; }
    public string UserFullName { get; set; } = string.Empty;
    public string UserEmail { get; set; } = string.Empty;

    public int PaymentMethodId { get; set; }
    public string PaymentMethodName { get; set; } = string.Empty;

    public int TicketCount { get; set; }

    /// <summary>Narudzba je placena - klijent na osnovu ovoga sakriva dugme za placanje.</summary>
    public bool IsPaid { get; set; }
    public decimal PaidAmount { get; set; }
    public decimal RefundedAmount { get; set; }

    /// <summary>Statusi u koje narudzba moze preci iz trenutnog stanja.</summary>
    public List<string> AllowedNextStatuses { get; set; } = [];
}

/// <summary>Detalji narudzbe sa listom karata - master-details prikaz.</summary>
public class SkiPassOrderDetailsDto : SkiPassOrderDto
{
    public List<SkiPassTicketDto> Tickets { get; set; } = [];
    public List<PaymentSummaryDto> Payments { get; set; } = [];
}

public class PaymentSummaryDto
{
    public int Id { get; set; }
    public decimal Amount { get; set; }
    public string Currency { get; set; } = string.Empty;
    public string Status { get; set; } = string.Empty;
    public string PaymentMethodName { get; set; } = string.Empty;
    public DateTime? PaidAt { get; set; }
    public decimal RefundedAmount { get; set; }
    public DateTime? RefundedAt { get; set; }
}

/// <summary>
/// Kreiranje narudzbe. Cijena se u potpunosti racuna na serveru iz cjenovnika tipa karte;
/// klijent salje samo sta zeli kupiti.
/// </summary>
public class SkiPassOrderCreateDto : IValidatableObject
{
    [Range(1, int.MaxValue, ErrorMessage = "Odaberite nacin placanja iz padajuce liste.")]
    public int PaymentMethodId { get; set; }

    [StringLength(500, ErrorMessage = "Napomena moze imati najvise 500 znakova.")]
    public string? Note { get; set; }

    [Required(ErrorMessage = "Narudzba mora sadrzavati najmanje jednu kartu.")]
    [MinLength(1, ErrorMessage = "Narudzba mora sadrzavati najmanje jednu kartu.")]
    [MaxLength(20, ErrorMessage = "U jednoj narudzbi je moguce kupiti najvise 20 karata.")]
    public List<SkiPassOrderItemDto> Items { get; set; } = [];

    public IEnumerable<ValidationResult> Validate(ValidationContext validationContext)
    {
        var duplicate = Items
            .GroupBy(i => new { i.TicketTypeId, i.ValidFrom, i.HolderFirstName, i.HolderLastName })
            .Any(g => g.Count() > 1);

        if (duplicate)
        {
            yield return new ValidationResult(
                "Narudzba sadrzi dvije identicne karte za istog nosioca, isti tip i isti datum pocetka.",
                [nameof(Items)]);
        }
    }
}

public class SkiPassOrderItemDto
{
    [Range(1, int.MaxValue, ErrorMessage = "Odaberite tip karte iz padajuce liste.")]
    public int TicketTypeId { get; set; }

    [Required(ErrorMessage = "Ime nosioca karte je obavezno.")]
    [StringLength(100, MinimumLength = 2, ErrorMessage = "Ime nosioca mora imati izmedju 2 i 100 znakova.")]
    public string HolderFirstName { get; set; } = string.Empty;

    [Required(ErrorMessage = "Prezime nosioca karte je obavezno.")]
    [StringLength(100, MinimumLength = 2, ErrorMessage = "Prezime nosioca mora imati izmedju 2 i 100 znakova.")]
    public string HolderLastName { get; set; } = string.Empty;

    [Required(ErrorMessage = "Datum pocetka vazenja karte je obavezan.")]
    public DateOnly ValidFrom { get; set; }

    [Range(1, 180, ErrorMessage = "Broj dana mora biti izmedju 1 i 180.")]
    public int NumberOfDays { get; set; } = 1;
}

public class SkiPassOrderStatusUpdateDto
{
    [Required(ErrorMessage = "Odaberite novi status narudzbe.")]
    public string Status { get; set; } = string.Empty;

    /// <summary>Razlog otkazivanja. Obavezan kada se narudzba otkazuje.</summary>
    [StringLength(500, ErrorMessage = "Razlog moze imati najvise 500 znakova.")]
    public string? CancellationReason { get; set; }
}

public class SkiPassOrderSearchDto : PagedRequest
{
    /// <summary>Pretraga po broju narudzbe, imenu ili e-mailu korisnika.</summary>
    public string? Query { get; set; }
    public int? UserId { get; set; }
    public string? Status { get; set; }
    public int? PaymentMethodId { get; set; }
    public bool? IsPaid { get; set; }
    public DateTime? OrderedFrom { get; set; }
    public DateTime? OrderedTo { get; set; }

    [Range(0, 1000000, ErrorMessage = "Minimalni iznos mora biti izmedju 0 i 1000000.")]
    public decimal? MinTotalAmount { get; set; }

    [Range(0, 1000000, ErrorMessage = "Maksimalni iznos mora biti izmedju 0 i 1000000.")]
    public decimal? MaxTotalAmount { get; set; }
}
