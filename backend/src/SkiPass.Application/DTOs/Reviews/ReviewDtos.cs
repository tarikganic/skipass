using System.ComponentModel.DataAnnotations;
using SkiPass.Application.Common;

namespace SkiPass.Application.DTOs.Reviews;

public class ReviewDto
{
    public int Id { get; set; }
    public int Rating { get; set; }
    public string? Comment { get; set; }
    public string TargetType { get; set; } = string.Empty;
    public DateTime CreatedAt { get; set; }

    public int UserId { get; set; }
    public string UserFullName { get; set; } = string.Empty;
    public string? UserProfileImageUrl { get; set; }

    public int? TrailId { get; set; }
    public string? TrailName { get; set; }

    public int? BenefitId { get; set; }
    public string? BenefitName { get; set; }

    public int? SkiResortId { get; set; }
    public string? SkiResortName { get; set; }
}

public class ReviewCreateDto : IValidatableObject
{
    [Range(1, 5, ErrorMessage = "Ocjena mora biti izmedju 1 i 5.")]
    public int Rating { get; set; }

    [StringLength(1000, ErrorMessage = "Komentar moze imati najvise 1000 znakova.")]
    public string? Comment { get; set; }

    [Required(ErrorMessage = "Odaberite sta ocjenjujete.")]
    public string TargetType { get; set; } = string.Empty;

    public int? TrailId { get; set; }
    public int? BenefitId { get; set; }
    public int? SkiResortId { get; set; }

    public IEnumerable<ValidationResult> Validate(ValidationContext validationContext)
    {
        var selectedTargets = new[] { TrailId, BenefitId, SkiResortId }.Count(id => id.HasValue);

        if (selectedTargets != 1)
        {
            yield return new ValidationResult(
                "Ocjena se mora odnositi na tacno jednu stavku: stazu, pogodnost ili skijaliste.",
                [nameof(TrailId), nameof(BenefitId), nameof(SkiResortId)]);
        }
    }
}

public class ReviewUpdateDto
{
    [Range(1, 5, ErrorMessage = "Ocjena mora biti izmedju 1 i 5.")]
    public int Rating { get; set; }

    [StringLength(1000, ErrorMessage = "Komentar moze imati najvise 1000 znakova.")]
    public string? Comment { get; set; }
}

public class ReviewSearchDto : PagedRequest
{
    /// <summary>Pretraga po komentaru ili imenu korisnika.</summary>
    public string? Query { get; set; }
    public int? UserId { get; set; }
    public string? TargetType { get; set; }
    public int? TrailId { get; set; }
    public int? BenefitId { get; set; }
    public int? SkiResortId { get; set; }

    [Range(1, 5, ErrorMessage = "Minimalna ocjena mora biti izmedju 1 i 5.")]
    public int? MinRating { get; set; }

    [Range(1, 5, ErrorMessage = "Maksimalna ocjena mora biti izmedju 1 i 5.")]
    public int? MaxRating { get; set; }
}
