using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using SkiPass.Application.Common;
using SkiPass.Application.DTOs.Users;
using SkiPass.Application.Services.Interfaces;
using SkiPass.Domain.Constants;

namespace SkiPass.API.Controllers;

[ApiController]
[Route("api/[controller]")]
[Authorize(Roles = Roles.Admin)]
[Produces("application/json")]
public class UsersController : ControllerBase
{
    private readonly IUserService _userService;

    public UsersController(IUserService userService)
    {
        _userService = userService;
    }

    [HttpGet]
    public async Task<ActionResult<PagedResult<UserDto>>> Search([FromQuery] UserSearchDto request, CancellationToken cancellationToken) =>
        Ok(await _userService.SearchAsync(request, cancellationToken));

    [HttpGet("{id:int}")]
    public async Task<ActionResult<UserDto>> GetById(int id, CancellationToken cancellationToken) =>
        Ok(await _userService.GetByIdAsync(id, cancellationToken));

    [HttpPost]
    public async Task<ActionResult<UserDto>> Create([FromBody] UserCreateDto dto, CancellationToken cancellationToken)
    {
        var created = await _userService.CreateAsync(dto, cancellationToken);
        return CreatedAtAction(nameof(GetById), new { id = created.Id }, created);
    }

    [HttpPut("{id:int}")]
    public async Task<ActionResult<UserDto>> Update(int id, [FromBody] UserUpdateDto dto, CancellationToken cancellationToken) =>
        Ok(await _userService.UpdateAsync(id, dto, cancellationToken));

    [HttpDelete("{id:int}")]
    public async Task<IActionResult> Delete(int id, CancellationToken cancellationToken)
    {
        await _userService.DeleteAsync(id, cancellationToken);
        return Ok(new { message = "Korisnik je uspjesno obrisan." });
    }
}
