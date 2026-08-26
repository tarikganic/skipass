using System.ComponentModel.DataAnnotations;
using SkiPass.Application.Common;

namespace SkiPass.Application.DTOs.Tickets;

public class TicketTypeDto
{
    public int Id { get; set; }
    public string Name { get; set; } = string.Empty;
    public string? Description { get; set; }
    public decimal PricePerDay { get; set; }
    public int MaxDays { get; set; }
    public decimal DiscountPercentage { get; set; }
    public int? MinAge { get; set; }
    public int? MaxAge { get; set; }
    public bool IsActive { get; set; }
    public int SkiResortId { get; set; }
    public string SkiResortName { get; set; } = string.Empty;
    public int SoldTicketCount { get; set; }
}

public class TicketTypeUpsertDto : IValidatableObject
{
    [Required(ErrorMessage = "Naziv tipa karte je obavezan.")]
    [StringLength(120, MinimumLength = 2, ErrorMessage = "Naziv mora imati izmedju 2 i 120 znakova.")]
    public string Name { get; set; } = string.Empty;

    [StringLength(1000, ErrorMessage = "Opis moze imati najvise 1000 znakova.")]
    public string? Description { get; set; }

    [Range(0.01, 100000, ErrorMessage = "Cijena po danu mora biti izmedju 0.01 i 100000.")]
    public decimal PricePerDay { get; set; }

    [Range(1, 180, ErrorMessage = "Maksimalan broj dana mora biti izmedju 1 i 180.")]
    public int MaxDays { get; set; } = 7;

    [Range(0, 100, ErrorMessage = "Popust mora biti izmedju 0 i 100 posto.")]
    public decimal DiscountPercentage { get; set; }

    [Range(0, 120, ErrorMessage = "Minimalna dob mora biti izmedju 0 i 120 godina.")]
    public int? MinAge { get; set; }

    [Range(0, 120, ErrorMessage = "Maksimalna dob mora biti izmedju 0 i 120 godina.")]
    public int? MaxAge { get; set; }

    public bool IsActive { get; set; } = true;

    [Range(1, int.MaxValue, ErrorMessage = "Odaberite skijaliste iz padajuce liste.")]
    public int SkiResortId { get; set; }

    public IEnumerable<ValidationResult> Validate(ValidationContext validationContext)
    {
        if (MinAge.HasValue && MaxAge.HasValue && MaxAge.Value < MinAge.Value)
        {
            yield return new ValidationResult(
                "Maksimalna dob mora biti veca ili jednaka minimalnoj dobi.",
                [nameof(MaxAge)]);
        }
    }
}

public class TicketTypeSearchDto : PagedRequest
{
    /// <summary>Pretraga po nazivu ili opisu tipa karte.</summary>
    public string? Query { get; set; }
    public int? SkiResortId { get; set; }
    public bool? IsActive { get; set; }

    [Range(0, 100000, ErrorMessage = "Minimalna cijena mora biti izmedju 0 i 100000.")]
    public decimal? MinPricePerDay { get; set; }

    [Range(0, 100000, ErrorMessage = "Maksimalna cijena mora biti izmedju 0 i 100000.")]
    public decimal? MaxPricePerDay { get; set; }
}
