namespace SkiPass.API.Contracts;

/// <summary>
/// Standardizovan oblik odgovora na greske. Klijentu se nikada ne izlazu
/// stack trace niti interni detalji implementacije.
/// </summary>
public class ApiErrorResponse
{
    public string Message { get; set; } = string.Empty;

    /// <summary>Greske po polju, koriste ih klijenti za prikaz poruka ispod kontrola.</summary>
    public Dictionary<string, string[]>? Errors { get; set; }

    /// <summary>Identifikator zahtjeva koji se moze povezati sa serverskim logom.</summary>
    public string? TraceId { get; set; }
}
