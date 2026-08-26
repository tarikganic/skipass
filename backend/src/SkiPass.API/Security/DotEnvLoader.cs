namespace SkiPass.API.Security;

/// <summary>
/// Ucitava konfiguraciju iz .env datoteke i preslikava je u ASP.NET konfiguracijske kljuceve.
/// Sve tajne (konekcijski string, JWT kljuc, SMTP i slicno) drze se iskljucivo ovdje,
/// a ne u appsettings.json niti u izvornom kodu.
/// </summary>
public static class DotEnvLoader
{
    /// <summary>Mapiranje .env varijabli na konfiguracijske kljuceve aplikacije.</summary>
    private static readonly (string ConfigKey, string EnvKey)[] DerivedKeys =
    [
        ("Jwt__Key", "JWT_KEY"),
        ("Jwt__Issuer", "JWT_ISSUER"),
        ("Jwt__Audience", "JWT_AUDIENCE"),
        ("Jwt__ExpiryMinutes", "JWT_EXPIRY_MINUTES"),
        ("RabbitMQ__Host", "RABBITMQ_HOST"),
        ("RabbitMQ__Port", "RABBITMQ_PORT"),
        ("RabbitMQ__Username", "RABBITMQ_USER"),
        ("RabbitMQ__Password", "RABBITMQ_PASSWORD"),
        ("Smtp__Host", "SMTP_HOST"),
        ("Smtp__Port", "SMTP_PORT"),
        ("Smtp__Username", "SMTP_USERNAME"),
        ("Smtp__Password", "SMTP_PASSWORD"),
        ("Smtp__UseSsl", "SMTP_USE_SSL"),
        ("Smtp__FromEmail", "SMTP_FROM_EMAIL"),
        ("Smtp__FromName", "SMTP_FROM_NAME"),
        ("Stripe__SecretKey", "STRIPE_SECRET_KEY"),
        ("Stripe__PublishableKey", "STRIPE_PUBLISHABLE_KEY"),
        ("Stripe__WebhookSecret", "STRIPE_WEBHOOK_SECRET"),
        ("Seed__AdminPassword", "SEED_ADMIN_PASSWORD"),
        ("Seed__StaffPassword", "SEED_STAFF_PASSWORD"),
        ("Seed__SkierPassword", "SEED_SKIER_PASSWORD")
    ];

    public static void Load()
    {
        var envPath = FindDotEnv(Directory.GetCurrentDirectory()) ?? FindDotEnv(AppContext.BaseDirectory);

        if (envPath is not null && File.Exists(envPath))
        {
            foreach (var rawLine in File.ReadAllLines(envPath))
            {
                var line = rawLine.Trim();
                if (line.Length == 0 || line.StartsWith('#'))
                {
                    continue;
                }

                var separatorIndex = line.IndexOf('=');
                if (separatorIndex <= 0)
                {
                    continue;
                }

                var key = line[..separatorIndex].Trim();
                var value = line[(separatorIndex + 1)..].Trim().Trim('"');

                // Varijable postavljene u okruzenju (npr. docker-compose) imaju prednost nad .env datotekom.
                if (key.Length > 0 && Environment.GetEnvironmentVariable(key) is null)
                {
                    Environment.SetEnvironmentVariable(key, value);
                }
            }
        }

        ApplyDerivedConfiguration();
    }

    private static void ApplyDerivedConfiguration()
    {
        foreach (var (configKey, envKey) in DerivedKeys)
        {
            CopyIfMissing(configKey, envKey);
        }

        BuildConnectionString();
    }

    /// <summary>
    /// Konekcijski string se sastavlja na jednom mjestu iz pojedinacnih .env vrijednosti,
    /// kako se isti podaci ne bi ponavljali na vise lokacija.
    /// </summary>
    private static void BuildConnectionString()
    {
        if (!string.IsNullOrWhiteSpace(Environment.GetEnvironmentVariable("ConnectionStrings__DefaultConnection")))
        {
            return;
        }

        var host = Environment.GetEnvironmentVariable("DB_HOST") ?? "localhost,1433";
        var name = Environment.GetEnvironmentVariable("DB_NAME") ?? "210116";

        // Windows autentifikacija je predvidjena samo za lokalni razvoj sa instaliranim
        // SQL Serverom; u Docker okruzenju se uvijek koriste korisnicko ime i lozinka.
        var useTrustedConnection = string.Equals(
            Environment.GetEnvironmentVariable("DB_TRUSTED_CONNECTION"),
            "true",
            StringComparison.OrdinalIgnoreCase);

        string credentials;
        if (useTrustedConnection)
        {
            credentials = "Integrated Security=True";
        }
        else
        {
            var password = Environment.GetEnvironmentVariable("DB_PASSWORD");
            if (string.IsNullOrWhiteSpace(password))
            {
                return;
            }

            var user = Environment.GetEnvironmentVariable("DB_USER") ?? "sa";
            credentials = $"User Id={user};Password={password}";
        }

        Environment.SetEnvironmentVariable(
            "ConnectionStrings__DefaultConnection",
            $"Server={host};Database={name};{credentials};TrustServerCertificate=True;Encrypt=False;");
    }

    private static void CopyIfMissing(string configKey, string envKey)
    {
        if (!string.IsNullOrWhiteSpace(Environment.GetEnvironmentVariable(configKey)))
        {
            return;
        }

        var value = Environment.GetEnvironmentVariable(envKey);
        if (!string.IsNullOrWhiteSpace(value))
        {
            Environment.SetEnvironmentVariable(configKey, value);
        }
    }

    private static string? FindDotEnv(string startDirectory)
    {
        var directory = new DirectoryInfo(startDirectory);

        while (directory is not null)
        {
            var candidate = Path.Combine(directory.FullName, ".env");
            if (File.Exists(candidate))
            {
                return candidate;
            }

            directory = directory.Parent;
        }

        return null;
    }
}
