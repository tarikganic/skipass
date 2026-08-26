using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;
using SkiPass.Application.Common;
using SkiPass.Application.DTOs.Notifications;
using SkiPass.Application.Exceptions;
using SkiPass.Application.Services.Interfaces;
using SkiPass.Domain.Entities;
using SkiPass.Domain.Enums;
using SkiPass.Infrastructure.Data;

namespace SkiPass.Infrastructure.Services;

public class NotificationService : INotificationService
{
    private const string EntityName = "Notifikacija";

    private readonly ApplicationDbContext _context;
    private readonly ICurrentUserService _currentUserService;
    private readonly ILogger<NotificationService> _logger;

    public NotificationService(
        ApplicationDbContext context,
        ICurrentUserService currentUserService,
        ILogger<NotificationService> logger)
    {
        _context = context;
        _currentUserService = currentUserService;
        _logger = logger;
    }

    public async Task<PagedResult<NotificationDto>> SearchAsync(NotificationSearchDto request, CancellationToken cancellationToken = default)
    {
        var query = BaseQuery().Where(n => !n.IsDeleted);

        // Korisnik uvijek vidi samo vlastite notifikacije.
        if (!_currentUserService.IsStaffOrAdmin)
        {
            var currentUserId = _currentUserService.GetRequiredUserId();
            query = query.Where(n => n.UserId == currentUserId);
        }
        else if (request.UserId.HasValue)
        {
            query = query.Where(n => n.UserId == request.UserId.Value);
        }

        if (!string.IsNullOrWhiteSpace(request.Query))
        {
            var term = request.Query.Trim();
            query = query.Where(n => n.Title.Contains(term) || n.Message.Contains(term));
        }

        if (!string.IsNullOrWhiteSpace(request.Type))
        {
            var type = ParseType(request.Type, nameof(request.Type));
            query = query.Where(n => n.Type == type);
        }

        if (request.IsRead.HasValue)
        {
            query = query.Where(n => n.IsRead == request.IsRead.Value);
        }

        if (request.CreatedFrom.HasValue)
        {
            query = query.Where(n => n.CreatedAt >= request.CreatedFrom.Value);
        }

        if (request.CreatedTo.HasValue)
        {
            query = query.Where(n => n.CreatedAt <= request.CreatedTo.Value);
        }

        var totalCount = await query.CountAsync(cancellationToken);

        var entities = await query
            .OrderByDescending(n => n.CreatedAt)
            .Skip((request.Page - 1) * request.PageSize)
            .Take(request.PageSize)
            .AsNoTracking()
            .ToListAsync(cancellationToken);

        return entities.Select(MapToDto).ToList().ToPagedResult(totalCount, request);
    }

    public async Task<NotificationDto> GetByIdAsync(int id, CancellationToken cancellationToken = default)
    {
        var entity = await BaseQuery()
            .AsNoTracking()
            .FirstOrDefaultAsync(n => n.Id == id && !n.IsDeleted, cancellationToken)
            ?? throw NotFoundException.For(EntityName, id);

        _currentUserService.EnsureCanAccessUser(entity.UserId);

        return MapToDto(entity);
    }

    public async Task<NotificationDto> CreateAsync(NotificationCreateDto dto, CancellationToken cancellationToken = default)
    {
        var userExists = await _context.UserProfiles.AnyAsync(u => u.Id == dto.UserId && !u.IsDeleted, cancellationToken);
        if (!userExists)
        {
            throw new ValidationException(nameof(dto.UserId), "Odabrani korisnik ne postoji.");
        }

        var notification = new Notification
        {
            UserId = dto.UserId,
            Title = dto.Title.Trim(),
            Message = dto.Message.Trim(),
            Type = NotificationType.General,
            TargetRoute = dto.TargetRoute?.Trim()
        };

        _context.Notifications.Add(notification);
        await _context.SaveChangesAsync(cancellationToken);

        _logger.LogInformation("Poslana notifikacija {NotificationId} korisniku {UserId}.", notification.Id, dto.UserId);

        var entity = await BaseQuery().AsNoTracking().FirstAsync(n => n.Id == notification.Id, cancellationToken);
        return MapToDto(entity);
    }

    public async Task<NotificationDto> MarkAsReadAsync(int id, int userId, CancellationToken cancellationToken = default)
    {
        var notification = await _context.Notifications
            .FirstOrDefaultAsync(n => n.Id == id && !n.IsDeleted, cancellationToken)
            ?? throw NotFoundException.For(EntityName, id);

        _currentUserService.EnsureCanAccessUser(notification.UserId);

        if (!notification.IsRead)
        {
            notification.IsRead = true;
            notification.ReadAt = DateTime.UtcNow;
            await _context.SaveChangesAsync(cancellationToken);
        }

        var entity = await BaseQuery().AsNoTracking().FirstAsync(n => n.Id == id, cancellationToken);
        return MapToDto(entity);
    }

    public async Task<int> MarkAllAsReadAsync(int userId, CancellationToken cancellationToken = default)
    {
        _currentUserService.EnsureCanAccessUser(userId);

        // Jedan batch upit umjesto ucitavanja svih zapisa u memoriju.
        return await _context.Notifications
            .Where(n => n.UserId == userId && !n.IsDeleted && !n.IsRead)
            .ExecuteUpdateAsync(
                setters => setters
                    .SetProperty(n => n.IsRead, true)
                    .SetProperty(n => n.ReadAt, DateTime.UtcNow)
                    .SetProperty(n => n.UpdatedAt, DateTime.UtcNow),
                cancellationToken);
    }

    public async Task<UnreadNotificationCountDto> GetUnreadCountAsync(int userId, CancellationToken cancellationToken = default)
    {
        _currentUserService.EnsureCanAccessUser(userId);

        var count = await _context.Notifications
            .CountAsync(n => n.UserId == userId && !n.IsDeleted && !n.IsRead, cancellationToken);

        return new UnreadNotificationCountDto { UnreadCount = count };
    }

    public async Task DeleteAsync(int id, CancellationToken cancellationToken = default)
    {
        var notification = await _context.Notifications
            .FirstOrDefaultAsync(n => n.Id == id && !n.IsDeleted, cancellationToken)
            ?? throw NotFoundException.For(EntityName, id);

        _currentUserService.EnsureCanAccessUser(notification.UserId);

        notification.IsDeleted = true;
        await _context.SaveChangesAsync(cancellationToken);
    }

    private IQueryable<Notification> BaseQuery() => _context.Notifications.Include(n => n.User);

    private static NotificationDto MapToDto(Notification e) => new()
    {
        Id = e.Id,
        Title = e.Title,
        Message = e.Message,
        Type = e.Type.ToString(),
        IsRead = e.IsRead,
        ReadAt = e.ReadAt,
        TargetRoute = e.TargetRoute,
        CreatedAt = e.CreatedAt,
        UserId = e.UserId,
        UserFullName = $"{e.User.FirstName} {e.User.LastName}"
    };

    private static NotificationType ParseType(string value, string field)
    {
        if (!Enum.TryParse<NotificationType>(value, ignoreCase: true, out var parsed) || !Enum.IsDefined(parsed))
        {
            throw new ValidationException(
                field,
                $"Nepoznat tip \"{value}\". Dozvoljene vrijednosti su: {string.Join(", ", Enum.GetNames<NotificationType>())}.");
        }

        return parsed;
    }
}
