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

public class CountryService
    : ReferenceCrudServiceBase<Country, CountryDto, CountryUpsertDto, CountrySearchDto>, ICountryService
{
    public CountryService(ApplicationDbContext context, IMemoryCache cache, ILogger<CountryService> logger)
        : base(context, cache, logger)
    {
    }

    protected override string EntityName => "Drzava";

    protected override IQueryable<Country> BaseQuery() =>
        Context.Countries.Include(c => c.Cities);

    protected override IQueryable<LookupDto> LookupQuery() =>
        Context.Countries
            .Where(c => !c.IsDeleted)
            .OrderBy(c => c.Name)
            .Select(c => new LookupDto { Id = c.Id, Name = c.Name });

    protected override IQueryable<Country> ApplyFilters(IQueryable<Country> query, CountrySearchDto request)
    {
        if (!string.IsNullOrWhiteSpace(request.Query))
        {
            var term = request.Query.Trim();
            query = query.Where(c => c.Name.Contains(term) || c.IsoCode.Contains(term));
        }

        return query;
    }

    protected override IQueryable<Country> ApplyDefaultSort(IQueryable<Country> query) => query.OrderBy(c => c.Name);

    protected override IQueryable<Country>? ApplySort(IQueryable<Country> query, string sortBy, bool descending) =>
        sortBy.ToLowerInvariant() switch
        {
            "name" => descending ? query.OrderByDescending(c => c.Name) : query.OrderBy(c => c.Name),
            "isocode" => descending ? query.OrderByDescending(c => c.IsoCode) : query.OrderBy(c => c.IsoCode),
            _ => null
        };

    protected override CountryDto MapToDto(Country e) => new()
    {
        Id = e.Id,
        Name = e.Name,
        IsoCode = e.IsoCode,
        CityCount = e.Cities.Count(c => !c.IsDeleted)
    };

    protected override async Task MapAsync(Country entity, CountryUpsertDto dto, CancellationToken cancellationToken)
    {
        var isoCode = dto.IsoCode.Trim().ToUpperInvariant();

        var nameTaken = await Context.Countries
            .AnyAsync(c => c.Id != entity.Id && !c.IsDeleted && c.Name == dto.Name, cancellationToken);
        if (nameTaken)
        {
            throw new ValidationException(nameof(dto.Name), "Drzava sa ovim nazivom vec postoji.");
        }

        var isoTaken = await Context.Countries
            .AnyAsync(c => c.Id != entity.Id && !c.IsDeleted && c.IsoCode == isoCode, cancellationToken);
        if (isoTaken)
        {
            throw new ValidationException(nameof(dto.IsoCode), "Drzava sa ovom ISO oznakom vec postoji.");
        }

        entity.Name = dto.Name.Trim();
        entity.IsoCode = isoCode;
    }

    protected override async Task EnsureCanDeleteAsync(Country entity, CancellationToken cancellationToken)
    {
        var cityCount = await Context.Cities
            .CountAsync(c => c.CountryId == entity.Id && !c.IsDeleted, cancellationToken);

        EnsureNotReferenced(EntityName, "Gradovi", cityCount);
    }
}

public class CityService
    : ReferenceCrudServiceBase<City, CityDto, CityUpsertDto, CitySearchDto>, ICityService
{
    public CityService(ApplicationDbContext context, IMemoryCache cache, ILogger<CityService> logger)
        : base(context, cache, logger)
    {
    }

    protected override string EntityName => "Grad";

    protected override IQueryable<City> BaseQuery() =>
        Context.Cities.Include(c => c.Country);

    protected override IQueryable<LookupDto> LookupQuery() =>
        Context.Cities
            .Where(c => !c.IsDeleted)
            .OrderBy(c => c.Name)
            .Select(c => new LookupDto { Id = c.Id, Name = c.Name });

    public async Task<List<LookupDto>> GetLookupByCountryAsync(int countryId, CancellationToken cancellationToken = default) =>
        await Context.Cities
            .Where(c => !c.IsDeleted && c.CountryId == countryId)
            .OrderBy(c => c.Name)
            .Select(c => new LookupDto { Id = c.Id, Name = c.Name })
            .AsNoTracking()
            .ToListAsync(cancellationToken);

    protected override IQueryable<City> ApplyFilters(IQueryable<City> query, CitySearchDto request)
    {
        if (!string.IsNullOrWhiteSpace(request.Query))
        {
            var term = request.Query.Trim();
            query = query.Where(c => c.Name.Contains(term) || (c.PostalCode != null && c.PostalCode.Contains(term)));
        }

        if (request.CountryId.HasValue)
        {
            query = query.Where(c => c.CountryId == request.CountryId.Value);
        }

        return query;
    }

    protected override IQueryable<City> ApplyDefaultSort(IQueryable<City> query) => query.OrderBy(c => c.Name);

    protected override IQueryable<City>? ApplySort(IQueryable<City> query, string sortBy, bool descending) =>
        sortBy.ToLowerInvariant() switch
        {
            "name" => descending ? query.OrderByDescending(c => c.Name) : query.OrderBy(c => c.Name),
            "country" => descending ? query.OrderByDescending(c => c.Country.Name) : query.OrderBy(c => c.Country.Name),
            _ => null
        };

    protected override CityDto MapToDto(City e) => new()
    {
        Id = e.Id,
        Name = e.Name,
        PostalCode = e.PostalCode,
        CountryId = e.CountryId,
        CountryName = e.Country.Name
    };

    protected override async Task MapAsync(City entity, CityUpsertDto dto, CancellationToken cancellationToken)
    {
        var countryExists = await Context.Countries
            .AnyAsync(c => c.Id == dto.CountryId && !c.IsDeleted, cancellationToken);
        if (!countryExists)
        {
            throw new ValidationException(nameof(dto.CountryId), "Odabrana drzava ne postoji.");
        }

        var duplicate = await Context.Cities.AnyAsync(
            c => c.Id != entity.Id && !c.IsDeleted && c.CountryId == dto.CountryId && c.Name == dto.Name,
            cancellationToken);
        if (duplicate)
        {
            throw new ValidationException(nameof(dto.Name), "Grad sa ovim nazivom vec postoji u odabranoj drzavi.");
        }

        entity.Name = dto.Name.Trim();
        entity.PostalCode = dto.PostalCode?.Trim();
        entity.CountryId = dto.CountryId;
    }

    protected override async Task EnsureCanDeleteAsync(City entity, CancellationToken cancellationToken)
    {
        var userCount = await Context.UserProfiles.CountAsync(u => u.CityId == entity.Id && !u.IsDeleted, cancellationToken);
        EnsureNotReferenced(EntityName, "Korisnici", userCount);

        var resortCount = await Context.SkiResorts.CountAsync(r => r.CityId == entity.Id && !r.IsDeleted, cancellationToken);
        EnsureNotReferenced(EntityName, "Skijalista", resortCount);

        var partnerCount = await Context.Partners.CountAsync(p => p.CityId == entity.Id && !p.IsDeleted, cancellationToken);
        EnsureNotReferenced(EntityName, "Partneri", partnerCount);
    }
}
