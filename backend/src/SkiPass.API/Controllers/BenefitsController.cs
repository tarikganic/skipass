using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using SkiPass.Application.Common;
using SkiPass.Application.DTOs.Benefits;
using SkiPass.Application.DTOs.Common;
using SkiPass.Application.Services.Interfaces;
using SkiPass.Domain.Constants;

namespace SkiPass.API.Controllers;

[ApiController]
[Route("api/[controller]")]
[Authorize]
[Produces("application/json")]
public class BenefitsController : ControllerBase
{
    private readonly IBenefitService _benefitService;
    private readonly IBenefitViewService _benefitViewService;
    private readonly ICurrentUserService _currentUserService;

    public BenefitsController(
        IBenefitService benefitService,
        IBenefitViewService benefitViewService,
        ICurrentUserService currentUserService)
    {
        _benefitService = benefitService;
        _benefitViewService = benefitViewService;
        _currentUserService = currentUserService;
    }

    [HttpGet]
    public async Task<ActionResult<PagedResult<BenefitDto>>> Search([FromQuery] BenefitSearchDto request, CancellationToken cancellationToken) =>
        Ok(await _benefitService.SearchAsync(request, cancellationToken));

    [HttpGet("lookup")]
    public async Task<ActionResult<List<LookupDto>>> Lookup(CancellationToken cancellationToken) =>
        Ok(await _benefitService.GetLookupAsync(cancellationToken));

    [HttpGet("{id:int}")]
    public async Task<ActionResult<BenefitDto>> GetById(int id, CancellationToken cancellationToken) =>
        Ok(await _benefitService.GetByIdAsync(id, cancellationToken));

    /// <summary>
    /// Evidentira pregled pogodnosti. Ovi zapisi su stvarni ulazni signal
    /// za sistem preporuke, pa ih klijent salje pri otvaranju detalja.
    /// </summary>
    [HttpPost("{id:int}/views")]
    public async Task<ActionResult<BenefitViewDto>> TrackView(
        int id,
        [FromBody] BenefitViewCreateDto dto,
        CancellationToken cancellationToken)
    {
        dto.BenefitId = id;
        var userId = _currentUserService.GetRequiredUserId();
        return Ok(await _benefitViewService.TrackAsync(dto, userId, cancellationToken));
    }

    /// <summary>Historija pregleda pogodnosti.</summary>
    [HttpGet("views")]
    public async Task<ActionResult<PagedResult<BenefitViewDto>>> SearchViews(
        [FromQuery] BenefitViewSearchDto request,
        CancellationToken cancellationToken) =>
        Ok(await _benefitViewService.SearchAsync(request, cancellationToken));

    [HttpPost]
    [Authorize(Roles = Roles.StaffOrAdmin)]
    public async Task<ActionResult<BenefitDto>> Create([FromBody] BenefitUpsertDto dto, CancellationToken cancellationToken)
    {
        var created = await _benefitService.CreateAsync(dto, cancellationToken);
        return CreatedAtAction(nameof(GetById), new { id = created.Id }, created);
    }

    [HttpPut("{id:int}")]
    [Authorize(Roles = Roles.StaffOrAdmin)]
    public async Task<ActionResult<BenefitDto>> Update(int id, [FromBody] BenefitUpsertDto dto, CancellationToken cancellationToken) =>
        Ok(await _benefitService.UpdateAsync(id, dto, cancellationToken));

    [HttpDelete("{id:int}")]
    [Authorize(Roles = Roles.Admin)]
    public async Task<IActionResult> Delete(int id, CancellationToken cancellationToken)
    {
        await _benefitService.DeleteAsync(id, cancellationToken);
        return Ok(new { message = "Pogodnost je uspjesno obrisana." });
    }
}

[ApiController]
[Route("api/benefit-purchases")]
[Authorize]
[Produces("application/json")]
public class BenefitPurchasesController : ControllerBase
{
    private readonly IBenefitPurchaseService _service;
    private readonly ICurrentUserService _currentUserService;

