namespace SkiPass.Domain.Entities;

/// <summary>Evidencija stanja staze - snjezni pokrivac, uslovi i eventualno zatvaranje.</summary>
public class TrailConditionLog : BaseEntity
{
    public DateTime RecordedAt { get; set; } = DateTime.UtcNow;
    public int SnowDepthCm { get; set; }

    /// <summary>Opis uslova, npr. "poledica na donjem dijelu staze".</summary>
    public string ConditionNote { get; set; } = string.Empty;

    /// <summary>Status staze u trenutku evidentiranja.</summary>
    public bool IsTrailOpen { get; set; }

    public int TrailId { get; set; }
    public Trail Trail { get; set; } = null!;

    public int RecordedByUserId { get; set; }
    public User RecordedByUser { get; set; } = null!;
}
