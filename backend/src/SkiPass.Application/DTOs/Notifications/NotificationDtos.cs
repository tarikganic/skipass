using System.ComponentModel.DataAnnotations;
using SkiPass.Application.Common;

namespace SkiPass.Application.DTOs.Notifications;

public class NotificationDto
{
    public int Id { get; set; }
    public string Title { get; set; } = string.Empty;
    public string Message { get; set; } = string.Empty;
    public string Type { get; set; } = string.Empty;
    public bool IsRead { get; set; }
    public DateTime? ReadAt { get; set; }
    public string? TargetRoute { get; set; }
    public DateTime CreatedAt { get; set; }

    public int UserId { get; set; }
    public string UserFullName { get; set; } = string.Empty;
}

/// <summary>Rucno slanje notifikacije korisniku iz administracije.</summary>
public class NotificationCreateDto
{
    [Range(1, int.MaxValue, ErrorMessage = "Odaberite korisnika kojem se salje notifikacija.")]
    public int UserId { get; set; }

    [Required(ErrorMessage = "Naslov notifikacije je obavezan.")]
    [StringLength(200, MinimumLength = 3, ErrorMessage = "Naslov mora imati izmedju 3 i 200 znakova.")]
    public string Title { get; set; } = string.Empty;

    [Required(ErrorMessage = "Tekst notifikacije je obavezan.")]
    [StringLength(1000, MinimumLength = 3, ErrorMessage = "Tekst mora imati izmedju 3 i 1000 znakova.")]
    public string Message { get; set; } = string.Empty;

    [StringLength(200, ErrorMessage = "Ruta moze imati najvise 200 znakova.")]
    public string? TargetRoute { get; set; }
}

public class NotificationSearchDto : PagedRequest
{
    /// <summary>Pretraga po naslovu ili tekstu notifikacije.</summary>
    public string? Query { get; set; }
    public int? UserId { get; set; }
    public string? Type { get; set; }
    public bool? IsRead { get; set; }
    public DateTime? CreatedFrom { get; set; }
    public DateTime? CreatedTo { get; set; }
}

public class UnreadNotificationCountDto
{
    public int UnreadCount { get; set; }
}
