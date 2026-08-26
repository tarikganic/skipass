namespace SkiPass.Domain.Entities;

/// <summary>Referentna tabela - drzave koje se koriste za gradove i partnere.</summary>
public class Country : BaseEntity
{
    public string Name { get; set; } = string.Empty;
    public string IsoCode { get; set; } = string.Empty;

    public virtual ICollection<City> Cities { get; set; } = new List<City>();
}
