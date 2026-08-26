using System.ComponentModel.DataAnnotations;
using SkiPass.Application.Common;

namespace SkiPass.Application.DTOs.Resorts;

public class SkiResortDto
{
    public int Id { get; set; }
    public string Name { get; set; } = string.Empty;
    public string Description { get; set; } = string.Empty;
    public string? LogoUrl { get; set; }
    public string? ContactEmail { get; set; }
    public string? ContactPhone { get; set; }
    public double Latitude { get; set; }
    public double Longitude { get; set; }
    public int BaseAltitudeMeters { get; set; }
    public int PeakAltitudeMeters { get; set; }
    public TimeOnly OpeningTime { get; set; }
    public TimeOnly ClosingTime { get; set; }
    public bool IsActive { get; set; }
    public int CityId { get; set; }
    public string CityName { get; set; } = string.Empty;
    public int TrailCount { get; set; }
    public int OpenTrailCount { get; set; }
    public int SkiLiftCount { get; set; }
    public int OperationalLiftCount { get; set; }
}

public class SkiResortUpsertDto : IValidatableObject
{
    [Required(ErrorMessage = "Naziv skijalista je obavezan.")]
    [StringLength(150, MinimumLength = 2, ErrorMessage = "Naziv mora imati izmedju 2 i 150 znakova.")]
    public string Name { get; set; } = string.Empty;

    [Required(ErrorMessage = "Opis skijalista je obavezan.")]
    [StringLength(2000, MinimumLength = 10, ErrorMessage = "Opis mora imati izmedju 10 i 2000 znakova.")]
    public string Description { get; set; } = string.Empty;

    [StringLength(500, ErrorMessage = "Putanja do logotipa moze imati najvise 500 znakova.")]
    public string? LogoUrl { get; set; }

    [EmailAddress(ErrorMessage = "Unesite validnu e-mail adresu u formatu: info@domena.ba")]
    public string? ContactEmail { get; set; }

    [RegularExpression(@"^\+?[0-9\s/-]{6,20}$", ErrorMessage = "Unesite validan broj telefona u formatu: +387 36 123 456")]
    public string? ContactPhone { get; set; }

    [Range(-90, 90, ErrorMessage = "Geografska sirina mora biti izmedju -90 i 90.")]
    public double Latitude { get; set; }

    [Range(-180, 180, ErrorMessage = "Geografska duzina mora biti izmedju -180 i 180.")]
    public double Longitude { get; set; }

    [Range(0, 9000, ErrorMessage = "Nadmorska visina baze mora biti izmedju 0 i 9000 metara.")]
    public int BaseAltitudeMeters { get; set; }

    [Range(0, 9000, ErrorMessage = "Nadmorska visina vrha mora biti izmedju 0 i 9000 metara.")]
    public int PeakAltitudeMeters { get; set; }

    public TimeOnly OpeningTime { get; set; }
    public TimeOnly ClosingTime { get; set; }

    [Range(1, int.MaxValue, ErrorMessage = "Odaberite grad iz padajuce liste.")]
    public int CityId { get; set; }

    public bool IsActive { get; set; } = true;

    public IEnumerable<ValidationResult> Validate(ValidationContext validationContext)
    {
        if (PeakAltitudeMeters <= BaseAltitudeMeters)
        {
            yield return new ValidationResult(
                "Nadmorska visina vrha mora biti veca od nadmorske visine baze.",
                [nameof(PeakAltitudeMeters)]);
        }

        if (ClosingTime <= OpeningTime)
        {
            yield return new ValidationResult(
                "Vrijeme zatvaranja mora biti nakon vremena otvaranja.",
                [nameof(ClosingTime)]);
        }
    }
}

public class SkiResortSearchDto : PagedRequest
{
    /// <summary>Pretraga po nazivu ili opisu skijalista.</summary>
    public string? Query { get; set; }
    public int? CityId { get; set; }
    public bool? IsActive { get; set; }
}
