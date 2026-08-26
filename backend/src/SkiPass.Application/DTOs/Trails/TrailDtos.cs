using System.ComponentModel.DataAnnotations;
using SkiPass.Application.Common;

namespace SkiPass.Application.DTOs.Trails;

public class TrailDto
{
    public int Id { get; set; }
    public string Name { get; set; } = string.Empty;
    public string Code { get; set; } = string.Empty;
    public string? Description { get; set; }
    public string? ImageUrl { get; set; }
    public int LengthMeters { get; set; }
    public int VerticalDropMeters { get; set; }
    public bool IsOpen { get; set; }
    public bool HasNightSkiing { get; set; }
    public bool HasSnowmaking { get; set; }
    public string EstimatedCrowdLevel { get; set; } = string.Empty;

    public int SkiResortId { get; set; }
    public string SkiResortName { get; set; } = string.Empty;

    public int TrailDifficultyId { get; set; }
    public string TrailDifficultyName { get; set; } = string.Empty;
    public string TrailDifficultyColorHex { get; set; } = string.Empty;

    /// <summary>Posljednje evidentirano stanje staze - prikazuje se u mobilnoj aplikaciji.</summary>
    public int? LatestSnowDepthCm { get; set; }
    public string? LatestConditionNote { get; set; }
    public DateTime? LatestConditionRecordedAt { get; set; }

    public double AverageRating { get; set; }
    public int ReviewCount { get; set; }
    public int OpenIncidentCount { get; set; }
}

public class TrailUpsertDto
{
    [Required(ErrorMessage = "Naziv staze je obavezan.")]
    [StringLength(150, MinimumLength = 2, ErrorMessage = "Naziv staze mora imati izmedju 2 i 150 znakova.")]
    public string Name { get; set; } = string.Empty;

    [Required(ErrorMessage = "Oznaka staze je obavezna.")]
    [RegularExpression("^[A-Z0-9-]{2,20}$", ErrorMessage = "Oznaka staze moze sadrzavati velika slova, cifre i crticu, npr. STAZA-01.")]
    public string Code { get; set; } = string.Empty;

    [StringLength(1500, ErrorMessage = "Opis moze imati najvise 1500 znakova.")]
    public string? Description { get; set; }

    [StringLength(500, ErrorMessage = "Putanja do slike moze imati najvise 500 znakova.")]
    public string? ImageUrl { get; set; }

    [Range(50, 50000, ErrorMessage = "Duzina staze mora biti izmedju 50 i 50000 metara.")]
    public int LengthMeters { get; set; }

    [Range(0, 3000, ErrorMessage = "Visinska razlika mora biti izmedju 0 i 3000 metara.")]
    public int VerticalDropMeters { get; set; }

    public bool IsOpen { get; set; } = true;
    public bool HasNightSkiing { get; set; }
    public bool HasSnowmaking { get; set; }

    [Range(1, int.MaxValue, ErrorMessage = "Odaberite skijaliste iz padajuce liste.")]
    public int SkiResortId { get; set; }

    [Range(1, int.MaxValue, ErrorMessage = "Odaberite tezinu staze iz padajuce liste.")]
    public int TrailDifficultyId { get; set; }
}

/// <summary>Brza promjena statusa staze i procijenjene guzve bez uredjivanja cijelog zapisa.</summary>
public class TrailStatusUpdateDto
{
    public bool IsOpen { get; set; }

    [Required(ErrorMessage = "Odaberite procijenjenu guzvu na stazi.")]
    public string EstimatedCrowdLevel { get; set; } = string.Empty;
}

public class TrailSearchDto : PagedRequest
{
    /// <summary>Pretraga po nazivu, oznaci ili opisu staze.</summary>
    public string? Query { get; set; }
    public int? SkiResortId { get; set; }
    public int? TrailDifficultyId { get; set; }
    public bool? IsOpen { get; set; }
    public bool? HasNightSkiing { get; set; }

    [Range(0, 50000, ErrorMessage = "Minimalna duzina mora biti izmedju 0 i 50000 metara.")]
    public int? MinLengthMeters { get; set; }

    [Range(0, 50000, ErrorMessage = "Maksimalna duzina mora biti izmedju 0 i 50000 metara.")]
    public int? MaxLengthMeters { get; set; }
}

public class TrailConditionLogDto
{
    public int Id { get; set; }
    public DateTime RecordedAt { get; set; }
    public int SnowDepthCm { get; set; }
    public string ConditionNote { get; set; } = string.Empty;
    public bool IsTrailOpen { get; set; }
    public int TrailId { get; set; }
    public string TrailName { get; set; } = string.Empty;
    public int RecordedByUserId { get; set; }
    public string RecordedByUserName { get; set; } = string.Empty;
}

public class TrailConditionLogCreateDto
{
    [Range(1, int.MaxValue, ErrorMessage = "Odaberite stazu iz padajuce liste.")]
    public int TrailId { get; set; }

    [Range(0, 800, ErrorMessage = "Snjezni pokrivac mora biti izmedju 0 i 800 cm.")]
    public int SnowDepthCm { get; set; }

    [Required(ErrorMessage = "Opis uslova na stazi je obavezan.")]
    [StringLength(500, MinimumLength = 3, ErrorMessage = "Opis uslova mora imati izmedju 3 i 500 znakova.")]
    public string ConditionNote { get; set; } = string.Empty;

    public bool IsTrailOpen { get; set; } = true;
}

public class TrailConditionLogSearchDto : PagedRequest
{
    /// <summary>Pretraga po opisu evidentiranih uslova.</summary>
    public string? Query { get; set; }
    public int? TrailId { get; set; }
    public int? SkiResortId { get; set; }
    public DateTime? RecordedFrom { get; set; }
    public DateTime? RecordedTo { get; set; }
}
