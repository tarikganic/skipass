using SkiPass.Domain.Enums;

namespace SkiPass.Domain.Entities;

/// <summary>
/// Incident prijavljen sa mobilne aplikacije: povreda, lose stanje staze, kvar lifta ili izgubljena osoba.
/// </summary>
public class Incident : BaseEntity
{
    public DateTime ReportedAt { get; set; } = DateTime.UtcNow;
    public string Description { get; set; } = string.Empty;
    public string? ImageUrl { get; set; }

    public double Latitude { get; set; }
    public double Longitude { get; set; }

    public IncidentStatus Status { get; set; } = IncidentStatus.Reported;
    public bool IsUrgent { get; set; }

    /// <summary>Obrazlozenje rjesavanja ili razlog odbijanja prijave.</summary>
    public string? ResolutionNote { get; set; }
    public DateTime? HandledAt { get; set; }

    /// <summary>Audit trag: zaposlenik koji je preuzeo, rijesio ili odbio prijavu.</summary>
    public int? HandledByUserId { get; set; }
    public User? HandledByUser { get; set; }

    public int ReportedByUserId { get; set; }
    public User ReportedByUser { get; set; } = null!;

    public int IncidentTypeId { get; set; }
    public IncidentType IncidentType { get; set; } = null!;

    public int? TrailId { get; set; }
    public Trail? Trail { get; set; }

    public int? SkiLiftId { get; set; }
    public SkiLift? SkiLift { get; set; }
}
