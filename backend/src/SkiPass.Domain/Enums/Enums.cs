namespace SkiPass.Domain.Enums;

public enum UserRole
{
    Skier = 0,
    Staff = 1,
    Admin = 2
}

/// <summary>Stanja narudzbe ski pass karata: Pending -> Confirmed -> Completed / Cancelled.</summary>
public enum OrderStatus
{
    Pending = 0,
    Confirmed = 1,
    Completed = 2,
    Cancelled = 3
}

/// <summary>Stanja pojedinacne ski pass karte.</summary>
public enum TicketStatus
{
    Pending = 0,
    Active = 1,
    Used = 2,
    Expired = 3,
    Cancelled = 4
}

public enum PaymentStatus
{
    Pending = 0,
    Completed = 1,
    Failed = 2,
    Refunded = 3,
    PartiallyRefunded = 4
}

/// <summary>Stanja prijavljenog incidenta: Reported -> InProgress -> Resolved / Rejected.</summary>
public enum IncidentStatus
{
    Reported = 0,
    InProgress = 1,
    Resolved = 2,
    Rejected = 3
}

/// <summary>Stanja evidencije kvara ili odrzavanja ski lifta.</summary>
public enum MaintenanceStatus
{
    Reported = 0,
    InProgress = 1,
    Completed = 2,
    Cancelled = 3
}

public enum CrowdLevel
{
    Low = 0,
    Moderate = 1,
    High = 2,
    VeryHigh = 3
}

public enum NotificationType
{
    General = 0,
    OrderConfirmed = 1,
    OrderCancelled = 2,
    PaymentCompleted = 3,
    PaymentRefunded = 4,
    TicketActivated = 5,
    TicketExpiring = 6,
    IncidentStatusChanged = 7,
    TrailStatusChanged = 8,
    LiftStatusChanged = 9,
    NewAnnouncement = 10,
    BenefitRecommendation = 11
}

/// <summary>Entitet na koji se odnosi korisnicka ocjena.</summary>
public enum ReviewTargetType
{
    Trail = 0,
    Benefit = 1,
    Resort = 2
}
