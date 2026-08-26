using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Caching.Memory;
using Microsoft.Extensions.Logging;
using SkiPass.Application.DTOs.Common;
using SkiPass.Application.DTOs.Reference;
using SkiPass.Application.Exceptions;
using SkiPass.Application.Services.Interfaces;
using SkiPass.Domain.Entities;
using SkiPass.Infrastructure.Data;

namespace SkiPass.Infrastructure.Services.Reference;

public class BenefitCategoryService
    : ReferenceCrudServiceBase<BenefitCategory, BenefitCategoryDto, BenefitCategoryUpsertDto, BenefitCategorySearchDto>,
      IBenefitCategoryService
{
    public BenefitCategoryService(ApplicationDbContext context, IMemoryCache cache, ILogger<BenefitCategoryService> logger)
        : base(context, cache, logger)
    {
    }

    protected override string EntityName => "Kategorija pogodnosti";

    protected override IQueryable<BenefitCategory> BaseQuery() => Context.BenefitCategories.Include(c => c.Benefits);

    protected override IQueryable<LookupDto> LookupQuery() =>
        Context.BenefitCategories
            .Where(c => !c.IsDeleted)
            .OrderBy(c => c.Name)
            .Select(c => new LookupDto { Id = c.Id, Name = c.Name });

    protected override IQueryable<BenefitCategory> ApplyFilters(IQueryable<BenefitCategory> query, BenefitCategorySearchDto request)
    {
        if (!string.IsNullOrWhiteSpace(request.Query))
        {
            var term = request.Query.Trim();
            query = query.Where(c => c.Name.Contains(term));
        }

        return query;
    }

    protected override IQueryable<BenefitCategory> ApplyDefaultSort(IQueryable<BenefitCategory> query) => query.OrderBy(c => c.Name);

    protected override BenefitCategoryDto MapToDto(BenefitCategory e) => new()
    {
        Id = e.Id,
        Name = e.Name,
        Description = e.Description,
        IconName = e.IconName,
        BenefitCount = e.Benefits.Count(b => !b.IsDeleted)
    };

    protected override async Task MapAsync(BenefitCategory entity, BenefitCategoryUpsertDto dto, CancellationToken cancellationToken)
    {
        var duplicate = await Context.BenefitCategories
            .AnyAsync(c => c.Id != entity.Id && !c.IsDeleted && c.Name == dto.Name, cancellationToken);
        if (duplicate)
        {
            throw new ValidationException(nameof(dto.Name), "Kategorija pogodnosti sa ovim nazivom vec postoji.");
        }

        entity.Name = dto.Name.Trim();
        entity.Description = dto.Description?.Trim();
        entity.IconName = dto.IconName?.Trim();
    }

    protected override async Task EnsureCanDeleteAsync(BenefitCategory entity, CancellationToken cancellationToken)
    {
        var benefitCount = await Context.Benefits.CountAsync(b => b.BenefitCategoryId == entity.Id && !b.IsDeleted, cancellationToken);
        EnsureNotReferenced(EntityName, "Pogodnosti", benefitCount);
    }
}

public class AnnouncementCategoryService
    : ReferenceCrudServiceBase<AnnouncementCategory, AnnouncementCategoryDto, AnnouncementCategoryUpsertDto, AnnouncementCategorySearchDto>,
      IAnnouncementCategoryService
{
    public AnnouncementCategoryService(ApplicationDbContext context, IMemoryCache cache, ILogger<AnnouncementCategoryService> logger)
        : base(context, cache, logger)
    {
    }

    protected override string EntityName => "Kategorija obavijesti";

    protected override IQueryable<AnnouncementCategory> BaseQuery() => Context.AnnouncementCategories.Include(c => c.Announcements);

    protected override IQueryable<LookupDto> LookupQuery() =>
        Context.AnnouncementCategories
            .Where(c => !c.IsDeleted)
            .OrderBy(c => c.Name)
            .Select(c => new LookupDto { Id = c.Id, Name = c.Name });

    protected override IQueryable<AnnouncementCategory> ApplyFilters(IQueryable<AnnouncementCategory> query, AnnouncementCategorySearchDto request)
    {
        if (!string.IsNullOrWhiteSpace(request.Query))
        {
            var term = request.Query.Trim();
            query = query.Where(c => c.Name.Contains(term));
        }

        return query;
    }

    protected override IQueryable<AnnouncementCategory> ApplyDefaultSort(IQueryable<AnnouncementCategory> query) => query.OrderBy(c => c.Name);

    protected override AnnouncementCategoryDto MapToDto(AnnouncementCategory e) => new()
    {
        Id = e.Id,
        Name = e.Name,
        Description = e.Description,
        AnnouncementCount = e.Announcements.Count(a => !a.IsDeleted)
    };

    protected override async Task MapAsync(AnnouncementCategory entity, AnnouncementCategoryUpsertDto dto, CancellationToken cancellationToken)
    {
        var duplicate = await Context.AnnouncementCategories
            .AnyAsync(c => c.Id != entity.Id && !c.IsDeleted && c.Name == dto.Name, cancellationToken);
        if (duplicate)
        {
            throw new ValidationException(nameof(dto.Name), "Kategorija obavijesti sa ovim nazivom vec postoji.");
        }

        entity.Name = dto.Name.Trim();
        entity.Description = dto.Description?.Trim();
    }

    protected override async Task EnsureCanDeleteAsync(AnnouncementCategory entity, CancellationToken cancellationToken)
    {
        var announcementCount = await Context.Announcements
            .CountAsync(a => a.AnnouncementCategoryId == entity.Id && !a.IsDeleted, cancellationToken);
        EnsureNotReferenced(EntityName, "Obavijesti", announcementCount);
    }
}

