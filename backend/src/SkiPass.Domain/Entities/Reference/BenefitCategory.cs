namespace SkiPass.Domain.Entities;

/// <summary>Referentna tabela - kategorija pogodnosti (iznajmljivanje opreme, ugostiteljstvo, skola skijanja).</summary>
public class BenefitCategory : BaseEntity
{
    public string Name { get; set; } = string.Empty;
    public string? Description { get; set; }
    public string? IconName { get; set; }

    public virtual ICollection<Benefit> Benefits { get; set; } = new List<Benefit>();
}
