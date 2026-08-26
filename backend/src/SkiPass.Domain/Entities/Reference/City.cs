namespace SkiPass.Domain.Entities;

/// <summary>Referentna tabela - gradovi za adrese korisnika, skijalista i partnera.</summary>
public class City : BaseEntity
{
    public string Name { get; set; } = string.Empty;
    public string? PostalCode { get; set; }

    public int CountryId { get; set; }
    public Country Country { get; set; } = null!;

    public virtual ICollection<User> Users { get; set; } = new List<User>();
    public virtual ICollection<SkiResort> SkiResorts { get; set; } = new List<SkiResort>();
    public virtual ICollection<Partner> Partners { get; set; } = new List<Partner>();
}
