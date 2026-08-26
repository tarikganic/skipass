using System.ComponentModel.DataAnnotations;
using SkiPass.Application.Common;

namespace SkiPass.Application.DTOs.Incidents;

public class IncidentDto
{
    public int Id { get; set; }
    public DateTime ReportedAt { get; set; }
    public string Description { get; set; } = string.Empty;
    public string? ImageUrl { get; set; }
    public double Latitude { get; set; }
    public double Longitude { get; set; }
    public string Status { get; set; } = string.Empty;
    public bool IsUrgent { get; set; }
    public string? ResolutionNote { get; set; }
    public DateTime? HandledAt { get; set; }

    public int ReportedByUserId { get; set; }
    public string ReportedByUserName { get; set; } = string.Empty;
    public string ReportedByUserPhone { get; set; } = string.Empty;

    public int? HandledByUserId { get; set; }
    public string? HandledByUserName { get; set; }

    public int IncidentTypeId { get; set; }
    public string IncidentTypeName { get; set; } = string.Empty;

    public int? TrailId { get; set; }
    public string? TrailName { get; set; }

    public int? SkiLiftId { get; set; }
    public string? SkiLiftName { get; set; }

    /// <summary>Statusi u koje incident moze preci iz trenutnog stanja.</summary>
    public List<string> AllowedNextStatuses { get; set; } = [];
}

public class IncidentCreateDto : IValidatableObject
{
    [Range(1, int.MaxValue, ErrorMessage = "Odaberite tip incidenta iz padajuce liste.")]
    public int IncidentTypeId { get; set; }

    [Required(ErrorMessage = "Opis problema je obavezan.")]
    [StringLength(2000, MinimumLength = 10, ErrorMessage = "Opis problema mora imati izmedju 10 i 2000 znakova.")]
    public string Description { get; set; } = string.Empty;

    [StringLength(500, ErrorMessage = "Putanja do slike moze imati najvise 500 znakova.")]
    public string? ImageUrl { get; set; }

    [Range(-90, 90, ErrorMessage = "Geografska sirina mora biti izmedju -90 i 90.")]
    public double Latitude { get; set; }

    [Range(-180, 180, ErrorMessage = "Geografska duzina mora biti izmedju -180 i 180.")]
    public double Longitude { get; set; }

    public int? TrailId { get; set; }
    public int? SkiLiftId { get; set; }

    public IEnumerable<ValidationResult> Validate(ValidationContext validationContext)
    {
        if (TrailId is null && SkiLiftId is null)
        {
            yield return new ValidationResult(
                "Odaberite stazu ili ski lift na koji se incident odnosi.",
                [nameof(TrailId), nameof(SkiLiftId)]);
        }
    }
}

public class IncidentStatusUpdateDto
{
    [Required(ErrorMessage = "Odaberite novi status incidenta.")]
    public string Status { get; set; } = string.Empty;

    /// <summary>Obrazlozenje rjesavanja ili razlog odbijanja. Obavezno pri zatvaranju prijave.</summary>
    [StringLength(1000, ErrorMessage = "Obrazlozenje moze imati najvise 1000 znakova.")]
    public string? ResolutionNote { get; set; }
}

public class IncidentSearchDto : PagedRequest
{
    /// <summary>Pretraga po opisu incidenta, imenu prijavitelja ili obrazlozenju.</summary>
    public string? Query { get; set; }
    public int? IncidentTypeId { get; set; }
    public int? ReportedByUserId { get; set; }
    public int? TrailId { get; set; }
    public int? SkiLiftId { get; set; }
    public int? SkiResortId { get; set; }
    public string? Status { get; set; }
    public bool? IsUrgent { get; set; }
    public DateTime? ReportedFrom { get; set; }
    public DateTime? ReportedTo { get; set; }
}
