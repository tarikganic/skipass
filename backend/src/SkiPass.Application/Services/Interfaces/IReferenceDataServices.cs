using SkiPass.Application.Common;
using SkiPass.Application.DTOs.Common;
using SkiPass.Application.DTOs.Reference;

namespace SkiPass.Application.Services.Interfaces;

/// <summary>
/// Referentni podaci se cesto ucitavaju za punjenje padajucih lista,
/// pa svaki referentni servis nudi i kesiranu lookup listu.
/// </summary>
public interface ILookupProvider
{
    Task<List<LookupDto>> GetLookupAsync(CancellationToken cancellationToken = default);
}

public interface ICountryService
    : ICrudService<CountryDto, CountryUpsertDto, CountrySearchDto>, ILookupProvider
{
}

public interface ICityService
    : ICrudService<CityDto, CityUpsertDto, CitySearchDto>, ILookupProvider
{
    Task<List<LookupDto>> GetLookupByCountryAsync(int countryId, CancellationToken cancellationToken = default);
}

public interface ITrailDifficultyService
    : ICrudService<TrailDifficultyDto, TrailDifficultyUpsertDto, TrailDifficultySearchDto>, ILookupProvider
{
}

public interface ILiftTypeService
    : ICrudService<LiftTypeDto, LiftTypeUpsertDto, LiftTypeSearchDto>, ILookupProvider
{
}

public interface IIncidentTypeService
    : ICrudService<IncidentTypeDto, IncidentTypeUpsertDto, IncidentTypeSearchDto>, ILookupProvider
{
}

public interface IBenefitCategoryService
    : ICrudService<BenefitCategoryDto, BenefitCategoryUpsertDto, BenefitCategorySearchDto>, ILookupProvider
{
}

public interface IAnnouncementCategoryService
    : ICrudService<AnnouncementCategoryDto, AnnouncementCategoryUpsertDto, AnnouncementCategorySearchDto>, ILookupProvider
{
}

public interface IPaymentMethodService
    : ICrudService<PaymentMethodDto, PaymentMethodUpsertDto, PaymentMethodSearchDto>, ILookupProvider
{
}

/// <summary>Enumeracije koje klijenti koriste za punjenje padajucih lista statusa i tipova.</summary>
public interface IEnumLookupService
{
    IReadOnlyDictionary<string, List<LookupDto>> GetAll();
    List<LookupDto> Get(string enumName);
}
