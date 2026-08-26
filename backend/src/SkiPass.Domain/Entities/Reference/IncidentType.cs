namespace SkiPass.Domain.Entities;

/// <summary>Referentna tabela - tip incidenta (povreda, lose stanje staze, kvar lifta, izgubljena osoba).</summary>
public class IncidentType : BaseEntity
{
    public string Name { get; set; } = string.Empty;
    public string? Description { get; set; }

    /// <summary>Incidenti ovog tipa se podrazumijevano tretiraju kao hitni.</summary>
    public bool IsUrgentByDefault { get; set; }

    public virtual ICollection<Incident> Incidents { get; set; } = new List<Incident>();
}
