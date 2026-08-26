using System.ComponentModel.DataAnnotations;
using SkiPass.Application.Common;

namespace SkiPass.Application.DTOs.Tickets;

public class SkiPassTicketDto
{
    public int Id { get; set; }
    public string QrCode { get; set; } = string.Empty;
    public string HolderFirstName { get; set; } = string.Empty;
    public string HolderLastName { get; set; } = string.Empty;
    public string HolderFullName { get; set; } = string.Empty;
    public DateOnly ValidFrom { get; set; }
    public DateOnly ValidTo { get; set; }
    public int NumberOfDays { get; set; }
    public decimal Price { get; set; }
    public string Status { get; set; } = string.Empty;
    public DateTime? ActivatedAt { get; set; }
    public DateTime? CancelledAt { get; set; }

    public int SkiPassOrderId { get; set; }
    public string OrderNumber { get; set; } = string.Empty;
    public string OrderStatus { get; set; } = string.Empty;

    public int PaymentMethodId { get; set; }
    public string PaymentMethodName { get; set; } = string.Empty;

    public int TicketTypeId { get; set; }
    public string TicketTypeName { get; set; } = string.Empty;

    public int SkiResortId { get; set; }
    public string SkiResortName { get; set; } = string.Empty;

    public int ValidationCount { get; set; }
    public DateTime? LastValidatedAt { get; set; }
}

public class SkiPassTicketSearchDto : PagedRequest
{
    /// <summary>Pretraga po QR kodu, imenu nosioca ili broju narudzbe.</summary>
    public string? Query { get; set; }
    public int? UserId { get; set; }
    public int? SkiPassOrderId { get; set; }
    public int? TicketTypeId { get; set; }
    public int? SkiResortId { get; set; }
    public string? Status { get; set; }
    public DateOnly? ValidOnDate { get; set; }
    public DateOnly? ValidFromDate { get; set; }
    public DateOnly? ValidToDate { get; set; }
}

/// <summary>Zahtjev za QR validaciju karte na ulazu na ski lift.</summary>
public class TicketValidationRequestDto
{
    [Required(ErrorMessage = "QR kod karte je obavezan.")]
    [StringLength(64, MinimumLength = 8, ErrorMessage = "QR kod mora imati izmedju 8 i 64 znaka.")]
    public string QrCode { get; set; } = string.Empty;

    [Range(1, int.MaxValue, ErrorMessage = "Odaberite ski lift na kojem se vrsi validacija.")]
    public int SkiLiftId { get; set; }
}

public class TicketValidationDto
{
    public int Id { get; set; }
    public DateTime ValidatedAt { get; set; }
    public bool IsSuccessful { get; set; }
    public string? FailureReason { get; set; }

    public int SkiPassTicketId { get; set; }
    public string TicketHolderName { get; set; } = string.Empty;
    public string TicketTypeName { get; set; } = string.Empty;

    public int SkiLiftId { get; set; }
    public string SkiLiftName { get; set; } = string.Empty;

    public int ValidatedByUserId { get; set; }
    public string ValidatedByUserName { get; set; } = string.Empty;
}

public class TicketValidationSearchDto : PagedRequest
{
    /// <summary>Pretraga po imenu nosioca karte, nazivu lifta ili razlogu odbijanja.</summary>
    public string? Query { get; set; }
    public int? SkiPassTicketId { get; set; }
    public int? SkiLiftId { get; set; }
    public int? SkiResortId { get; set; }
    public bool? IsSuccessful { get; set; }
    public DateTime? ValidatedFrom { get; set; }
    public DateTime? ValidatedTo { get; set; }
}
