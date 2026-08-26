using System.ComponentModel.DataAnnotations;
using SkiPass.Application.Common;

namespace SkiPass.Application.DTOs.Weather;

public class WeatherLogDto
{
    public int Id { get; set; }
    public DateTime RecordedAt { get; set; }
    public double TemperatureCelsius { get; set; }
    public double WindSpeedKmh { get; set; }
    public double SnowfallCm { get; set; }
    public int SnowDepthCm { get; set; }
    public string Conditions { get; set; } = string.Empty;
    public int VisibilityMeters { get; set; }

    public int SkiResortId { get; set; }
    public string SkiResortName { get; set; } = string.Empty;
}

public class WeatherLogUpsertDto
{
    [Required(ErrorMessage = "Datum i vrijeme mjerenja su obavezni.")]
    public DateTime RecordedAt { get; set; }

    [Range(-60, 50, ErrorMessage = "Temperatura mora biti izmedju -60 i 50 stepeni Celzijusa.")]
    public double TemperatureCelsius { get; set; }

    [Range(0, 300, ErrorMessage = "Brzina vjetra mora biti izmedju 0 i 300 km/h.")]
    public double WindSpeedKmh { get; set; }

    [Range(0, 300, ErrorMessage = "Kolicina snijega mora biti izmedju 0 i 300 cm.")]
    public double SnowfallCm { get; set; }

    [Range(0, 800, ErrorMessage = "Snjezni pokrivac mora biti izmedju 0 i 800 cm.")]
    public int SnowDepthCm { get; set; }

    [Required(ErrorMessage = "Opis vremenskih uslova je obavezan.")]
    [StringLength(200, MinimumLength = 3, ErrorMessage = "Opis mora imati izmedju 3 i 200 znakova.")]
    public string Conditions { get; set; } = string.Empty;

    [Range(0, 50000, ErrorMessage = "Vidljivost mora biti izmedju 0 i 50000 metara.")]
    public int VisibilityMeters { get; set; }

    [Range(1, int.MaxValue, ErrorMessage = "Odaberite skijaliste iz padajuce liste.")]
    public int SkiResortId { get; set; }
}

public class WeatherLogSearchDto : PagedRequest
{
    /// <summary>Pretraga po opisu vremenskih uslova.</summary>
    public string? Query { get; set; }
    public int? SkiResortId { get; set; }
    public DateTime? RecordedFrom { get; set; }
    public DateTime? RecordedTo { get; set; }
}
