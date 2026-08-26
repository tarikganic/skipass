using SkiPass.Domain.Enums;

namespace SkiPass.Domain.Rules;

/// <summary>State machine za evidenciju kvarova i odrzavanja ski liftova.</summary>
public static class MaintenanceStatusRules
{
    private static readonly Dictionary<MaintenanceStatus, MaintenanceStatus[]> AllowedTransitions = new()
    {
        [MaintenanceStatus.Reported] = [MaintenanceStatus.InProgress, MaintenanceStatus.Cancelled],
        [MaintenanceStatus.InProgress] = [MaintenanceStatus.Completed, MaintenanceStatus.Cancelled],
        [MaintenanceStatus.Completed] = [],
        [MaintenanceStatus.Cancelled] = []
    };

    /// <summary>Statusi u kojima kvar jos uvijek moze drzati lift van pogona.</summary>
    public static readonly MaintenanceStatus[] OpenStatuses = [MaintenanceStatus.Reported, MaintenanceStatus.InProgress];

    public static bool CanTransition(MaintenanceStatus from, MaintenanceStatus to) =>
        AllowedTransitions.TryGetValue(from, out var allowed) && allowed.Contains(to);

    public static bool IsOpen(MaintenanceStatus status) => OpenStatuses.Contains(status);
}
