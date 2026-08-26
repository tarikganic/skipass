using SkiPass.Application.DTOs.Announcements;
using SkiPass.Application.DTOs.Benefits;
using SkiPass.Application.DTOs.Weather;

namespace SkiPass.Application.DTOs.Home;

/// <summary>
/// Objedinjeni podaci za pocetnu stranicu mobilne aplikacije.
/// Vraca se jednim pozivom kako klijent ne bi pravio sest odvojenih zahtjeva
/// pri svakom otvaranju aplikacije.
/// </summary>
public class HomeSummaryDto
{
    public int SkiResortId { get; set; }
    public string SkiResortName { get; set; } = string.Empty;
    public string? SkiResortLogoUrl { get; set; }
    public TimeOnly OpeningTime { get; set; }
    public TimeOnly ClosingTime { get; set; }
    public bool IsResortOpen { get; set; }

    public WeatherLogDto? Weather { get; set; }

    public int TotalLiftCount { get; set; }
    public int OperationalLiftCount { get; set; }
    public int TotalTrailCount { get; set; }
    public int OpenTrailCount { get; set; }

    /// <summary>Broj karata prijavljenog korisnika koje su trenutno upotrebljive.</summary>
    public int ActiveTicketCount { get; set; }
    public int UnreadNotificationCount { get; set; }

    public List<AnnouncementDto> LatestAnnouncements { get; set; } = [];
    public List<BenefitDto> FeaturedBenefits { get; set; } = [];
}
