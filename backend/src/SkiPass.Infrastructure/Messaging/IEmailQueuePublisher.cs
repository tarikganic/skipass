using SkiPass.Contracts;

namespace SkiPass.Infrastructure.Messaging;

/// <summary>Objavljuje poruke za slanje e-maila na RabbitMQ, koje SkiPass.Worker konzumira.</summary>
public interface IEmailQueuePublisher
{
    Task PublishAsync(EmailNotificationMessage message, CancellationToken cancellationToken = default);
}
