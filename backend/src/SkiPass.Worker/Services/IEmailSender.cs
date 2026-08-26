using SkiPass.Contracts;

namespace SkiPass.Worker.Services;

public interface IEmailSender
{
    Task SendAsync(EmailNotificationMessage message, CancellationToken cancellationToken = default);
}
