namespace SkiPass.Domain.Entities;

/// <summary>Partnerska firma koja pruza dodatne usluge korisnicima skijalista.</summary>
public class Partner : BaseEntity
{
    public string Name { get; set; } = string.Empty;
    public string? Description { get; set; }
    public string? ContactEmail { get; set; }
    public string? ContactPhone { get; set; }
    public string? Website { get; set; }
    public string? LogoUrl { get; set; }
    public string? Address { get; set; }
    public bool IsActive { get; set; } = true;

    public int? CityId { get; set; }
    public City? City { get; set; }

    public virtual ICollection<Benefit> Benefits { get; set; } = new List<Benefit>();
}
