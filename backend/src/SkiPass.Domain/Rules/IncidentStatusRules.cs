using SkiPass.Domain.Enums;

namespace SkiPass.Domain.Rules;

/// <summary>
/// State machine za prijavljene incidente.
/// Reported -> InProgress -> Resolved, uz mogucnost odbijanja neosnovane prijave.
/// </summary>
public static class IncidentStatusRules
{
    private static readonly Dictionary<IncidentStatus, IncidentStatus[]> AllowedTransitions = new()
    {
        [IncidentStatus.Reported] = [IncidentStatus.InProgress, IncidentStatus.Rejected],
        [IncidentStatus.InProgress] = [IncidentStatus.Resolved, IncidentStatus.Rejected],
        [IncidentStatus.Resolved] = [],
        [IncidentStatus.Rejected] = []
    };

    /// <summary>Statusi koji zahtijevaju obavezno obrazlozenje.</summary>
    public static readonly IncidentStatus[] StatusesRequiringNote = [IncidentStatus.Resolved, IncidentStatus.Rejected];

    public static bool CanTransition(IncidentStatus from, IncidentStatus to) =>
        AllowedTransitions.TryGetValue(from, out var allowed) && allowed.Contains(to);

    public static bool RequiresNote(IncidentStatus status) => StatusesRequiringNote.Contains(status);
}
