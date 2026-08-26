namespace SkiPass.Domain.Entities;

/// <summary>
/// Obavijest skijalista (news). Sadrzi naslov, tekst, sliku i datum objave.
/// </summary>
public class Announcement : BaseEntity
{
    public string Title { get; set; } = string.Empty;
    public string Content { get; set; } = string.Empty;
    public string? ImageUrl { get; set; }
    public DateTime PublishedAt { get; set; } = DateTime.UtcNow;
    public DateTime? ExpiresAt { get; set; }
    public bool IsUrgent { get; set; }
    public bool IsActive { get; set; } = true;

    public int AnnouncementCategoryId { get; set; }
    public AnnouncementCategory AnnouncementCategory { get; set; } = null!;

    public int SkiResortId { get; set; }
    public SkiResort SkiResort { get; set; } = null!;

    public int CreatedByUserId { get; set; }
    public User CreatedByUser { get; set; } = null!;
}
