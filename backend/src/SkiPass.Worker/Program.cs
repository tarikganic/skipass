using Mailtrap;
using SkiPass.Worker;
using SkiPass.Worker.Services;

DotEnvLoader.Load();

var builder = Host.CreateApplicationBuilder(args);

builder.Services.AddSingleton(sp =>
{
    var apiToken = sp.GetRequiredService<IConfiguration>()["Mailtrap:ApiToken"];
    if (string.IsNullOrWhiteSpace(apiToken))
    {
        throw new InvalidOperationException(
            "Mailtrap:ApiToken nije konfigurisan (MAILTRAP_API_TOKEN u .env). E-mail se ne moze poslati bez njega.");
    }

    return new MailtrapClientFactory(apiToken);
});
builder.Services.AddSingleton<IEmailSender, MailtrapEmailSender>();
builder.Services.AddHostedService<EmailConsumerService>();

var host = builder.Build();
host.Run();
