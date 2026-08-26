namespace SkiPass.Domain.Entities;

/// <summary>Referentna tabela - tezina staze (plava, crvena, crna).</summary>
public class TrailDifficulty : BaseEntity
{
    public string Name { get; set; } = string.Empty;
    public string? Description { get; set; }

    /// <summary>Boja oznake staze u HEX formatu, koristi se za prikaz na klijentima.</summary>
    public string ColorHex { get; set; } = "#000000";

    /// <summary>Redoslijed prikaza - od najlakse ka najtezoj stazi.</summary>
    public int SortOrder { get; set; }

    public virtual ICollection<Trail> Trails { get; set; } = new List<Trail>();
}
