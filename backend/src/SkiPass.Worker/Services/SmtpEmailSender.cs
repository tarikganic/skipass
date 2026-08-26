using MailKit.Net.Smtp;
using MailKit.Security;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;
using MimeKit;
using MimeKit.Text;
using SkiPass.Contracts;

namespace SkiPass.Worker.Services;

/// <summary>
/// Stvarno salje e-mail preko SMTP-a (MailKit). Ovo je razlog zasto SkiPass.Worker
/// postoji kao poseban servis: sporo/nepouzdano slanje e-maila se ne smije desavati
/// u toku HTTP zahtjeva ka glavnom API-ju.
/// </summary>
public class SmtpEmailSender : ISmtpEmailSender
{
    private readonly IConfiguration _configuration;
    private readonly ILogger<SmtpEmailSender> _logger;

    public SmtpEmailSender(IConfiguration configuration, ILogger<SmtpEmailSender> logger)
    {
        _configuration = configuration;
        _logger = logger;
    }

    public async Task SendAsync(EmailNotificationMessage message, CancellationToken cancellationToken = default)
    {
        var host = _configuration["Smtp:Host"];
        if (string.IsNullOrWhiteSpace(host))
        {
            throw new InvalidOperationException(
                "Smtp:Host nije konfigurisan (SMTP_HOST u .env). E-mail se ne moze poslati bez SMTP podataka.");
        }

        var port = int.TryParse(_configuration["Smtp:Port"], out var parsedPort) ? parsedPort : 587;
        var useSsl = !bool.TryParse(_configuration["Smtp:UseSsl"], out var parsedSsl) || parsedSsl;
        var username = _configuration["Smtp:Username"];
        var password = _configuration["Smtp:Password"];
        var fromEmail = _configuration["Smtp:FromEmail"] ?? "noreply@skipass.ba";
        var fromName = _configuration["Smtp:FromName"] ?? "SkiPass";

        var mimeMessage = new MimeMessage();
        mimeMessage.From.Add(new MailboxAddress(fromName, fromEmail));
        mimeMessage.To.Add(string.IsNullOrWhiteSpace(message.ToName)
            ? new MailboxAddress(message.To, message.To)
            : new MailboxAddress(message.ToName, message.To));
        mimeMessage.Subject = message.Subject;
        mimeMessage.Body = new TextPart(TextFormat.Plain) { Text = message.Body };

        using var client = new SmtpClient();

        var socketOptions = useSsl ? SecureSocketOptions.StartTlsWhenAvailable : SecureSocketOptions.None;
        await client.ConnectAsync(host, port, socketOptions, cancellationToken);

        if (!string.IsNullOrWhiteSpace(username))
        {
            await client.AuthenticateAsync(username, password, cancellationToken);
        }

        await client.SendAsync(mimeMessage, cancellationToken);
        await client.DisconnectAsync(true, cancellationToken);

        _logger.LogInformation("E-mail {MessageId} uspjesno poslan na {To}.", message.MessageId, message.To);
    }
}
