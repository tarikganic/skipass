using SkiPass.Contracts;

namespace SkiPass.Worker.Services;

public interface ISmtpEmailSender
{
    Task SendAsync(EmailNotificationMessage message, CancellationToken cancellationToken = default);
}
