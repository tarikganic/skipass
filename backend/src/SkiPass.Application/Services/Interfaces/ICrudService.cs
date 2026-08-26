using SkiPass.Application.Common;

namespace SkiPass.Application.Services.Interfaces;

/// <summary>
/// Zajednicki ugovor za CRUD operacije. Sve list operacije su obavezno stranicirane
/// i prihvataju najmanje jedan parametar pretrage.
/// </summary>
public interface ICrudService<TDto, TCreateDto, TUpdateDto, TSearchDto>
    where TSearchDto : PagedRequest
{
    Task<PagedResult<TDto>> SearchAsync(TSearchDto request, CancellationToken cancellationToken = default);
    Task<TDto> GetByIdAsync(int id, CancellationToken cancellationToken = default);
    Task<TDto> CreateAsync(TCreateDto dto, CancellationToken cancellationToken = default);
    Task<TDto> UpdateAsync(int id, TUpdateDto dto, CancellationToken cancellationToken = default);
    Task DeleteAsync(int id, CancellationToken cancellationToken = default);
}

/// <summary>Varijanta za entitete koji koriste isti DTO za kreiranje i izmjenu.</summary>
public interface ICrudService<TDto, TUpsertDto, TSearchDto>
    : ICrudService<TDto, TUpsertDto, TUpsertDto, TSearchDto>
    where TSearchDto : PagedRequest
{
}
