using Microsoft.EntityFrameworkCore;
using SkiPass.Application.DTOs.Announcements;
using SkiPass.Application.DTOs.Benefits;
using SkiPass.Application.DTOs.Home;
using SkiPass.Application.DTOs.Weather;
using SkiPass.Application.Exceptions;
using SkiPass.Application.Services.Interfaces;
using SkiPass.Domain.Enums;
using SkiPass.Domain.Rules;
using SkiPass.Infrastructure.Data;

namespace SkiPass.Infrastructure.Services;

/// <summary>
/// Sastavlja pocetni prikaz mobilne aplikacije. Svaki podatak se dohvata
/// zasebnim agregatnim upitom nad bazom, bez ucitavanja cijelih kolekcija u memoriju.
/// </summary>
public class HomeService : IHomeService
{
    private const int LatestAnnouncementCount = 3;
    private const int FeaturedBenefitCount = 4;

    private readonly ApplicationDbContext _context;

    public HomeService(ApplicationDbContext context)
    {
        _context = context;
    }

    public async Task<HomeSummaryDto> GetSummaryAsync(int userId, int? skiResortId, CancellationToken cancellationToken = default)
    {
        var resort = await _context.SkiResorts
            .Where(r => !r.IsDeleted && r.IsActive)
            .Where(r => skiResortId == null || r.Id == skiResortId)
            .OrderBy(r => r.Id)
            .Select(r => new
            {
                r.Id,
                r.Name,
                r.LogoUrl,
                r.OpeningTime,
                r.ClosingTime
            })
            .FirstOrDefaultAsync(cancellationToken)
            ?? throw new NotFoundException("Nijedno aktivno skijaliste nije pronadjeno.");

        var liftStats = await _context.SkiLifts
            .Where(l => !l.IsDeleted && l.SkiResortId == resort.Id)
            .GroupBy(l => 1)
            .Select(g => new { Total = g.Count(), Operational = g.Count(l => l.IsOperational) })
            .FirstOrDefaultAsync(cancellationToken);

        var trailStats = await _context.Trails
            .Where(t => !t.IsDeleted && t.SkiResortId == resort.Id)
            .GroupBy(t => 1)
            .Select(g => new { Total = g.Count(), Open = g.Count(t => t.IsOpen) })
            .FirstOrDefaultAsync(cancellationToken);

        var weather = await _context.WeatherLogs
            .Where(w => !w.IsDeleted && w.SkiResortId == resort.Id)
            .OrderByDescending(w => w.RecordedAt)
            .Select(w => new WeatherLogDto
            {
                Id = w.Id,
                RecordedAt = w.RecordedAt,
                TemperatureCelsius = w.TemperatureCelsius,
                WindSpeedKmh = w.WindSpeedKmh,
                SnowfallCm = w.SnowfallCm,
                SnowDepthCm = w.SnowDepthCm,
                Conditions = w.Conditions,
                VisibilityMeters = w.VisibilityMeters,
                SkiResortId = w.SkiResortId,
                SkiResortName = resort.Name
            })
            .FirstOrDefaultAsync(cancellationToken);

        var now = DateTime.UtcNow;
        var today = DateOnly.FromDateTime(now);

        var activeTicketCount = await _context.SkiPassTickets
            .CountAsync(
                t => !t.IsDeleted
                     && t.SkiPassOrder.UserId == userId
                     && t.ValidFrom <= today
                     && t.ValidTo >= today
                     && (t.Status == TicketStatus.Active || t.Status == TicketStatus.Used),
                cancellationToken);

        var unreadNotificationCount = await _context.Notifications
            .CountAsync(n => !n.IsDeleted && n.UserId == userId && !n.IsRead, cancellationToken);

        var announcements = await _context.Announcements
            .Where(a => !a.IsDeleted
                        && a.IsActive
                        && a.SkiResortId == resort.Id
                        && a.PublishedAt <= now
                        && (a.ExpiresAt == null || a.ExpiresAt > now))
            .OrderByDescending(a => a.IsUrgent)
            .ThenByDescending(a => a.PublishedAt)
            .Take(LatestAnnouncementCount)
            .Select(a => new AnnouncementDto
            {
                Id = a.Id,
                Title = a.Title,
                Content = a.Content,
                ImageUrl = a.ImageUrl,
                PublishedAt = a.PublishedAt,
                ExpiresAt = a.ExpiresAt,
                IsUrgent = a.IsUrgent,
                IsActive = a.IsActive,
                AnnouncementCategoryId = a.AnnouncementCategoryId,
                AnnouncementCategoryName = a.AnnouncementCategory.Name,
                SkiResortId = a.SkiResortId,
                SkiResortName = a.SkiResort.Name,
                CreatedByUserId = a.CreatedByUserId,
                CreatedByUserName = a.CreatedByUser.FirstName + " " + a.CreatedByUser.LastName
            })
            .AsNoTracking()
            .ToListAsync(cancellationToken);

        // Istaknute pogodnosti su one sa najvecim popustom, pa najbolje ocijenjene.
        var benefits = await _context.Benefits
            .Where(b => !b.IsDeleted && b.IsActive && b.SkiResortId == resort.Id)
            .OrderByDescending(b => b.DiscountPercentage)
            .ThenByDescending(b => b.AverageRating)
            .Take(FeaturedBenefitCount)
            .Select(b => new BenefitDto
            {
                Id = b.Id,
                Name = b.Name,
                Description = b.Description,
                ImageUrl = b.ImageUrl,
                Price = b.Price,
                DiscountPercentage = b.DiscountPercentage,
                EffectivePrice = Math.Round(b.Price * (1 - b.DiscountPercentage / 100m), 2),
                Brand = b.Brand,
                IsActive = b.IsActive,
                AverageRating = b.AverageRating,
                RatingCount = b.RatingCount,
                BenefitCategoryId = b.BenefitCategoryId,
                BenefitCategoryName = b.BenefitCategory.Name,
                SkiResortId = b.SkiResortId,
                SkiResortName = b.SkiResort.Name,
                PartnerId = b.PartnerId,
                PartnerName = b.Partner == null ? null : b.Partner.Name,
                PurchaseCount = b.Purchases.Count(p => !p.IsDeleted && p.Status != OrderStatus.Cancelled)
            })
            .AsNoTracking()
            .ToListAsync(cancellationToken);

        var localTime = TimeOnly.FromDateTime(now);

        return new HomeSummaryDto
        {
            SkiResortId = resort.Id,
            SkiResortName = resort.Name,
            SkiResortLogoUrl = resort.LogoUrl,
            OpeningTime = resort.OpeningTime,
            ClosingTime = resort.ClosingTime,
            IsResortOpen = localTime >= resort.OpeningTime && localTime <= resort.ClosingTime,
            Weather = weather,
            TotalLiftCount = liftStats?.Total ?? 0,
            OperationalLiftCount = liftStats?.Operational ?? 0,
            TotalTrailCount = trailStats?.Total ?? 0,
            OpenTrailCount = trailStats?.Open ?? 0,
            ActiveTicketCount = activeTicketCount,
            UnreadNotificationCount = unreadNotificationCount,
            LatestAnnouncements = announcements,
            FeaturedBenefits = benefits
        };
    }
}
