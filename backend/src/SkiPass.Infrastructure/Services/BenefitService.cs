using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;
using SkiPass.Application.Common;
using SkiPass.Application.DTOs.Benefits;
using SkiPass.Application.DTOs.Common;
using SkiPass.Application.Exceptions;
using SkiPass.Application.Services.Interfaces;
using SkiPass.Domain.Entities;
using SkiPass.Domain.Enums;
using SkiPass.Domain.Rules;
using SkiPass.Infrastructure.Data;

namespace SkiPass.Infrastructure.Services;

public class BenefitService
    : CrudServiceBase<Benefit, BenefitDto, BenefitUpsertDto, BenefitSearchDto>, IBenefitService
{
    public BenefitService(ApplicationDbContext context, ILogger<BenefitService> logger)
        : base(context, logger)
    {
    }

    protected override string EntityName => "Pogodnost";

    protected override IQueryable<Benefit> BaseQuery() =>
        Context.Benefits
            .Include(b => b.BenefitCategory)
            .Include(b => b.SkiResort)
            .Include(b => b.Partner)
            .Include(b => b.Purchases);

    public async Task<List<LookupDto>> GetLookupAsync(CancellationToken cancellationToken = default) =>
        await Context.Benefits
            .Where(b => !b.IsDeleted && b.IsActive)
            .OrderBy(b => b.Name)
            .Select(b => new LookupDto { Id = b.Id, Name = b.Name })
            .AsNoTracking()
            .ToListAsync(cancellationToken);

    protected override IQueryable<Benefit> ApplyFilters(IQueryable<Benefit> query, BenefitSearchDto request)
    {
        if (!string.IsNullOrWhiteSpace(request.Query))
        {
            var term = request.Query.Trim();
            query = query.Where(b =>
                b.Name.Contains(term) ||
                b.Description.Contains(term) ||
                (b.Brand != null && b.Brand.Contains(term)));
        }

        if (request.BenefitCategoryId.HasValue)
        {
            query = query.Where(b => b.BenefitCategoryId == request.BenefitCategoryId.Value);
        }

        if (request.SkiResortId.HasValue)
        {
            query = query.Where(b => b.SkiResortId == request.SkiResortId.Value);
        }

        if (request.PartnerId.HasValue)
        {
            query = query.Where(b => b.PartnerId == request.PartnerId.Value);
        }

        if (!string.IsNullOrWhiteSpace(request.Brand))
        {
            var brand = request.Brand.Trim();
            query = query.Where(b => b.Brand == brand);
        }

        if (request.IsActive.HasValue)
        {
            query = query.Where(b => b.IsActive == request.IsActive.Value);
        }

        // Filtriranje po cijeni se radi na nivou baze, nad efektivnom cijenom nakon popusta.
        if (request.MinPrice.HasValue)
        {
            query = query.Where(b => b.Price * (1 - b.DiscountPercentage / 100m) >= request.MinPrice.Value);
        }

        if (request.MaxPrice.HasValue)
        {
            query = query.Where(b => b.Price * (1 - b.DiscountPercentage / 100m) <= request.MaxPrice.Value);
        }

        if (request.MinAverageRating.HasValue)
        {
            query = query.Where(b => b.AverageRating >= request.MinAverageRating.Value);
        }

        return query;
    }

    protected override IQueryable<Benefit> ApplyDefaultSort(IQueryable<Benefit> query) => query.OrderBy(b => b.Name);

    protected override IQueryable<Benefit>? ApplySort(IQueryable<Benefit> query, string sortBy, bool descending) =>
        sortBy.ToLowerInvariant() switch
        {
            "name" => descending ? query.OrderByDescending(b => b.Name) : query.OrderBy(b => b.Name),
            "price" => descending ? query.OrderByDescending(b => b.Price) : query.OrderBy(b => b.Price),
            "rating" => descending ? query.OrderByDescending(b => b.AverageRating) : query.OrderBy(b => b.AverageRating),
            _ => null
        };

    protected override BenefitDto MapToDto(Benefit e) => new()
    {
        Id = e.Id,
        Name = e.Name,
        Description = e.Description,
        ImageUrl = e.ImageUrl,
        Price = e.Price,
        DiscountPercentage = e.DiscountPercentage,
        EffectivePrice = CalculateEffectivePrice(e.Price, e.DiscountPercentage),
        Brand = e.Brand,
        IsActive = e.IsActive,
        AverageRating = e.AverageRating,
        RatingCount = e.RatingCount,
        BenefitCategoryId = e.BenefitCategoryId,
        BenefitCategoryName = e.BenefitCategory.Name,
        SkiResortId = e.SkiResortId,
        SkiResortName = e.SkiResort.Name,
        PartnerId = e.PartnerId,
        PartnerName = e.Partner?.Name,
        PurchaseCount = e.Purchases.Count(p => !p.IsDeleted && p.Status != OrderStatus.Cancelled)
    };

    protected override async Task MapAsync(Benefit entity, BenefitUpsertDto dto, CancellationToken cancellationToken)
    {
        var categoryExists = await Context.BenefitCategories
            .AnyAsync(c => c.Id == dto.BenefitCategoryId && !c.IsDeleted, cancellationToken);
        if (!categoryExists)
        {
            throw new ValidationException(nameof(dto.BenefitCategoryId), "Odabrana kategorija pogodnosti ne postoji.");
        }

        var resortExists = await Context.SkiResorts.AnyAsync(r => r.Id == dto.SkiResortId && !r.IsDeleted, cancellationToken);
        if (!resortExists)
        {
            throw new ValidationException(nameof(dto.SkiResortId), "Odabrano skijaliste ne postoji.");
        }

        if (dto.PartnerId.HasValue)
        {
            var partnerExists = await Context.Partners
                .AnyAsync(p => p.Id == dto.PartnerId.Value && !p.IsDeleted, cancellationToken);
            if (!partnerExists)
            {
                throw new ValidationException(nameof(dto.PartnerId), "Odabrani partner ne postoji.");
            }
        }

        var duplicate = await Context.Benefits.AnyAsync(
            b => b.Id != entity.Id && !b.IsDeleted && b.SkiResortId == dto.SkiResortId && b.Name == dto.Name,
            cancellationToken);
        if (duplicate)
        {
            throw new ValidationException(nameof(dto.Name), "Pogodnost sa ovim nazivom vec postoji na odabranom skijalistu.");
        }

        entity.Name = dto.Name.Trim();
        entity.Description = dto.Description.Trim();
        entity.ImageUrl = dto.ImageUrl?.Trim();
        entity.Price = dto.Price;
        entity.DiscountPercentage = dto.DiscountPercentage;
        entity.Brand = dto.Brand?.Trim();
        entity.IsActive = dto.IsActive;
        entity.BenefitCategoryId = dto.BenefitCategoryId;
        entity.SkiResortId = dto.SkiResortId;
        entity.PartnerId = dto.PartnerId;
    }

    protected override async Task EnsureCanDeleteAsync(Benefit entity, CancellationToken cancellationToken)
    {
        var purchaseCount = await Context.BenefitPurchases
            .CountAsync(p => p.BenefitId == entity.Id && !p.IsDeleted, cancellationToken);
        EnsureNotReferenced(EntityName, "Kupljene pogodnosti", purchaseCount);

        var reviewCount = await Context.Reviews
            .CountAsync(r => r.BenefitId == entity.Id && !r.IsDeleted, cancellationToken);
        EnsureNotReferenced(EntityName, "Ocjene korisnika", reviewCount);
    }

    internal static decimal CalculateEffectivePrice(decimal price, decimal discountPercentage) =>
        Math.Round(price * (1 - discountPercentage / 100m), 2, MidpointRounding.AwayFromZero);
}

