using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Caching.Memory;
using Microsoft.Extensions.Logging;
using SkiPass.Application.Common;
using SkiPass.Application.DTOs.Common;
using SkiPass.Application.Services.Interfaces;
using SkiPass.Domain.Entities;
using SkiPass.Infrastructure.Data;

namespace SkiPass.Infrastructure.Services.Reference;

/// <summary>
/// Osnova za servise referentnih podataka. Lookup liste se ucitavaju na skoro svaki
/// zahtjev klijenta, pa se kesiraju na servisnom nivou i invalidiraju pri svakoj izmjeni.
/// </summary>
public abstract class ReferenceCrudServiceBase<TEntity, TDto, TUpsertDto, TSearchDto>
    : CrudServiceBase<TEntity, TDto, TUpsertDto, TSearchDto>, ILookupProvider
    where TEntity : BaseEntity, new()
    where TSearchDto : PagedRequest
{
    private static readonly TimeSpan LookupCacheDuration = TimeSpan.FromMinutes(10);

    private readonly IMemoryCache _cache;

    protected ReferenceCrudServiceBase(ApplicationDbContext context, IMemoryCache cache, ILogger logger)
        : base(context, logger)
    {
        _cache = cache;
    }

    protected string LookupCacheKey => $"lookup:{typeof(TEntity).Name}";

    /// <summary>Upit koji vraca aktivne zapise za punjenje padajucih lista.</summary>
    protected abstract IQueryable<LookupDto> LookupQuery();

    public async Task<List<LookupDto>> GetLookupAsync(CancellationToken cancellationToken = default)
    {
        if (_cache.TryGetValue(LookupCacheKey, out List<LookupDto>? cached) && cached is not null)
        {
            return cached;
        }

        var items = await LookupQuery().AsNoTracking().ToListAsync(cancellationToken);
        _cache.Set(LookupCacheKey, items, LookupCacheDuration);
        return items;
    }

    protected void InvalidateLookupCache() => _cache.Remove(LookupCacheKey);

    public override async Task<TDto> CreateAsync(TUpsertDto dto, CancellationToken cancellationToken = default)
    {
        var result = await base.CreateAsync(dto, cancellationToken);
        InvalidateLookupCache();
        return result;
    }

    public override async Task<TDto> UpdateAsync(int id, TUpsertDto dto, CancellationToken cancellationToken = default)
    {
        var result = await base.UpdateAsync(id, dto, cancellationToken);
        InvalidateLookupCache();
        return result;
    }

    public override async Task DeleteAsync(int id, CancellationToken cancellationToken = default)
    {
        await base.DeleteAsync(id, cancellationToken);
        InvalidateLookupCache();
    }
}
