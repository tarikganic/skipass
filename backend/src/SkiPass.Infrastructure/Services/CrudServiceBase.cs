using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;
using SkiPass.Application.Common;
using SkiPass.Application.Exceptions;
using SkiPass.Application.Services.Interfaces;
using SkiPass.Domain.Entities;
using SkiPass.Infrastructure.Data;

namespace SkiPass.Infrastructure.Services;

/// <summary>
/// Zajednicka implementacija CRUD operacija. Izdvojena je da bi se izbjeglo
/// ponavljanje iste logike u svakom servisu (DRY), a specificni servisi
/// nadjacavaju samo ono sto im je stvarno potrebno.
/// </summary>
public abstract class CrudServiceBase<TEntity, TDto, TCreateDto, TUpdateDto, TSearchDto>
    : ICrudService<TDto, TCreateDto, TUpdateDto, TSearchDto>
    where TEntity : BaseEntity, new()
    where TSearchDto : PagedRequest
{
    protected readonly ApplicationDbContext Context;
    protected readonly ILogger Logger;

    protected CrudServiceBase(ApplicationDbContext context, ILogger logger)
    {
        Context = context;
        Logger = logger;
    }

    /// <summary>Naziv entiteta koji se koristi u porukama o greskama.</summary>
    protected abstract string EntityName { get; }

    /// <summary>Osnovni upit sa svim Include-ovima potrebnim za mapiranje u DTO.</summary>
    protected abstract IQueryable<TEntity> BaseQuery();

    protected abstract TDto MapToDto(TEntity entity);

    /// <summary>Primjenjuje filtere pretrage. Svaki list endpoint ima najmanje jedan parametar.</summary>
    protected abstract IQueryable<TEntity> ApplyFilters(IQueryable<TEntity> query, TSearchDto request);

    /// <summary>Podrazumijevano sortiranje kada klijent ne posalje SortBy.</summary>
    protected virtual IQueryable<TEntity> ApplyDefaultSort(IQueryable<TEntity> query) =>
        query.OrderByDescending(e => e.Id);

    /// <summary>Sortiranje po polju koje je klijent zatrazio. Nepoznata polja se ignorisu.</summary>
    protected virtual IQueryable<TEntity>? ApplySort(IQueryable<TEntity> query, string sortBy, bool descending) => null;

    protected abstract Task MapCreateAsync(TEntity entity, TCreateDto dto, CancellationToken cancellationToken);

    protected abstract Task MapUpdateAsync(TEntity entity, TUpdateDto dto, CancellationToken cancellationToken);

    /// <summary>Provjera poslovnih preduslova prije brisanja (npr. postojanje povezanih zapisa).</summary>
    protected virtual Task EnsureCanDeleteAsync(TEntity entity, CancellationToken cancellationToken) =>
        Task.CompletedTask;

    public virtual async Task<PagedResult<TDto>> SearchAsync(TSearchDto request, CancellationToken cancellationToken = default)
    {
        var query = BaseQuery();

        // IncludeDeleted se namjerno ignorise ovdje: ova osnovna pretraga je dostupna
        // svakom prijavljenom korisniku (citanje referentnih i glavnih podataka), pa
        // ne postoji provjera role koja bi potvrdila da je pozivalac administrator.
        // Nijedan klijent trenutno ne salje ovaj parametar - meko obrisani zapisi se
        // zato uvijek iskljucuju iz ove metode.
        query = query.Where(e => !e.IsDeleted);

        query = ApplyFilters(query, request);

        var totalCount = await query.CountAsync(cancellationToken);

        query = (string.IsNullOrWhiteSpace(request.SortBy)
            ? null
            : ApplySort(query, request.SortBy.Trim(), request.SortDescending)) ?? ApplyDefaultSort(query);

        var entities = await query
            .Skip((request.Page - 1) * request.PageSize)
            .Take(request.PageSize)
            .AsNoTracking()
            .ToListAsync(cancellationToken);

        return entities.Select(MapToDto).ToList().ToPagedResult(totalCount, request);
    }

    public virtual async Task<TDto> GetByIdAsync(int id, CancellationToken cancellationToken = default)
    {
        var entity = await BaseQuery()
            .AsNoTracking()
            .FirstOrDefaultAsync(e => e.Id == id && !e.IsDeleted, cancellationToken)
            ?? throw NotFoundException.For(EntityName, id);

        return MapToDto(entity);
    }

    public virtual async Task<TDto> CreateAsync(TCreateDto dto, CancellationToken cancellationToken = default)
    {
        var entity = new TEntity();
        await MapCreateAsync(entity, dto, cancellationToken);

        Context.Set<TEntity>().Add(entity);
        await Context.SaveChangesAsync(cancellationToken);

        Logger.LogInformation("Kreiran zapis {EntityName} sa identifikatorom {EntityId}.", EntityName, entity.Id);
        return await GetByIdAsync(entity.Id, cancellationToken);
    }

    public virtual async Task<TDto> UpdateAsync(int id, TUpdateDto dto, CancellationToken cancellationToken = default)
    {
        var entity = await Context.Set<TEntity>()
            .FirstOrDefaultAsync(e => e.Id == id && !e.IsDeleted, cancellationToken)
            ?? throw NotFoundException.For(EntityName, id);

        await MapUpdateAsync(entity, dto, cancellationToken);
        await Context.SaveChangesAsync(cancellationToken);

        Logger.LogInformation("Azuriran zapis {EntityName} sa identifikatorom {EntityId}.", EntityName, entity.Id);
        return await GetByIdAsync(entity.Id, cancellationToken);
    }

    /// <summary>
    /// Soft delete: zapis se oznacava kao obrisan tek nakon provjere da ga ne koriste drugi entiteti.
    /// </summary>
    public virtual async Task DeleteAsync(int id, CancellationToken cancellationToken = default)
    {
        var entity = await Context.Set<TEntity>()
            .FirstOrDefaultAsync(e => e.Id == id && !e.IsDeleted, cancellationToken)
            ?? throw NotFoundException.For(EntityName, id);

        await EnsureCanDeleteAsync(entity, cancellationToken);

        entity.IsDeleted = true;
        await Context.SaveChangesAsync(cancellationToken);

        Logger.LogInformation("Obrisan zapis {EntityName} sa identifikatorom {EntityId}.", EntityName, entity.Id);
    }

    /// <summary>Provjerava da li povezani zapisi sprjecavaju brisanje i baca jasnu poruku ako sprjecavaju.</summary>
    protected static void EnsureNotReferenced(string entityName, string usedBy, int count)
    {
        if (count > 0)
        {
            throw new ReferencedEntityException(entityName, usedBy, count);
        }
    }

    /// <summary>Sigurno parsira enum vrijednost poslanu kao string i vraca jasnu validacijsku gresku.</summary>
    protected static TEnum ParseEnum<TEnum>(string value, string field) where TEnum : struct, Enum
    {
        if (!Enum.TryParse<TEnum>(value, ignoreCase: true, out var parsed) || !Enum.IsDefined(parsed))
        {
            var allowed = string.Join(", ", Enum.GetNames<TEnum>());
            throw new ValidationException(field, $"Nepoznata vrijednost \"{value}\". Dozvoljene vrijednosti su: {allowed}.");
        }

        return parsed;
    }

    protected static TEnum? ParseOptionalEnum<TEnum>(string? value, string field) where TEnum : struct, Enum =>
        string.IsNullOrWhiteSpace(value) ? null : ParseEnum<TEnum>(value, field);
}

/// <summary>Varijanta za entitete koji koriste isti DTO za kreiranje i izmjenu.</summary>
public abstract class CrudServiceBase<TEntity, TDto, TUpsertDto, TSearchDto>
    : CrudServiceBase<TEntity, TDto, TUpsertDto, TUpsertDto, TSearchDto>,
      ICrudService<TDto, TUpsertDto, TSearchDto>
    where TEntity : BaseEntity, new()
    where TSearchDto : PagedRequest
{
    protected CrudServiceBase(ApplicationDbContext context, ILogger logger) : base(context, logger)
    {
    }

    /// <summary>Jedinstveno mapiranje koje se koristi i pri kreiranju i pri izmjeni zapisa.</summary>
    protected abstract Task MapAsync(TEntity entity, TUpsertDto dto, CancellationToken cancellationToken);

    protected sealed override Task MapCreateAsync(TEntity entity, TUpsertDto dto, CancellationToken cancellationToken) =>
        MapAsync(entity, dto, cancellationToken);

    protected sealed override Task MapUpdateAsync(TEntity entity, TUpsertDto dto, CancellationToken cancellationToken) =>
        MapAsync(entity, dto, cancellationToken);
}
