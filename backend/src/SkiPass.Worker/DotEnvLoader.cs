namespace SkiPass.Worker;

/// <summary>
/// Ucitava RabbitMQ i SMTP vrijednosti iz .env datoteke u korijenu projekta, za lokalno
/// pokretanje bez Dockera. Mala, namjerno duplirana verzija SkiPass.API/Security/DotEnvLoader.cs
/// (samo kljucevi koje ovaj servis stvarno koristi) - radnik ne referencira API projekat.
/// U Docker okruzenju docker-compose vec postavlja iste varijable direktno u environment,
/// pa se ova datoteka tada preskace.
/// </summary>
public static class DotEnvLoader
{
    private static readonly (string ConfigKey, string EnvKey)[] DerivedKeys =
    [
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
        ("Smtp__FromName", "SMTP_FROM_NAME")
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

                if (key.Length > 0 && Environment.GetEnvironmentVariable(key) is null)
                {
                    Environment.SetEnvironmentVariable(key, value);
                }
            }
        }

        foreach (var (configKey, envKey) in DerivedKeys)
        {
            if (!string.IsNullOrWhiteSpace(Environment.GetEnvironmentVariable(configKey)))
            {
                continue;
            }

            var value = Environment.GetEnvironmentVariable(envKey);
            if (!string.IsNullOrWhiteSpace(value))
            {
                Environment.SetEnvironmentVariable(configKey, value);
            }
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
