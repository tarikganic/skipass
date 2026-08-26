using Microsoft.EntityFrameworkCore;
using SkiPass.Application.DTOs.Recommendations;
using SkiPass.Application.Services.Interfaces;
using SkiPass.Domain.Entities;
using SkiPass.Infrastructure.Data;

namespace SkiPass.Infrastructure.Services;

public class RecommenderService : IRecommenderService
{
    private const int MaxSignalCategories = 3;
    private const double PurchasedCategoryWeight = 3;
    private const double ViewedCategoryWeight = 2;
    private const double UsedPartnerWeight = 2;
    private const double PreferredBrandWeight = 2;

    private readonly ApplicationDbContext _context;

    public RecommenderService(ApplicationDbContext context)
    {
        _context = context;
    }

    public async Task<List<RecommendedBenefitDto>> GetRecommendedBenefitsAsync(int userId, int take, CancellationToken cancellationToken = default)
    {
        var purchasedBenefitIds = await _context.BenefitPurchases
            .Where(p => p.UserId == userId)
            .Select(p => p.BenefitId)
            .Distinct()
            .ToListAsync(cancellationToken);

        var purchasedCategoryIds = await _context.BenefitPurchases
            .Where(p => p.UserId == userId)
            .GroupBy(p => p.Benefit.BenefitCategoryId)
            .OrderByDescending(g => g.Count())
            .Take(MaxSignalCategories)
            .Select(g => g.Key)
            .ToListAsync(cancellationToken);

        var viewedCategoryIds = await _context.BenefitViews
            .Where(v => v.UserId == userId)
            .GroupBy(v => v.Benefit.BenefitCategoryId)
            .OrderByDescending(g => g.Sum(v => v.DurationSeconds) + g.Count())
            .Take(MaxSignalCategories)
            .Select(g => g.Key)
            .ToListAsync(cancellationToken);

        var usedPartnerIds = await _context.BenefitPurchases
            .Where(p => p.UserId == userId && p.Benefit.PartnerId != null)
            .Select(p => p.Benefit.PartnerId!.Value)
            .Union(_context.BenefitViews
                .Where(v => v.UserId == userId && v.Benefit.PartnerId != null)
                .Select(v => v.Benefit.PartnerId!.Value))
            .Distinct()
            .ToListAsync(cancellationToken);

        var preferredBrand = await _context.BenefitPurchases
            .Where(p => p.UserId == userId && p.Benefit.Brand != null)
            .Select(p => p.Benefit.Brand!)
            .Concat(_context.BenefitViews
                .Where(v => v.UserId == userId && v.Benefit.Brand != null)
                .Select(v => v.Benefit.Brand!))
            .GroupBy(b => b)
            .OrderByDescending(g => g.Count())
            .Select(g => g.Key)
            .FirstOrDefaultAsync(cancellationToken);

        var candidates = await _context.Benefits
            .Where(b => !b.IsDeleted && b.IsActive && !purchasedBenefitIds.Contains(b.Id))
            .Include(b => b.BenefitCategory)
            .Include(b => b.SkiResort)
            .Include(b => b.Partner)
            .AsNoTracking()
            .ToListAsync(cancellationToken);

        var scored = new List<RecommendedBenefitDto>();
        foreach (var benefit in candidates)
        {
            var reasons = new List<RecommendationReasonDto>();
            double score = 0;

            if (purchasedCategoryIds.Contains(benefit.BenefitCategoryId))
            {
                score += PurchasedCategoryWeight;
                reasons.Add(new RecommendationReasonDto { Code = RecommendationReasonCodes.PurchasedCategory, CategoryName = benefit.BenefitCategory.Name });
            }
            else if (viewedCategoryIds.Contains(benefit.BenefitCategoryId))
            {
                score += ViewedCategoryWeight;
                reasons.Add(new RecommendationReasonDto { Code = RecommendationReasonCodes.ViewedCategory, CategoryName = benefit.BenefitCategory.Name });
            }

            if (benefit.PartnerId.HasValue && usedPartnerIds.Contains(benefit.PartnerId.Value))
            {
                score += UsedPartnerWeight;
                reasons.Add(new RecommendationReasonDto { Code = RecommendationReasonCodes.UsedPartner, PartnerName = benefit.Partner?.Name });
            }

            if (preferredBrand != null && benefit.Brand == preferredBrand)
            {
                score += PreferredBrandWeight;
                reasons.Add(new RecommendationReasonDto { Code = RecommendationReasonCodes.PreferredBrand, Brand = benefit.Brand });
            }

            if (score > 0)
            {
                scored.Add(MapToDto(benefit, score, reasons));
            }
        }

        if (scored.Count > 0)
        {
            return scored
                .OrderByDescending(b => b.Score)
                .ThenByDescending(b => b.AverageRating)
                .Take(take)
                .ToList();
        }

        return candidates
            .OrderByDescending(b => b.AverageRating)
            .ThenByDescending(b => b.RatingCount)
            .Take(take)
            .Select(b => MapToDto(b, 0, [new RecommendationReasonDto { Code = RecommendationReasonCodes.PopularFallback }]))
            .ToList();
    }

    private static RecommendedBenefitDto MapToDto(Benefit benefit, double score, List<RecommendationReasonDto> reasons) => new()
    {
        Id = benefit.Id,
        Name = benefit.Name,
        Description = benefit.Description,
        ImageUrl = benefit.ImageUrl,
        Price = benefit.Price,
        DiscountPercentage = benefit.DiscountPercentage,
        EffectivePrice = BenefitService.CalculateEffectivePrice(benefit.Price, benefit.DiscountPercentage),
        Brand = benefit.Brand,
        AverageRating = benefit.AverageRating,
        RatingCount = benefit.RatingCount,
        BenefitCategoryId = benefit.BenefitCategoryId,
        BenefitCategoryName = benefit.BenefitCategory.Name,
        SkiResortId = benefit.SkiResortId,
        SkiResortName = benefit.SkiResort.Name,
        PartnerId = benefit.PartnerId,
        PartnerName = benefit.Partner?.Name,
        Score = score,
        Reasons = reasons
    };
}
