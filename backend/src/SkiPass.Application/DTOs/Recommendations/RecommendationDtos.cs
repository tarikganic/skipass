namespace SkiPass.Application.DTOs.Recommendations;

public static class RecommendationReasonCodes
{
    public const string PurchasedCategory = "PurchasedCategory";
    public const string ViewedCategory = "ViewedCategory";
    public const string UsedPartner = "UsedPartner";
    public const string PreferredBrand = "PreferredBrand";
    public const string PopularFallback = "PopularFallback";
}

public class RecommendationReasonDto
{
    public string Code { get; set; } = string.Empty;
    public string? CategoryName { get; set; }
    public string? PartnerName { get; set; }
    public string? Brand { get; set; }
}

public class RecommendedBenefitDto
{
    public int Id { get; set; }
    public string Name { get; set; } = string.Empty;
    public string Description { get; set; } = string.Empty;
    public string? ImageUrl { get; set; }
    public decimal Price { get; set; }
    public decimal DiscountPercentage { get; set; }
    public decimal EffectivePrice { get; set; }
    public string? Brand { get; set; }
    public double AverageRating { get; set; }
    public int RatingCount { get; set; }
    public int BenefitCategoryId { get; set; }
    public string BenefitCategoryName { get; set; } = string.Empty;
    public int SkiResortId { get; set; }
    public string SkiResortName { get; set; } = string.Empty;
    public int? PartnerId { get; set; }
    public string? PartnerName { get; set; }
    public double Score { get; set; }
    public List<RecommendationReasonDto> Reasons { get; set; } = [];
}