public class PaymentMethodService
    : ReferenceCrudServiceBase<PaymentMethod, PaymentMethodDto, PaymentMethodUpsertDto, PaymentMethodSearchDto>,
      IPaymentMethodService
{
    public PaymentMethodService(ApplicationDbContext context, IMemoryCache cache, ILogger<PaymentMethodService> logger)
        : base(context, cache, logger)
    {
    }

    protected override string EntityName => "Nacin placanja";

    protected override IQueryable<PaymentMethod> BaseQuery() => Context.PaymentMethods.Include(p => p.Orders);

    protected override IQueryable<LookupDto> LookupQuery() =>
        Context.PaymentMethods
            .Where(p => !p.IsDeleted && p.IsActive)
            .OrderBy(p => p.Name)
            .Select(p => new LookupDto { Id = p.Id, Name = p.Name });

    protected override IQueryable<PaymentMethod> ApplyFilters(IQueryable<PaymentMethod> query, PaymentMethodSearchDto request)
    {
        if (!string.IsNullOrWhiteSpace(request.Query))
        {
            var term = request.Query.Trim();
            query = query.Where(p => p.Name.Contains(term) || p.Code.Contains(term));
        }

        if (request.IsActive.HasValue)
        {
            query = query.Where(p => p.IsActive == request.IsActive.Value);
        }

        if (request.IsOnline.HasValue)
        {
            query = query.Where(p => p.IsOnline == request.IsOnline.Value);
        }

        return query;
    }

    protected override IQueryable<PaymentMethod> ApplyDefaultSort(IQueryable<PaymentMethod> query) => query.OrderBy(p => p.Name);

    protected override PaymentMethodDto MapToDto(PaymentMethod e) => new()
    {
        Id = e.Id,
        Name = e.Name,
        Code = e.Code,
        IsOnline = e.IsOnline,
        IsActive = e.IsActive,
        OrderCount = e.Orders.Count(o => !o.IsDeleted)
    };

    protected override async Task MapAsync(PaymentMethod entity, PaymentMethodUpsertDto dto, CancellationToken cancellationToken)
    {
        var code = dto.Code.Trim().ToUpperInvariant();

        var duplicate = await Context.PaymentMethods
            .AnyAsync(p => p.Id != entity.Id && !p.IsDeleted && p.Code == code, cancellationToken);
        if (duplicate)
        {
            throw new ValidationException(nameof(dto.Code), "Nacin placanja sa ovom oznakom vec postoji.");
        }

        entity.Name = dto.Name.Trim();
        entity.Code = code;
        entity.IsOnline = dto.IsOnline;
        entity.IsActive = dto.IsActive;
    }

    protected override async Task EnsureCanDeleteAsync(PaymentMethod entity, CancellationToken cancellationToken)
    {
        var orderCount = await Context.SkiPassOrders.CountAsync(o => o.PaymentMethodId == entity.Id && !o.IsDeleted, cancellationToken);
        EnsureNotReferenced(EntityName, "Narudzbe", orderCount);

        var paymentCount = await Context.Payments.CountAsync(p => p.PaymentMethodId == entity.Id && !p.IsDeleted, cancellationToken);
        EnsureNotReferenced(EntityName, "Placanja", paymentCount);
    }
}
