namespace SkiPass.Domain.Entities;

/// <summary>Skijaliste - krovni entitet koji objedinjuje staze, liftove, karte i pogodnosti.</summary>
public class SkiResort : BaseEntity
{
    public string Name { get; set; } = string.Empty;
    public string Description { get; set; } = string.Empty;
    public string? LogoUrl { get; set; }
    public string? ContactEmail { get; set; }
    public string? ContactPhone { get; set; }

    public double Latitude { get; set; }
    public double Longitude { get; set; }

    /// <summary>Nadmorska visina baze skijalista u metrima.</summary>
    public int BaseAltitudeMeters { get; set; }

    /// <summary>Nadmorska visina vrha skijalista u metrima.</summary>
    public int PeakAltitudeMeters { get; set; }

    public TimeOnly OpeningTime { get; set; } = new(08, 30);
    public TimeOnly ClosingTime { get; set; } = new(16, 00);
    public bool IsActive { get; set; } = true;

    public int CityId { get; set; }
    public City City { get; set; } = null!;

    public virtual ICollection<Trail> Trails { get; set; } = new List<Trail>();
    public virtual ICollection<SkiLift> SkiLifts { get; set; } = new List<SkiLift>();
    public virtual ICollection<TicketType> TicketTypes { get; set; } = new List<TicketType>();
    public virtual ICollection<Benefit> Benefits { get; set; } = new List<Benefit>();
    public virtual ICollection<WeatherLog> WeatherLogs { get; set; } = new List<WeatherLog>();
    public virtual ICollection<Announcement> Announcements { get; set; } = new List<Announcement>();
}