    public BenefitPurchasesController(IBenefitPurchaseService service, ICurrentUserService currentUserService)
    {
        _service = service;
        _currentUserService = currentUserService;
    }

    [HttpGet]
    public async Task<ActionResult<PagedResult<BenefitPurchaseDto>>> Search(
        [FromQuery] BenefitPurchaseSearchDto request,
        CancellationToken cancellationToken) =>
        Ok(await _service.SearchAsync(request, cancellationToken));

    [HttpGet("{id:int}")]
    public async Task<ActionResult<BenefitPurchaseDto>> GetById(int id, CancellationToken cancellationToken) =>
        Ok(await _service.GetByIdAsync(id, cancellationToken));

    [HttpPost]
    public async Task<ActionResult<BenefitPurchaseDto>> Create(
        [FromBody] BenefitPurchaseCreateDto dto,
        CancellationToken cancellationToken)
    {
        var userId = _currentUserService.GetRequiredUserId();
        var created = await _service.CreateForUserAsync(dto, userId, cancellationToken);
        return CreatedAtAction(nameof(GetById), new { id = created.Id }, created);
    }

    [HttpPatch("{id:int}/status")]
    public async Task<ActionResult<BenefitPurchaseDto>> UpdateStatus(
        int id,
        [FromBody] BenefitPurchaseStatusUpdateDto dto,
        CancellationToken cancellationToken) =>
        Ok(await _service.UpdateStatusAsync(id, dto, cancellationToken));

    [HttpDelete("{id:int}")]
    [Authorize(Roles = Roles.Admin)]
    public async Task<IActionResult> Delete(int id, CancellationToken cancellationToken)
    {
        await _service.DeleteAsync(id, cancellationToken);
        return Ok(new { message = "Kupovina pogodnosti je uspjesno obrisana." });
    }
}

[ApiController]
[Route("api/[controller]")]
[Authorize]
[Produces("application/json")]
public class PartnersController : ControllerBase
{
    private readonly IPartnerService _service;

    public PartnersController(IPartnerService service)
    {
        _service = service;
    }

    [HttpGet]
    public async Task<ActionResult<PagedResult<PartnerDto>>> Search([FromQuery] PartnerSearchDto request, CancellationToken cancellationToken) =>
        Ok(await _service.SearchAsync(request, cancellationToken));

    [HttpGet("lookup")]
    public async Task<ActionResult<List<LookupDto>>> Lookup(CancellationToken cancellationToken) =>
        Ok(await _service.GetLookupAsync(cancellationToken));

    [HttpGet("{id:int}")]
    public async Task<ActionResult<PartnerDto>> GetById(int id, CancellationToken cancellationToken) =>
        Ok(await _service.GetByIdAsync(id, cancellationToken));

    [HttpPost]
    [Authorize(Roles = Roles.StaffOrAdmin)]
    public async Task<ActionResult<PartnerDto>> Create([FromBody] PartnerUpsertDto dto, CancellationToken cancellationToken)
    {
        var created = await _service.CreateAsync(dto, cancellationToken);
        return CreatedAtAction(nameof(GetById), new { id = created.Id }, created);
    }

    [HttpPut("{id:int}")]
    [Authorize(Roles = Roles.StaffOrAdmin)]
    public async Task<ActionResult<PartnerDto>> Update(int id, [FromBody] PartnerUpsertDto dto, CancellationToken cancellationToken) =>
        Ok(await _service.UpdateAsync(id, dto, cancellationToken));

    [HttpDelete("{id:int}")]
    [Authorize(Roles = Roles.Admin)]
    public async Task<IActionResult> Delete(int id, CancellationToken cancellationToken)
    {
        await _service.DeleteAsync(id, cancellationToken);
        return Ok(new { message = "Partner je uspjesno obrisan." });
    }
}
