using SkiPass.Domain.Enums;

namespace SkiPass.Domain.Entities;

/// <summary>Sistemska notifikacija upucena konkretnom korisniku.</summary>
public class Notification : BaseEntity
{
    public string Title { get; set; } = string.Empty;
    public string Message { get; set; } = string.Empty;
    public NotificationType Type { get; set; } = NotificationType.General;
    public bool IsRead { get; set; }
    public DateTime? ReadAt { get; set; }

    /// <summary>Opciona ruta u klijentskoj aplikaciji na koju notifikacija vodi.</summary>
    public string? TargetRoute { get; set; }

    public int UserId { get; set; }
    public User User { get; set; } = null!;
}
