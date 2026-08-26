using SkiPass.Application.DTOs.Common;
using SkiPass.Application.Exceptions;
using SkiPass.Application.Services.Interfaces;
using SkiPass.Domain.Enums;

namespace SkiPass.Infrastructure.Services.Reference;

/// <summary>
/// Izlaze enumeracije klijentima kako bi padajuce liste statusa i tipova bile
/// popunjene iz jednog izvora umjesto hardkodiranih vrijednosti na svakom klijentu.
/// </summary>
public class EnumLookupService : IEnumLookupService
{
    private static readonly Dictionary<string, List<LookupDto>> Values = new(StringComparer.OrdinalIgnoreCase)
    {
        [nameof(UserRole)] = Build<UserRole>(),
        [nameof(OrderStatus)] = Build<OrderStatus>(),
        [nameof(TicketStatus)] = Build<TicketStatus>(),
        [nameof(PaymentStatus)] = Build<PaymentStatus>(),
        [nameof(IncidentStatus)] = Build<IncidentStatus>(),
        [nameof(MaintenanceStatus)] = Build<MaintenanceStatus>(),
        [nameof(CrowdLevel)] = Build<CrowdLevel>(),
        [nameof(NotificationType)] = Build<NotificationType>(),
        [nameof(ReviewTargetType)] = Build<ReviewTargetType>()
    };

    public IReadOnlyDictionary<string, List<LookupDto>> GetAll() => Values;

    public List<LookupDto> Get(string enumName)
    {
        if (!Values.TryGetValue(enumName, out var values))
        {
            var allowed = string.Join(", ", Values.Keys);
            throw new NotFoundException($"Enumeracija \"{enumName}\" nije pronadjena. Dostupne su: {allowed}.");
        }

        return values;
    }

    private static List<LookupDto> Build<TEnum>() where TEnum : struct, Enum =>
        Enum.GetValues<TEnum>()
            .Select(value => new LookupDto
            {
                Id = Convert.ToInt32(value),
                Name = value.ToString()
            })
            .ToList();
}
