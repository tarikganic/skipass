namespace SkiPass.API.Security;

/// <summary>
/// Provjerava da su sve obavezne konfiguracijske vrijednosti dostupne prije pokretanja,
/// kako aplikacija ne bi pukla tek pri prvom zahtjevu.
/// </summary>
public static class ConfigurationValidator
{
    private const int MinimumJwtKeyLength = 32;

    public static void Validate(IConfiguration configuration)
    {
        var missing = new List<string>();

        if (string.IsNullOrWhiteSpace(configuration.GetConnectionString("DefaultConnection")))
        {
            missing.Add("ConnectionStrings:DefaultConnection (DB_HOST, DB_NAME, DB_USER, DB_PASSWORD)");
        }

        foreach (var key in new[] { "Jwt:Key", "Jwt:Issuer", "Jwt:Audience", "Stripe:SecretKey", "Stripe:WebhookSecret" })
        {
            if (string.IsNullOrWhiteSpace(configuration[key]))
            {
                missing.Add(key);
            }
        }

        if (missing.Count > 0)
        {
            throw new InvalidOperationException(
                $"Nedostaju obavezne konfiguracijske vrijednosti: {string.Join(", ", missing)}. " +
                "Provjerite .env datoteku u korijenu projekta.");
        }

        var jwtKey = configuration["Jwt:Key"]!;
        if (jwtKey.Length < MinimumJwtKeyLength)
        {
            throw new InvalidOperationException(
                $"Jwt:Key mora imati najmanje {MinimumJwtKeyLength} znakova radi sigurnosti potpisa tokena.");
        }
    }
}
