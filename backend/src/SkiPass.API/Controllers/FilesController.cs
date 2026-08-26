using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using SkiPass.API.Contracts;
using SkiPass.API.Security;
using SkiPass.Application.DTOs.Files;
using SkiPass.Application.Services.Interfaces;
using SkiPass.Domain.Constants;

namespace SkiPass.API.Controllers;

/// <summary>
/// Upload slika. Svaki upload zahtijeva autentifikaciju, a datoteke se snimaju
/// pod nasumicnim imenom kako se ne bi moglo pogoditi ime tudje datoteke.
/// </summary>
[ApiController]
[Route("api/[controller]")]
[Authorize]
[Produces("application/json")]
public class FilesController : ControllerBase
{
    /// <summary>Podfolderi u koje je dozvoljeno snimati; sprjecava prolaz kroz putanju.</summary>
    private static readonly Dictionary<string, string> AllowedCategories = new(StringComparer.OrdinalIgnoreCase)
    {
        ["profiles"] = "profiles",
        ["incidents"] = "incidents"
    };

    /// <summary>Kategorije u koje smiju pisati samo osoblje i administratori.</summary>
    private static readonly HashSet<string> StaffOnlyCategories = new(StringComparer.OrdinalIgnoreCase)
    {
        "trails",
        "benefits",
        "announcements",
        "resorts"
    };

    private readonly ICurrentUserService _currentUserService;
    private readonly IWebHostEnvironment _environment;
    private readonly ILogger<FilesController> _logger;

    public FilesController(
        ICurrentUserService currentUserService,
        IWebHostEnvironment environment,
        ILogger<FilesController> logger)
    {
        _currentUserService = currentUserService;
        _environment = environment;
        _logger = logger;
    }

    /// <summary>
    /// Prima sliku i vraca relativnu putanju koja se potom sprema uz odgovarajuci zapis.
    /// </summary>
    [HttpPost("images/{category}")]
    [RequestSizeLimit(ImageUploadValidator.MaxFileSizeBytes)]
    public async Task<ActionResult<UploadedFileDto>> UploadImage(
        string category,
        IFormFile file,
        CancellationToken cancellationToken)
    {
        var folder = ResolveFolder(category);
        if (folder is null)
        {
            return BadRequest(new ApiErrorResponse
            {
                Message = $"Nepoznata kategorija \"{category}\".",
                TraceId = HttpContext.TraceIdentifier
            });
        }

        var validationError = await ImageUploadValidator.ValidateAsync(file, cancellationToken);
        if (validationError is not null)
        {
            return BadRequest(new ApiErrorResponse
            {
                Message = "Molimo ispravite oznacena polja.",
                Errors = new Dictionary<string, string[]> { ["file"] = [validationError] },
                TraceId = HttpContext.TraceIdentifier
            });
        }

        var webRoot = _environment.WebRootPath ?? Path.Combine(_environment.ContentRootPath, "wwwroot");
        var targetDirectory = Path.Combine(webRoot, "uploads", folder);
        Directory.CreateDirectory(targetDirectory);

        var fileName = $"{Guid.NewGuid():N}{ImageUploadValidator.ResolveExtension(file)}";
        var fullPath = Path.Combine(targetDirectory, fileName);

        await using (var target = new FileStream(fullPath, FileMode.CreateNew))
        {
            await using var source = file.OpenReadStream();
            await source.CopyToAsync(target, cancellationToken);
        }

        var url = $"/uploads/{folder}/{fileName}";
        _logger.LogInformation(
            "Korisnik {UserId} je uploadovao sliku {Url} ({Size} bajta).",
            _currentUserService.GetRequiredUserId(), url, file.Length);

        return Ok(new UploadedFileDto
        {
            Url = url,
            FileName = fileName,
            SizeBytes = file.Length
        });
    }

    /// <summary>Mapira kategoriju na dozvoljeni podfolder, uz provjeru role gdje je potrebno.</summary>
    private string? ResolveFolder(string category)
    {
        if (AllowedCategories.TryGetValue(category, out var folder))
        {
            return folder;
        }

        if (StaffOnlyCategories.Contains(category) && _currentUserService.IsStaffOrAdmin)
        {
            return category.ToLowerInvariant();
        }

        return null;
    }
}
