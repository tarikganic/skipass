using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;
using SkiPass.Application.Common;
using SkiPass.Application.DTOs.Reviews;
using SkiPass.Application.Exceptions;
using SkiPass.Application.Services.Interfaces;
using SkiPass.Domain.Entities;
using SkiPass.Domain.Enums;
using SkiPass.Domain.Interfaces;
using SkiPass.Infrastructure.Data;

namespace SkiPass.Infrastructure.Services;

public class ReviewService : IReviewService
{
    private const string EntityName = "Ocjena";

    private readonly ApplicationDbContext _context;
    private readonly IUnitOfWork _unitOfWork;
    private readonly ILogger<ReviewService> _logger;

    public ReviewService(ApplicationDbContext context, IUnitOfWork unitOfWork, ILogger<ReviewService> logger)
    {
        _context = context;
        _unitOfWork = unitOfWork;
        _logger = logger;
    }

    public async Task<PagedResult<ReviewDto>> SearchAsync(ReviewSearchDto request, CancellationToken cancellationToken = default)
    {
        var query = BaseQuery().Where(r => !r.IsDeleted);

        if (!string.IsNullOrWhiteSpace(request.Query))
        {
            var term = request.Query.Trim();
            query = query.Where(r =>
                (r.Comment != null && r.Comment.Contains(term)) ||
                r.User.FirstName.Contains(term) ||
                r.User.LastName.Contains(term));
        }

        if (request.UserId.HasValue)
        {
            query = query.Where(r => r.UserId == request.UserId.Value);
        }

        if (!string.IsNullOrWhiteSpace(request.TargetType))
        {
            var targetType = ParseTargetType(request.TargetType, nameof(request.TargetType));
            query = query.Where(r => r.TargetType == targetType);
        }

        if (request.TrailId.HasValue)
        {
            query = query.Where(r => r.TrailId == request.TrailId.Value);
        }

        if (request.BenefitId.HasValue)
        {
            query = query.Where(r => r.BenefitId == request.BenefitId.Value);
        }

        if (request.SkiResortId.HasValue)
        {
            query = query.Where(r => r.SkiResortId == request.SkiResortId.Value);
        }

        if (request.MinRating.HasValue)
        {
            query = query.Where(r => r.Rating >= request.MinRating.Value);
        }

        if (request.MaxRating.HasValue)
        {
            query = query.Where(r => r.Rating <= request.MaxRating.Value);
        }

        var totalCount = await query.CountAsync(cancellationToken);

        var entities = await query
            .OrderByDescending(r => r.CreatedAt)
            .Skip((request.Page - 1) * request.PageSize)
            .Take(request.PageSize)
            .AsNoTracking()
            .ToListAsync(cancellationToken);

        return entities.Select(MapToDto).ToList().ToPagedResult(totalCount, request);
    }

    public async Task<ReviewDto> GetByIdAsync(int id, CancellationToken cancellationToken = default)
    {
        var entity = await BaseQuery()
            .AsNoTracking()
            .FirstOrDefaultAsync(r => r.Id == id && !r.IsDeleted, cancellationToken)
            ?? throw NotFoundException.For(EntityName, id);

        return MapToDto(entity);
    }

    public async Task<ReviewDto> CreateAsync(ReviewCreateDto dto, int userId, CancellationToken cancellationToken = default)
    {
        var targetType = ParseTargetType(dto.TargetType, nameof(dto.TargetType));

        await EnsureTargetMatchesTypeAsync(targetType, dto, cancellationToken);
        await EnsureNotAlreadyReviewedAsync(userId, dto, cancellationToken);

        await _unitOfWork.BeginTransactionAsync(cancellationToken);
        try
        {
            var review = new Review
            {
                Rating = dto.Rating,
                Comment = dto.Comment?.Trim(),
                TargetType = targetType,
                UserId = userId,
                TrailId = dto.TrailId,
                BenefitId = dto.BenefitId,
                SkiResortId = dto.SkiResortId
            };

            _context.Reviews.Add(review);
            await _context.SaveChangesAsync(cancellationToken);

            if (review.BenefitId.HasValue)
            {
                await RecalculateBenefitRatingAsync(review.BenefitId.Value, cancellationToken);
            }

            await _unitOfWork.CommitTransactionAsync(cancellationToken);

            _logger.LogInformation("Korisnik {UserId} je ostavio ocjenu {Rating}.", userId, dto.Rating);
            return await GetByIdAsync(review.Id, cancellationToken);
        }
        catch
        {
            await _unitOfWork.RollbackTransactionAsync(cancellationToken);
            throw;
        }
    }

