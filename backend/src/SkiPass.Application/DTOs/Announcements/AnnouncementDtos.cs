using System.ComponentModel.DataAnnotations;
using SkiPass.Application.Common;

namespace SkiPass.Application.DTOs.Announcements;

public class AnnouncementDto
{
    public int Id { get; set; }
    public string Title { get; set; } = string.Empty;
    public string Content { get; set; } = string.Empty;
    public string? ImageUrl { get; set; }
    public DateTime PublishedAt { get; set; }
    public DateTime? ExpiresAt { get; set; }
    public bool IsUrgent { get; set; }
    public bool IsActive { get; set; }

    public int AnnouncementCategoryId { get; set; }
    public string AnnouncementCategoryName { get; set; } = string.Empty;

    public int SkiResortId { get; set; }
    public string SkiResortName { get; set; } = string.Empty;

    public int CreatedByUserId { get; set; }
    public string CreatedByUserName { get; set; } = string.Empty;
}

public class AnnouncementUpsertDto : IValidatableObject
{
    [Required(ErrorMessage = "Naslov obavijesti je obavezan.")]
    [StringLength(200, MinimumLength = 3, ErrorMessage = "Naslov mora imati izmedju 3 i 200 znakova.")]
    public string Title { get; set; } = string.Empty;

    [Required(ErrorMessage = "Tekst obavijesti je obavezan.")]
    [StringLength(5000, MinimumLength = 10, ErrorMessage = "Tekst mora imati izmedju 10 i 5000 znakova.")]
    public string Content { get; set; } = string.Empty;

    [StringLength(500, ErrorMessage = "Putanja do slike moze imati najvise 500 znakova.")]
    public string? ImageUrl { get; set; }

    [Required(ErrorMessage = "Datum objave je obavezan.")]
    public DateTime PublishedAt { get; set; }

    public DateTime? ExpiresAt { get; set; }

    public bool IsUrgent { get; set; }
    public bool IsActive { get; set; } = true;

    [Range(1, int.MaxValue, ErrorMessage = "Odaberite kategoriju obavijesti iz padajuce liste.")]
    public int AnnouncementCategoryId { get; set; }

    [Range(1, int.MaxValue, ErrorMessage = "Odaberite skijaliste iz padajuce liste.")]
    public int SkiResortId { get; set; }

    public IEnumerable<ValidationResult> Validate(ValidationContext validationContext)
    {
        if (ExpiresAt.HasValue && ExpiresAt.Value <= PublishedAt)
        {
            yield return new ValidationResult(
                "Datum isteka mora biti nakon datuma objave.",
                [nameof(ExpiresAt)]);
        }
    }
}

public class AnnouncementSearchDto : PagedRequest
{
    /// <summary>Pretraga po naslovu ili tekstu obavijesti.</summary>
    public string? Query { get; set; }
    public int? AnnouncementCategoryId { get; set; }
    public int? SkiResortId { get; set; }
    public bool? IsUrgent { get; set; }
    public bool? IsActive { get; set; }

    /// <summary>Prikazuje samo obavijesti koje su trenutno objavljene i nisu istekle.</summary>
    public bool? CurrentlyVisible { get; set; }

    public DateTime? PublishedFrom { get; set; }
    public DateTime? PublishedTo { get; set; }
}
