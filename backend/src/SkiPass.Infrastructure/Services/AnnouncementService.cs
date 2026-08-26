using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;
using SkiPass.Application.DTOs.Announcements;
using SkiPass.Application.Exceptions;
using SkiPass.Application.Services.Interfaces;
using SkiPass.Domain.Entities;
using SkiPass.Infrastructure.Data;

namespace SkiPass.Infrastructure.Services;

public class AnnouncementService
    : CrudServiceBase<Announcement, AnnouncementDto, AnnouncementUpsertDto, AnnouncementSearchDto>, IAnnouncementService
{
    private readonly ICurrentUserService _currentUserService;

    public AnnouncementService(
        ApplicationDbContext context,
        ICurrentUserService currentUserService,
        ILogger<AnnouncementService> logger)
        : base(context, logger)
    {
        _currentUserService = currentUserService;
    }

    protected override string EntityName => "Obavijest";

    protected override IQueryable<Announcement> BaseQuery() =>
        Context.Announcements
            .Include(a => a.AnnouncementCategory)
            .Include(a => a.SkiResort)
            .Include(a => a.CreatedByUser);

    protected override IQueryable<Announcement> ApplyFilters(IQueryable<Announcement> query, AnnouncementSearchDto request)
    {
        if (!string.IsNullOrWhiteSpace(request.Query))
        {
            var term = request.Query.Trim();
            query = query.Where(a => a.Title.Contains(term) || a.Content.Contains(term));
        }

        if (request.AnnouncementCategoryId.HasValue)
        {
            query = query.Where(a => a.AnnouncementCategoryId == request.AnnouncementCategoryId.Value);
        }

        if (request.SkiResortId.HasValue)
        {
            query = query.Where(a => a.SkiResortId == request.SkiResortId.Value);
        }

        if (request.IsUrgent.HasValue)
        {
            query = query.Where(a => a.IsUrgent == request.IsUrgent.Value);
        }

        if (request.IsActive.HasValue)
        {
            query = query.Where(a => a.IsActive == request.IsActive.Value);
        }

        if (request.CurrentlyVisible == true)
        {
            var now = DateTime.UtcNow;
            query = query.Where(a => a.IsActive && a.PublishedAt <= now && (a.ExpiresAt == null || a.ExpiresAt > now));
        }

        if (request.PublishedFrom.HasValue)
        {
            query = query.Where(a => a.PublishedAt >= request.PublishedFrom.Value);
        }

        if (request.PublishedTo.HasValue)
        {
            query = query.Where(a => a.PublishedAt <= request.PublishedTo.Value);
        }

        return query;
    }

    protected override IQueryable<Announcement> ApplyDefaultSort(IQueryable<Announcement> query) =>
        query.OrderByDescending(a => a.IsUrgent).ThenByDescending(a => a.PublishedAt);

    protected override IQueryable<Announcement>? ApplySort(IQueryable<Announcement> query, string sortBy, bool descending) =>
        sortBy.ToLowerInvariant() switch
        {
            "title" => descending ? query.OrderByDescending(a => a.Title) : query.OrderBy(a => a.Title),
            "publishedat" => descending ? query.OrderByDescending(a => a.PublishedAt) : query.OrderBy(a => a.PublishedAt),
            _ => null
        };

    protected override AnnouncementDto MapToDto(Announcement e) => new()
    {
        Id = e.Id,
        Title = e.Title,
        Content = e.Content,
        ImageUrl = e.ImageUrl,
        PublishedAt = e.PublishedAt,
        ExpiresAt = e.ExpiresAt,
        IsUrgent = e.IsUrgent,
        IsActive = e.IsActive,
        AnnouncementCategoryId = e.AnnouncementCategoryId,
        AnnouncementCategoryName = e.AnnouncementCategory.Name,
        SkiResortId = e.SkiResortId,
        SkiResortName = e.SkiResort.Name,
        CreatedByUserId = e.CreatedByUserId,
        CreatedByUserName = $"{e.CreatedByUser.FirstName} {e.CreatedByUser.LastName}"
    };

    protected override Task MapAsync(Announcement entity, AnnouncementUpsertDto dto, CancellationToken cancellationToken) =>
        MapInternalAsync(entity, dto, _currentUserService.GetRequiredUserId(), cancellationToken);

    public async Task<AnnouncementDto> CreateForUserAsync(AnnouncementUpsertDto dto, int userId, CancellationToken cancellationToken = default)
    {
        var entity = new Announcement();
        await MapInternalAsync(entity, dto, userId, cancellationToken);

        Context.Announcements.Add(entity);
        await Context.SaveChangesAsync(cancellationToken);

        Logger.LogInformation("Kreirana obavijest {AnnouncementId} od korisnika {UserId}.", entity.Id, userId);
        return await GetByIdAsync(entity.Id, cancellationToken);
    }

    private async Task MapInternalAsync(Announcement entity, AnnouncementUpsertDto dto, int userId, CancellationToken cancellationToken)
    {
        var categoryExists = await Context.AnnouncementCategories
            .AnyAsync(c => c.Id == dto.AnnouncementCategoryId && !c.IsDeleted, cancellationToken);
        if (!categoryExists)
        {
            throw new ValidationException(nameof(dto.AnnouncementCategoryId), "Odabrana kategorija obavijesti ne postoji.");
        }

        var resortExists = await Context.SkiResorts
            .AnyAsync(r => r.Id == dto.SkiResortId && !r.IsDeleted, cancellationToken);
        if (!resortExists)
        {
            throw new ValidationException(nameof(dto.SkiResortId), "Odabrano skijaliste ne postoji.");
        }

        entity.Title = dto.Title.Trim();
        entity.Content = dto.Content.Trim();
        entity.ImageUrl = dto.ImageUrl?.Trim();
        entity.PublishedAt = dto.PublishedAt;
        entity.ExpiresAt = dto.ExpiresAt;
        entity.IsUrgent = dto.IsUrgent;
        entity.IsActive = dto.IsActive;
        entity.AnnouncementCategoryId = dto.AnnouncementCategoryId;
        entity.SkiResortId = dto.SkiResortId;

        if (entity.Id == 0)
        {
            entity.CreatedByUserId = userId;
        }
    }
}
