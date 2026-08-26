using SkiPass.Domain.Enums;

namespace SkiPass.Domain.Entities;

/// <summary>Evidencija kvara ili planiranog odrzavanja ski lifta.</summary>
public class LiftMaintenanceRecord : BaseEntity
{
    public DateTime ReportedAt { get; set; } = DateTime.UtcNow;
    public DateTime? ResolvedAt { get; set; }
    public string Description { get; set; } = string.Empty;
    public string? ResolutionNote { get; set; }
    public MaintenanceStatus Status { get; set; } = MaintenanceStatus.Reported;

    /// <summary>Da li kvar zahtijeva obustavu rada lifta.</summary>
    public bool RequiresShutdown { get; set; }

    public int SkiLiftId { get; set; }
    public SkiLift SkiLift { get; set; } = null!;

    public int ReportedByUserId { get; set; }
    public User ReportedByUser { get; set; } = null!;

    public int? ResolvedByUserId { get; set; }
    public User? ResolvedByUser { get; set; }
}