    public async Task<ReviewDto> UpdateAsync(int id, ReviewUpdateDto dto, int userId, bool isAdmin, CancellationToken cancellationToken = default)
    {
        var review = await _context.Reviews
            .FirstOrDefaultAsync(r => r.Id == id && !r.IsDeleted, cancellationToken)
            ?? throw NotFoundException.For(EntityName, id);

        if (!isAdmin && review.UserId != userId)
        {
            throw new ForbiddenAccessException("Mozete uredjivati samo vlastite ocjene.");
        }

        await _unitOfWork.BeginTransactionAsync(cancellationToken);
        try
        {
            review.Rating = dto.Rating;
            review.Comment = dto.Comment?.Trim();

            await _context.SaveChangesAsync(cancellationToken);

            if (review.BenefitId.HasValue)
            {
                await RecalculateBenefitRatingAsync(review.BenefitId.Value, cancellationToken);
            }

            await _unitOfWork.CommitTransactionAsync(cancellationToken);
            return await GetByIdAsync(id, cancellationToken);
        }
        catch
        {
            await _unitOfWork.RollbackTransactionAsync(cancellationToken);
            throw;
        }
    }

    public async Task DeleteAsync(int id, int userId, bool isAdmin, CancellationToken cancellationToken = default)
    {
        var review = await _context.Reviews
            .FirstOrDefaultAsync(r => r.Id == id && !r.IsDeleted, cancellationToken)
            ?? throw NotFoundException.For(EntityName, id);

        if (!isAdmin && review.UserId != userId)
        {
            throw new ForbiddenAccessException("Mozete brisati samo vlastite ocjene.");
        }

        await _unitOfWork.BeginTransactionAsync(cancellationToken);
        try
        {
            review.IsDeleted = true;
            await _context.SaveChangesAsync(cancellationToken);

            if (review.BenefitId.HasValue)
            {
                await RecalculateBenefitRatingAsync(review.BenefitId.Value, cancellationToken);
            }

            await _unitOfWork.CommitTransactionAsync(cancellationToken);
            _logger.LogInformation("Obrisana ocjena {ReviewId}.", id);
        }
        catch
        {
            await _unitOfWork.RollbackTransactionAsync(cancellationToken);
            throw;
        }
    }

    /// <summary>
    /// Prosjecna ocjena pogodnosti se drzi na entitetu jer se koristi i u pretrazi
    /// i kao signal u sistemu preporuke, pa se osvjezava jednim agregatnim upitom.
    /// </summary>
    private async Task RecalculateBenefitRatingAsync(int benefitId, CancellationToken cancellationToken)
    {
        var stats = await _context.Reviews
            .Where(r => r.BenefitId == benefitId && !r.IsDeleted)
            .GroupBy(r => r.BenefitId)
            .Select(g => new { Count = g.Count(), Average = g.Average(r => (double)r.Rating) })
            .FirstOrDefaultAsync(cancellationToken);

        var benefit = await _context.Benefits.FirstOrDefaultAsync(b => b.Id == benefitId, cancellationToken);
        if (benefit is null)
        {
            return;
        }

        benefit.RatingCount = stats?.Count ?? 0;
        benefit.AverageRating = stats is null ? 0 : Math.Round(stats.Average, 2);

        await _context.SaveChangesAsync(cancellationToken);
    }

