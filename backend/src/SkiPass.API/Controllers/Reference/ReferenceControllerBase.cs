using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using SkiPass.Application.Common;
using SkiPass.Application.DTOs.Common;
using SkiPass.Application.Services.Interfaces;
using SkiPass.Domain.Constants;

namespace SkiPass.API.Controllers.Reference;

/// <summary>
/// Zajednicka osnova za kontrolere referentnih podataka.
/// Citanje je dostupno svim prijavljenim korisnicima jer se koristi za punjenje
/// padajucih lista, dok su izmjene ogranicene na administratore.
/// </summary>
[ApiController]
[Route("api/[controller]")]
[Authorize]
[Produces("application/json")]
public abstract class ReferenceControllerBase<TService, TDto, TUpsertDto, TSearchDto> : ControllerBase
    where TService : ICrudService<TDto, TUpsertDto, TSearchDto>, ILookupProvider
    where TSearchDto : PagedRequest
{
    protected readonly TService Service;

    protected ReferenceControllerBase(TService service)
    {
        Service = service;
    }

    /// <summary>Naziv entiteta u jednini, koristi se u porukama o uspjehu.</summary>
    protected abstract string EntityLabel { get; }

    [HttpGet]
    public async Task<ActionResult<PagedResult<TDto>>> Search([FromQuery] TSearchDto request, CancellationToken cancellationToken) =>
        Ok(await Service.SearchAsync(request, cancellationToken));

    /// <summary>Skracena lista za punjenje padajucih lista na klijentu.</summary>
    [HttpGet("lookup")]
    public async Task<ActionResult<List<LookupDto>>> Lookup(CancellationToken cancellationToken) =>
        Ok(await Service.GetLookupAsync(cancellationToken));

    [HttpGet("{id:int}")]
    public async Task<ActionResult<TDto>> GetById(int id, CancellationToken cancellationToken) =>
        Ok(await Service.GetByIdAsync(id, cancellationToken));

    [HttpPost]
    [Authorize(Roles = Roles.Admin)]
    public async Task<ActionResult<TDto>> Create([FromBody] TUpsertDto dto, CancellationToken cancellationToken)
    {
        var created = await Service.CreateAsync(dto, cancellationToken);
        return CreatedAtAction(nameof(GetById), new { id = GetId(created) }, created);
    }

    [HttpPut("{id:int}")]
    [Authorize(Roles = Roles.Admin)]
    public async Task<ActionResult<TDto>> Update(int id, [FromBody] TUpsertDto dto, CancellationToken cancellationToken) =>
        Ok(await Service.UpdateAsync(id, dto, cancellationToken));

    [HttpDelete("{id:int}")]
    [Authorize(Roles = Roles.Admin)]
    public async Task<IActionResult> Delete(int id, CancellationToken cancellationToken)
    {
        await Service.DeleteAsync(id, cancellationToken);
        return Ok(new { message = $"{EntityLabel} je uspjesno obrisan(a)." });
    }

    /// <summary>Cita identifikator iz kreiranog DTO-a za Location zaglavlje.</summary>
    private static int GetId(TDto dto) =>
        (int)(typeof(TDto).GetProperty("Id")?.GetValue(dto) ?? 0);
}
