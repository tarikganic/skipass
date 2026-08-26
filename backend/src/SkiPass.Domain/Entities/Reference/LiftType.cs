namespace SkiPass.Domain.Entities;

/// <summary>Referentna tabela - tip ski lifta (sidro, sjedeznica, gondola).</summary>
public class LiftType : BaseEntity
{
    public string Name { get; set; } = string.Empty;
    public string? Description { get; set; }

    public virtual ICollection<SkiLift> SkiLifts { get; set; } = new List<SkiLift>();
}
