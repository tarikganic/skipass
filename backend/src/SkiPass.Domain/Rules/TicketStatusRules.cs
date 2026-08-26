using SkiPass.Domain.Enums;

namespace SkiPass.Domain.Rules;

/// <summary>
/// State machine za pojedinacnu ski pass kartu.
/// Pending -> Active -> Used / Expired, uz mogucnost otkazivanja prije koristenja.
/// </summary>
public static class TicketStatusRules
{
    private static readonly Dictionary<TicketStatus, TicketStatus[]> AllowedTransitions = new()
    {
        [TicketStatus.Pending] = [TicketStatus.Active, TicketStatus.Cancelled],
        [TicketStatus.Active] = [TicketStatus.Used, TicketStatus.Expired, TicketStatus.Cancelled],
        [TicketStatus.Used] = [TicketStatus.Expired],
        [TicketStatus.Expired] = [],
        [TicketStatus.Cancelled] = []
    };

    /// <summary>Statusi u kojima karta moze proci QR validaciju na liftu.</summary>
    public static readonly TicketStatus[] ValidatableStatuses = [TicketStatus.Active, TicketStatus.Used];

    public static bool CanTransition(TicketStatus from, TicketStatus to) =>
        AllowedTransitions.TryGetValue(from, out var allowed) && allowed.Contains(to);

    public static bool IsValidatable(TicketStatus status) => ValidatableStatuses.Contains(status);
}
