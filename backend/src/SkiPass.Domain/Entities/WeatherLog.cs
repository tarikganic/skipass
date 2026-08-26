namespace SkiPass.Domain.Entities;

/// <summary>Evidencija vremenskih uslova na skijalistu.</summary>
public class WeatherLog : BaseEntity
{
    public DateTime RecordedAt { get; set; } = DateTime.UtcNow;
    public double TemperatureCelsius { get; set; }
    public double WindSpeedKmh { get; set; }
    public double SnowfallCm { get; set; }
    public int SnowDepthCm { get; set; }

    /// <summary>Kratak opis uslova, npr. suncano ili snijeg sa vjetrom.</summary>
    public string Conditions { get; set; } = string.Empty;
    public int VisibilityMeters { get; set; }

    public int SkiResortId { get; set; }
    public SkiResort SkiResort { get; set; } = null!;
}