public class BenefitPurchaseService
    : CrudServiceBase<BenefitPurchase, BenefitPurchaseDto, BenefitPurchaseCreateDto, BenefitPurchaseSearchDto>,
      IBenefitPurchaseService
{
    private readonly ICurrentUserService _currentUserService;

    public BenefitPurchaseService(
        ApplicationDbContext context,
        ICurrentUserService currentUserService,
        ILogger<BenefitPurchaseService> logger)
        : base(context, logger)
    {
        _currentUserService = currentUserService;
    }

    protected override string EntityName => "Kupovina pogodnosti";

    protected override IQueryable<BenefitPurchase> BaseQuery() =>
        Context.BenefitPurchases
            .Include(p => p.User)
            .Include(p => p.Benefit)
                .ThenInclude(b => b.BenefitCategory);

    protected override IQueryable<BenefitPurchase> ApplyFilters(IQueryable<BenefitPurchase> query, BenefitPurchaseSearchDto request)
    {
        if (!_currentUserService.IsStaffOrAdmin)
        {
            var currentUserId = _currentUserService.GetRequiredUserId();
            query = query.Where(p => p.UserId == currentUserId);
        }
        else if (request.UserId.HasValue)
        {
            query = query.Where(p => p.UserId == request.UserId.Value);
        }

        if (!string.IsNullOrWhiteSpace(request.Query))
        {
            var term = request.Query.Trim();
            query = query.Where(p =>
                p.Benefit.Name.Contains(term) ||
                p.User.FirstName.Contains(term) ||
                p.User.LastName.Contains(term));
        }

        if (request.BenefitId.HasValue)
        {
            query = query.Where(p => p.BenefitId == request.BenefitId.Value);
        }

        if (request.BenefitCategoryId.HasValue)
        {
            query = query.Where(p => p.Benefit.BenefitCategoryId == request.BenefitCategoryId.Value);
        }

        if (!string.IsNullOrWhiteSpace(request.Status))
        {
            var status = ParseEnum<OrderStatus>(request.Status, nameof(request.Status));
            query = query.Where(p => p.Status == status);
        }

        if (request.PurchasedFrom.HasValue)
        {
            query = query.Where(p => p.PurchasedAt >= request.PurchasedFrom.Value);
        }

        if (request.PurchasedTo.HasValue)
        {
            query = query.Where(p => p.PurchasedAt <= request.PurchasedTo.Value);
        }

        return query;
    }

    protected override IQueryable<BenefitPurchase> ApplyDefaultSort(IQueryable<BenefitPurchase> query) =>
        query.OrderByDescending(p => p.PurchasedAt);

    protected override BenefitPurchaseDto MapToDto(BenefitPurchase e) => new()
    {
        Id = e.Id,
        PurchasedAt = e.PurchasedAt,
        Quantity = e.Quantity,
        TotalPrice = e.TotalPrice,
        Status = e.Status.ToString(),
        CancellationReason = e.CancellationReason,
        UserId = e.UserId,
        UserFullName = $"{e.User.FirstName} {e.User.LastName}",
        BenefitId = e.BenefitId,
        BenefitName = e.Benefit.Name,
        BenefitCategoryName = e.Benefit.BenefitCategory.Name,
        BenefitImageUrl = e.Benefit.ImageUrl,
        AllowedNextStatuses = OrderStatusRules.GetAllowedTransitions(e.Status).Select(s => s.ToString()).ToList()
    };

    protected override Task MapAsync(BenefitPurchase entity, BenefitPurchaseCreateDto dto, CancellationToken cancellationToken) =>
        MapInternalAsync(entity, dto, _currentUserService.GetRequiredUserId(), cancellationToken);

    public async Task<BenefitPurchaseDto> CreateForUserAsync(BenefitPurchaseCreateDto dto, int userId, CancellationToken cancellationToken = default)
    {
        var entity = new BenefitPurchase();
        await MapInternalAsync(entity, dto, userId, cancellationToken);

        Context.BenefitPurchases.Add(entity);
        await Context.SaveChangesAsync(cancellationToken);

        Logger.LogInformation("Korisnik {UserId} je kupio pogodnost {BenefitId}.", userId, dto.BenefitId);
        return await GetByIdAsync(entity.Id, cancellationToken);
    }

    public async Task<BenefitPurchaseDto> UpdateStatusAsync(int id, BenefitPurchaseStatusUpdateDto dto, CancellationToken cancellationToken = default)
    {
        var entity = await Context.BenefitPurchases
            .FirstOrDefaultAsync(p => p.Id == id && !p.IsDeleted, cancellationToken)
            ?? throw NotFoundException.For(EntityName, id);

        _currentUserService.EnsureCanAccessUser(entity.UserId);

        var newStatus = ParseEnum<OrderStatus>(dto.Status, nameof(dto.Status));

        if (!OrderStatusRules.CanTransition(entity.Status, newStatus))
        {
            throw new BusinessException($"Prelaz iz statusa \"{entity.Status}\" u status \"{newStatus}\" nije dozvoljen.");
        }

        if (newStatus == OrderStatus.Cancelled && string.IsNullOrWhiteSpace(dto.CancellationReason))
        {
            throw new ValidationException(nameof(dto.CancellationReason), "Razlog otkazivanja je obavezan.");
        }

        // Skijas smije otkazati vlastitu kupovinu, ali potvrdu/zavrsetak (nakon
        // evidentiranog placanja) smije postaviti samo osoblje.
        if (newStatus != OrderStatus.Cancelled && !_currentUserService.IsStaffOrAdmin)
        {
            throw new ForbiddenAccessException("Ovaj status moze postaviti samo osoblje.");
        }

        entity.Status = newStatus;
        entity.CancellationReason = dto.CancellationReason?.Trim();

        await Context.SaveChangesAsync(cancellationToken);

        Logger.LogInformation("Kupovina pogodnosti {PurchaseId} je prebacena u status {Status}.", id, newStatus);
        return await GetByIdAsync(id, cancellationToken);
    }

    private async Task MapInternalAsync(BenefitPurchase entity, BenefitPurchaseCreateDto dto, int userId, CancellationToken cancellationToken)
    {
        var benefit = await Context.Benefits
            .FirstOrDefaultAsync(b => b.Id == dto.BenefitId && !b.IsDeleted && b.IsActive, cancellationToken)
            ?? throw new ValidationException(nameof(dto.BenefitId), "Odabrana pogodnost nije dostupna.");

        entity.BenefitId = benefit.Id;
        entity.Quantity = dto.Quantity;
        // Cijena se uvijek racuna na serveru iz vazeceg cjenovnika pogodnosti.
        entity.TotalPrice = BenefitService.CalculateEffectivePrice(benefit.Price, benefit.DiscountPercentage) * dto.Quantity;

        if (entity.Id == 0)
        {
            entity.UserId = userId;
            entity.PurchasedAt = DateTime.UtcNow;
            entity.Status = OrderStatus.Pending;
        }
    }

    protected override Task EnsureCanDeleteAsync(BenefitPurchase entity, CancellationToken cancellationToken)
    {
        if (entity.Status is OrderStatus.Confirmed or OrderStatus.Completed)
        {
            throw new BusinessException(
                "Potvrdjena kupovina pogodnosti se ne moze obrisati. Prvo je otkazite uz navodjenje razloga.");
        }

        return Task.CompletedTask;
    }
}