    private async Task EnsureTargetMatchesTypeAsync(ReviewTargetType targetType, ReviewCreateDto dto, CancellationToken cancellationToken)
    {
        switch (targetType)
        {
            case ReviewTargetType.Trail:
                if (dto.TrailId is null)
                {
                    throw new ValidationException(nameof(dto.TrailId), "Za ocjenu staze je obavezno odabrati stazu.");
                }

                if (!await _context.Trails.AnyAsync(t => t.Id == dto.TrailId.Value && !t.IsDeleted, cancellationToken))
                {
                    throw new ValidationException(nameof(dto.TrailId), "Odabrana staza ne postoji.");
                }

                break;

            case ReviewTargetType.Benefit:
                if (dto.BenefitId is null)
                {
                    throw new ValidationException(nameof(dto.BenefitId), "Za ocjenu pogodnosti je obavezno odabrati pogodnost.");
                }

                if (!await _context.Benefits.AnyAsync(b => b.Id == dto.BenefitId.Value && !b.IsDeleted, cancellationToken))
                {
                    throw new ValidationException(nameof(dto.BenefitId), "Odabrana pogodnost ne postoji.");
                }

                break;

            case ReviewTargetType.Resort:
                if (dto.SkiResortId is null)
                {
                    throw new ValidationException(nameof(dto.SkiResortId), "Za ocjenu skijalista je obavezno odabrati skijaliste.");
                }

                if (!await _context.SkiResorts.AnyAsync(r => r.Id == dto.SkiResortId.Value && !r.IsDeleted, cancellationToken))
                {
                    throw new ValidationException(nameof(dto.SkiResortId), "Odabrano skijaliste ne postoji.");
                }

                break;
        }
    }

    private async Task EnsureNotAlreadyReviewedAsync(int userId, ReviewCreateDto dto, CancellationToken cancellationToken)
    {
        var alreadyReviewed = await _context.Reviews.AnyAsync(
            r => r.UserId == userId
                 && !r.IsDeleted
                 && ((dto.TrailId != null && r.TrailId == dto.TrailId)
                     || (dto.BenefitId != null && r.BenefitId == dto.BenefitId)
                     || (dto.SkiResortId != null && r.SkiResortId == dto.SkiResortId)),
            cancellationToken);

        if (alreadyReviewed)
        {
            throw new BusinessException("Ovu stavku ste vec ocijenili. Postojecu ocjenu mozete urediti.");
        }
    }

    private IQueryable<Review> BaseQuery() =>
        _context.Reviews
            .Include(r => r.User)
            .Include(r => r.Trail)
            .Include(r => r.Benefit)
            .Include(r => r.SkiResort);

    private static ReviewDto MapToDto(Review e) => new()
    {
        Id = e.Id,
        Rating = e.Rating,
        Comment = e.Comment,
        TargetType = e.TargetType.ToString(),
        CreatedAt = e.CreatedAt,
        UserId = e.UserId,
        UserFullName = $"{e.User.FirstName} {e.User.LastName}",
        UserProfileImageUrl = e.User.ProfileImageUrl,
        TrailId = e.TrailId,
        TrailName = e.Trail?.Name,
        BenefitId = e.BenefitId,
        BenefitName = e.Benefit?.Name,
        SkiResortId = e.SkiResortId,
        SkiResortName = e.SkiResort?.Name
    };

    private static ReviewTargetType ParseTargetType(string value, string field)
    {
        if (!Enum.TryParse<ReviewTargetType>(value, ignoreCase: true, out var parsed) || !Enum.IsDefined(parsed))
        {
            throw new ValidationException(
                field,
                $"Nepoznata vrijednost \"{value}\". Dozvoljene vrijednosti su: {string.Join(", ", Enum.GetNames<ReviewTargetType>())}.");
        }

        return parsed;
    }
}
