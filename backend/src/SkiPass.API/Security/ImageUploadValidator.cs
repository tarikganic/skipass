namespace SkiPass.API.Security;

/// <summary>
/// Provjerava prilozene slike prije snimanja na disk. Osim ekstenzije i MIME tipa,
/// provjeravaju se i magic bytes, jer se ekstenzija i zaglavlje lako mogu falsifikovati.
/// </summary>
public static class ImageUploadValidator
{
    public const long MaxFileSizeBytes = 5 * 1024 * 1024;

    private static readonly string[] AllowedExtensions = [".jpg", ".jpeg", ".png", ".webp"];
    private static readonly string[] AllowedMimeTypes = ["image/jpeg", "image/png", "image/webp"];

    /// <summary>Vraca poruku o gresci ili null ako je datoteka prihvatljiva.</summary>
    public static async Task<string?> ValidateAsync(IFormFile? file, CancellationToken cancellationToken = default)
    {
        if (file is null || file.Length == 0)
        {
            return "Datoteka nije prilozena.";
        }

        if (file.Length > MaxFileSizeBytes)
        {
            return $"Slika ne smije biti veca od {MaxFileSizeBytes / (1024 * 1024)} MB.";
        }

        var extension = Path.GetExtension(file.FileName).ToLowerInvariant();
        if (!AllowedExtensions.Contains(extension))
        {
            return $"Dozvoljeni formati su: {string.Join(", ", AllowedExtensions.Select(e => e.TrimStart('.')))}.";
        }

        if (!IsAllowedMimeType(file.ContentType))
        {
            return "Tip sadrzaja datoteke ne odgovara dozvoljenim formatima slike.";
        }

        if (!await HasMatchingSignatureAsync(file, extension, cancellationToken))
        {
            return "Sadrzaj datoteke ne odgovara formatu koji ekstenzija navodi.";
        }

        return null;
    }

    public static string ResolveExtension(IFormFile file) => Path.GetExtension(file.FileName).ToLowerInvariant();

    private static bool IsAllowedMimeType(string? contentType)
    {
        if (string.IsNullOrWhiteSpace(contentType))
        {
            return false;
        }

        // Neki klijenti salju genericki tip; u tom slucaju se oslanjamo na magic bytes.
        if (contentType.Equals("application/octet-stream", StringComparison.OrdinalIgnoreCase))
        {
            return true;
        }

        return AllowedMimeTypes.Contains(contentType.ToLowerInvariant());
    }

    private static async Task<bool> HasMatchingSignatureAsync(IFormFile file, string extension, CancellationToken cancellationToken)
    {
        var header = new byte[12];

        await using var stream = file.OpenReadStream();
        var read = await stream.ReadAsync(header, cancellationToken);

        if (read < 4)
        {
            return false;
        }

        return extension switch
        {
            ".jpg" or ".jpeg" => header[0] == 0xFF && header[1] == 0xD8 && header[2] == 0xFF,

            ".png" => read >= 8
                      && header[0] == 0x89 && header[1] == 0x50 && header[2] == 0x4E && header[3] == 0x47
                      && header[4] == 0x0D && header[5] == 0x0A && header[6] == 0x1A && header[7] == 0x0A,

            ".webp" => read >= 12
                       && header[0] == 0x52 && header[1] == 0x49 && header[2] == 0x46 && header[3] == 0x46
                       && header[8] == 0x57 && header[9] == 0x45 && header[10] == 0x42 && header[11] == 0x50,

            _ => false
        };
    }
}
