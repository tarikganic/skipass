using SkiPass.Domain.Enums;

namespace SkiPass.Domain.Entities;

/// <summary>Ski staza sa trenutnim statusom, tezinom i procijenjenom guzvom.</summary>
public class Trail : BaseEntity
{
    public string Name { get; set; } = string.Empty;
    public string Code { get; set; } = string.Empty;
    public string? Description { get; set; }
    public string? ImageUrl { get; set; }

    public int LengthMeters { get; set; }
    public int VerticalDropMeters { get; set; }
    public bool IsOpen { get; set; } = true;
    public bool HasNightSkiing { get; set; }
    public bool HasSnowmaking { get; set; }
    public CrowdLevel EstimatedCrowdLevel { get; set; } = CrowdLevel.Low;

    public int SkiResortId { get; set; }
    public SkiResort SkiResort { get; set; } = null!;

    public int TrailDifficultyId { get; set; }
    public TrailDifficulty TrailDifficulty { get; set; } = null!;

    public virtual ICollection<TrailConditionLog> ConditionLogs { get; set; } = new List<TrailConditionLog>();
    public virtual ICollection<Incident> Incidents { get; set; } = new List<Incident>();
    public virtual ICollection<Review> Reviews { get; set; } = new List<Review>();
}
