using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;
using SkiPass.Application.DTOs.Benefits;
using SkiPass.Application.DTOs.Common;
using SkiPass.Application.Exceptions;
using SkiPass.Application.Services.Interfaces;
using SkiPass.Domain.Entities;
using SkiPass.Infrastructure.Data;

namespace SkiPass.Infrastructure.Services;

public class PartnerService
    : CrudServiceBase<Partner, PartnerDto, PartnerUpsertDto, PartnerSearchDto>, IPartnerService
{
    public PartnerService(ApplicationDbContext context, ILogger<PartnerService> logger)
        : base(context, logger)
    {
    }

    protected override string EntityName => "Partner";

    protected override IQueryable<Partner> BaseQuery() =>
        Context.Partners
            .Include(p => p.City)
            .Include(p => p.Benefits);

    public async Task<List<LookupDto>> GetLookupAsync(CancellationToken cancellationToken = default) =>
        await Context.Partners
            .Where(p => !p.IsDeleted && p.IsActive)
            .OrderBy(p => p.Name)
            .Select(p => new LookupDto { Id = p.Id, Name = p.Name })
            .AsNoTracking()
            .ToListAsync(cancellationToken);

    protected override IQueryable<Partner> ApplyFilters(IQueryable<Partner> query, PartnerSearchDto request)
    {
        if (!string.IsNullOrWhiteSpace(request.Query))
        {
            var term = request.Query.Trim();
            query = query.Where(p =>
                p.Name.Contains(term) ||
                (p.Description != null && p.Description.Contains(term)) ||
                (p.Address != null && p.Address.Contains(term)));
        }

        if (request.CityId.HasValue)
        {
            query = query.Where(p => p.CityId == request.CityId.Value);
        }

        if (request.IsActive.HasValue)
        {
            query = query.Where(p => p.IsActive == request.IsActive.Value);
        }

        return query;
    }

    protected override IQueryable<Partner> ApplyDefaultSort(IQueryable<Partner> query) => query.OrderBy(p => p.Name);

    protected override PartnerDto MapToDto(Partner e) => new()
    {
        Id = e.Id,
        Name = e.Name,
        Description = e.Description,
        ContactEmail = e.ContactEmail,
        ContactPhone = e.ContactPhone,
        Website = e.Website,
        LogoUrl = e.LogoUrl,
        Address = e.Address,
        IsActive = e.IsActive,
        CityId = e.CityId,
        CityName = e.City?.Name,
        BenefitCount = e.Benefits.Count(b => !b.IsDeleted)
    };

    protected override async Task MapAsync(Partner entity, PartnerUpsertDto dto, CancellationToken cancellationToken)
    {
        if (dto.CityId.HasValue)
        {
            var cityExists = await Context.Cities.AnyAsync(c => c.Id == dto.CityId.Value && !c.IsDeleted, cancellationToken);
            if (!cityExists)
            {
                throw new ValidationException(nameof(dto.CityId), "Odabrani grad ne postoji.");
            }
        }

        var duplicate = await Context.Partners
            .AnyAsync(p => p.Id != entity.Id && !p.IsDeleted && p.Name == dto.Name, cancellationToken);
        if (duplicate)
        {
            throw new ValidationException(nameof(dto.Name), "Partner sa ovim nazivom vec postoji.");
        }

        entity.Name = dto.Name.Trim();
        entity.Description = dto.Description?.Trim();
        entity.ContactEmail = dto.ContactEmail?.Trim();
        entity.ContactPhone = dto.ContactPhone?.Trim();
        entity.Website = dto.Website?.Trim();
        entity.LogoUrl = dto.LogoUrl?.Trim();
        entity.Address = dto.Address?.Trim();
        entity.IsActive = dto.IsActive;
        entity.CityId = dto.CityId;
    }

    protected override async Task EnsureCanDeleteAsync(Partner entity, CancellationToken cancellationToken)
    {
        var benefitCount = await Context.Benefits.CountAsync(b => b.PartnerId == entity.Id && !b.IsDeleted, cancellationToken);
        EnsureNotReferenced(EntityName, "Pogodnosti", benefitCount);
    }
}
