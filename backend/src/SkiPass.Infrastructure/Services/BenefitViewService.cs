using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;
using SkiPass.Application.Common;
using SkiPass.Application.DTOs.Benefits;
using SkiPass.Application.Exceptions;
using SkiPass.Application.Services.Interfaces;
using SkiPass.Domain.Entities;
using SkiPass.Infrastructure.Data;

namespace SkiPass.Infrastructure.Services;

/// <summary>
/// Biljezi stvarnu historiju pregleda pogodnosti. Ovi zapisi su ulazni signal
/// za content-based sistem preporuke, pa se upisuju pri svakom pregledu detalja.
/// </summary>
public class BenefitViewService : IBenefitViewService
{
    private readonly ApplicationDbContext _context;
    private readonly ICurrentUserService _currentUserService;
    private readonly ILogger<BenefitViewService> _logger;

    public BenefitViewService(
        ApplicationDbContext context,
        ICurrentUserService currentUserService,
        ILogger<BenefitViewService> logger)
    {
        _context = context;
        _currentUserService = currentUserService;
        _logger = logger;
    }

    public async Task<PagedResult<BenefitViewDto>> SearchAsync(BenefitViewSearchDto request, CancellationToken cancellationToken = default)
    {
        var query = BaseQuery().Where(v => !v.IsDeleted);

        if (!_currentUserService.IsStaffOrAdmin)
        {
            var currentUserId = _currentUserService.GetRequiredUserId();
            query = query.Where(v => v.UserId == currentUserId);
        }
        else if (request.UserId.HasValue)
        {
            query = query.Where(v => v.UserId == request.UserId.Value);
        }

        if (!string.IsNullOrWhiteSpace(request.Query))
        {
            var term = request.Query.Trim();
            query = query.Where(v =>
                v.Benefit.Name.Contains(term) ||
                v.User.FirstName.Contains(term) ||
                v.User.LastName.Contains(term));
        }

        if (request.BenefitId.HasValue)
        {
            query = query.Where(v => v.BenefitId == request.BenefitId.Value);
        }

        if (request.ViewedFrom.HasValue)
        {
            query = query.Where(v => v.ViewedAt >= request.ViewedFrom.Value);
        }

        if (request.ViewedTo.HasValue)
        {
            query = query.Where(v => v.ViewedAt <= request.ViewedTo.Value);
        }

        var totalCount = await query.CountAsync(cancellationToken);

        var entities = await query
            .OrderByDescending(v => v.ViewedAt)
            .Skip((request.Page - 1) * request.PageSize)
            .Take(request.PageSize)
            .AsNoTracking()
            .ToListAsync(cancellationToken);

        return entities.Select(MapToDto).ToList().ToPagedResult(totalCount, request);
    }

    public async Task<BenefitViewDto> TrackAsync(BenefitViewCreateDto dto, int userId, CancellationToken cancellationToken = default)
    {
        var benefitExists = await _context.Benefits
            .AnyAsync(b => b.Id == dto.BenefitId && !b.IsDeleted, cancellationToken);
        if (!benefitExists)
        {
            throw new ValidationException(nameof(dto.BenefitId), "Odabrana pogodnost ne postoji.");
        }

        var view = new BenefitView
        {
            UserId = userId,
            BenefitId = dto.BenefitId,
            DurationSeconds = dto.DurationSeconds,
            ViewedAt = DateTime.UtcNow
        };

        _context.BenefitViews.Add(view);
        await _context.SaveChangesAsync(cancellationToken);

        _logger.LogDebug("Evidentiran pregled pogodnosti {BenefitId} korisnika {UserId}.", dto.BenefitId, userId);

        var entity = await BaseQuery().AsNoTracking().FirstAsync(v => v.Id == view.Id, cancellationToken);
        return MapToDto(entity);
    }

    private IQueryable<BenefitView> BaseQuery() =>
        _context.BenefitViews
            .Include(v => v.User)
            .Include(v => v.Benefit)
                .ThenInclude(b => b.BenefitCategory);

    private static BenefitViewDto MapToDto(BenefitView e) => new()
    {
        Id = e.Id,
        ViewedAt = e.ViewedAt,
        DurationSeconds = e.DurationSeconds,
        UserId = e.UserId,
        UserFullName = $"{e.User.FirstName} {e.User.LastName}",
        BenefitId = e.BenefitId,
        BenefitName = e.Benefit.Name,
        BenefitCategoryName = e.Benefit.BenefitCategory.Name
    };
}
