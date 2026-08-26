namespace SkiPass.Domain.Entities;

/// <summary>Referentna tabela - kategorija obavijesti (vremenski uslovi, zatvaranje staza, akcije).</summary>
public class AnnouncementCategory : BaseEntity
{
    public string Name { get; set; } = string.Empty;
    public string? Description { get; set; }

    public virtual ICollection<Announcement> Announcements { get; set; } = new List<Announcement>();
}
