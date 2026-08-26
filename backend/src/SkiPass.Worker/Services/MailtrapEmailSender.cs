using Mailtrap;
using Mailtrap.Emails.Requests;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;
using SkiPass.Contracts;

namespace SkiPass.Worker.Services;

/// <summary>
/// Stvarno salje e-mail preko Mailtrap Email API-ja (Mailtrap .NET SDK, ne SMTP). Ovo je
/// razlog zasto SkiPass.Worker postoji kao poseban servis: sporo/nepouzdano slanje e-maila
/// se ne smije desavati u toku HTTP zahtjeva ka glavnom API-ju.
/// </summary>
public class MailtrapEmailSender : IEmailSender
{
    private readonly IMailtrapClient _client;
    private readonly string _fromEmail;
    private readonly string _fromName;
    private readonly ILogger<MailtrapEmailSender> _logger;

    public MailtrapEmailSender(MailtrapClientFactory clientFactory, IConfiguration configuration, ILogger<MailtrapEmailSender> logger)
    {
        _client = clientFactory.CreateClient();
        _fromEmail = configuration["Mailtrap:FromEmail"] ?? "noreply@skipass.ba";
        _fromName = configuration["Mailtrap:FromName"] ?? "SkiPass";
        _logger = logger;
    }

    public async Task SendAsync(EmailNotificationMessage message, CancellationToken cancellationToken = default)
    {
        var request = SendEmailRequest
            .Create()
            .From(_fromEmail, _fromName)
            .To(message.To, message.ToName)
            .Subject(message.Subject)
            .Category(message.NotificationType)
            .Text(message.Body);

        await _client.Email().Send(request);

        _logger.LogInformation("E-mail {MessageId} uspjesno poslan na {To}.", message.MessageId, message.To);
    }
}
