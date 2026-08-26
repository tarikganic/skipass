namespace SkiPass.Domain.Entities;

/// <summary>Ski lift sa statusom rada i trenutnim brojem korisnika.</summary>
public class SkiLift : BaseEntity
{
    public string Name { get; set; } = string.Empty;
    public string Code { get; set; } = string.Empty;
    public string? Description { get; set; }

    public int LengthMeters { get; set; }
    public int CapacityPerHour { get; set; }
    public int RideDurationMinutes { get; set; }
    public bool IsOperational { get; set; } = true;

    /// <summary>Broj korisnika koji trenutno koriste lift - azurira se QR validacijom.</summary>
    public int CurrentRiders { get; set; }
    public DateTime? LastMaintenanceAt { get; set; }

    public int SkiResortId { get; set; }
    public SkiResort SkiResort { get; set; } = null!;

    public int LiftTypeId { get; set; }
    public LiftType LiftType { get; set; } = null!;

    public virtual ICollection<LiftMaintenanceRecord> MaintenanceRecords { get; set; } = new List<LiftMaintenanceRecord>();
    public virtual ICollection<TicketValidation> Validations { get; set; } = new List<TicketValidation>();
    public virtual ICollection<Incident> Incidents { get; set; } = new List<Incident>();
}
