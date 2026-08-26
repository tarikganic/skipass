using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using SkiPass.Application.DTOs.Common;
using SkiPass.Application.DTOs.Reference;
using SkiPass.Application.Services.Interfaces;

namespace SkiPass.API.Controllers.Reference;

public class CountriesController
    : ReferenceControllerBase<ICountryService, CountryDto, CountryUpsertDto, CountrySearchDto>
{
    public CountriesController(ICountryService service) : base(service)
    {
    }

    protected override string EntityLabel => "Drzava";
}

public class CitiesController
    : ReferenceControllerBase<ICityService, CityDto, CityUpsertDto, CitySearchDto>
{
    public CitiesController(ICityService service) : base(service)
    {
    }

    protected override string EntityLabel => "Grad";

    /// <summary>Gradovi jedne drzave - koristi se za zavisne padajuce liste.</summary>
    [HttpGet("lookup/by-country/{countryId:int}")]
    public async Task<ActionResult<List<LookupDto>>> LookupByCountry(int countryId, CancellationToken cancellationToken) =>
        Ok(await Service.GetLookupByCountryAsync(countryId, cancellationToken));
}

public class TrailDifficultiesController
    : ReferenceControllerBase<ITrailDifficultyService, TrailDifficultyDto, TrailDifficultyUpsertDto, TrailDifficultySearchDto>
{
    public TrailDifficultiesController(ITrailDifficultyService service) : base(service)
    {
    }

    protected override string EntityLabel => "Tezina staze";
}

public class LiftTypesController
    : ReferenceControllerBase<ILiftTypeService, LiftTypeDto, LiftTypeUpsertDto, LiftTypeSearchDto>
{
    public LiftTypesController(ILiftTypeService service) : base(service)
    {
    }

    protected override string EntityLabel => "Tip ski lifta";
}

public class IncidentTypesController
    : ReferenceControllerBase<IIncidentTypeService, IncidentTypeDto, IncidentTypeUpsertDto, IncidentTypeSearchDto>
{
    public IncidentTypesController(IIncidentTypeService service) : base(service)
    {
    }

    protected override string EntityLabel => "Tip incidenta";
}

public class BenefitCategoriesController
    : ReferenceControllerBase<IBenefitCategoryService, BenefitCategoryDto, BenefitCategoryUpsertDto, BenefitCategorySearchDto>
{
    public BenefitCategoriesController(IBenefitCategoryService service) : base(service)
    {
    }

    protected override string EntityLabel => "Kategorija pogodnosti";
}

public class AnnouncementCategoriesController
    : ReferenceControllerBase<IAnnouncementCategoryService, AnnouncementCategoryDto, AnnouncementCategoryUpsertDto, AnnouncementCategorySearchDto>
{
    public AnnouncementCategoriesController(IAnnouncementCategoryService service) : base(service)
    {
    }

    protected override string EntityLabel => "Kategorija obavijesti";
}

public class PaymentMethodsController
    : ReferenceControllerBase<IPaymentMethodService, PaymentMethodDto, PaymentMethodUpsertDto, PaymentMethodSearchDto>
{
    public PaymentMethodsController(IPaymentMethodService service) : base(service)
    {
    }

    protected override string EntityLabel => "Nacin placanja";
}

/// <summary>
/// Izlaze enumeracije sistema kako bi klijenti punili padajuce liste statusa i tipova
/// iz jednog izvora umjesto iz hardkodiranih vrijednosti.
/// </summary>
[ApiController]
[Route("api/[controller]")]
[Authorize]
[Produces("application/json")]
public class EnumsController : ControllerBase
{
    private readonly IEnumLookupService _enumLookupService;

    public EnumsController(IEnumLookupService enumLookupService)
    {
        _enumLookupService = enumLookupService;
    }

    [HttpGet]
    public ActionResult<IReadOnlyDictionary<string, List<LookupDto>>> GetAll() =>
        Ok(_enumLookupService.GetAll());

    [HttpGet("{enumName}")]
    public ActionResult<List<LookupDto>> Get(string enumName) =>
        Ok(_enumLookupService.Get(enumName));
}
