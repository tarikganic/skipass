using SkiPass.Domain.Enums;

namespace SkiPass.Domain.Rules;

/// <summary>
/// Centralizovana state machine logika za narudzbe ski pass karata.
/// Dozvoljeni prelazi: Pending -> Confirmed / Cancelled, Confirmed -> Completed / Cancelled.
/// </summary>
public static class OrderStatusRules
{
    private static readonly Dictionary<OrderStatus, OrderStatus[]> AllowedTransitions = new()
    {
        [OrderStatus.Pending] = [OrderStatus.Confirmed, OrderStatus.Cancelled],
        [OrderStatus.Confirmed] = [OrderStatus.Completed, OrderStatus.Cancelled],
        [OrderStatus.Completed] = [],
        [OrderStatus.Cancelled] = []
    };

    /// <summary>Statusi u kojima narudzba jos zauzima kapacitet i moze se placati.</summary>
    public static readonly OrderStatus[] OpenStatuses = [OrderStatus.Pending, OrderStatus.Confirmed];

    public static bool CanTransition(OrderStatus from, OrderStatus to) =>
        AllowedTransitions.TryGetValue(from, out var allowed) && allowed.Contains(to);

    public static IReadOnlyCollection<OrderStatus> GetAllowedTransitions(OrderStatus from) =>
        AllowedTransitions.TryGetValue(from, out var allowed) ? allowed : [];

    public static bool IsOpen(OrderStatus status) => OpenStatuses.Contains(status);
}
