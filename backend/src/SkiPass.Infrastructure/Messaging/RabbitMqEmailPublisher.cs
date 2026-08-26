using System.Text;
using System.Text.Json;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;
using RabbitMQ.Client;
using SkiPass.Contracts;

namespace SkiPass.Infrastructure.Messaging;

/// <summary>
/// Objavljuje poruke na RabbitMQ. Drzi jednu (singleton) konekciju otvorenu za citav
/// zivotni vijek aplikacije i otvara po jedan kanal za svako objavljivanje - otvaranje
/// nove konekcije za svaku poruku je skupo i eksplicitno se izbjegava.
/// </summary>
public sealed class RabbitMqEmailPublisher : IEmailQueuePublisher, IDisposable
{
    private readonly ILogger<RabbitMqEmailPublisher> _logger;
    private readonly ConnectionFactory _connectionFactory;
    private readonly object _connectionLock = new();
    private IConnection? _connection;

    public RabbitMqEmailPublisher(IConfiguration configuration, ILogger<RabbitMqEmailPublisher> logger)
    {
        _logger = logger;
        _connectionFactory = new ConnectionFactory
        {
            HostName = configuration["RabbitMQ:Host"] ?? "localhost",
            Port = int.TryParse(configuration["RabbitMQ:Port"], out var port) ? port : 5672,
            UserName = configuration["RabbitMQ:Username"] ?? "guest",
            Password = configuration["RabbitMQ:Password"] ?? "guest",
            AutomaticRecoveryEnabled = true,
            NetworkRecoveryInterval = TimeSpan.FromSeconds(5)
        };
    }

    public Task PublishAsync(EmailNotificationMessage message, CancellationToken cancellationToken = default)
    {
        try
        {
            var connection = GetOrCreateConnection();
            using var channel = connection.CreateModel();

            channel.QueueDeclare(RabbitMqQueueNames.EmailNotifications, durable: true, exclusive: false, autoDelete: false);

            var body = Encoding.UTF8.GetBytes(JsonSerializer.Serialize(message));
            var properties = channel.CreateBasicProperties();
            properties.Persistent = true;
            properties.MessageId = message.MessageId.ToString();
            properties.ContentType = "application/json";

            channel.BasicPublish(exchange: string.Empty, routingKey: RabbitMqQueueNames.EmailNotifications, basicProperties: properties, body: body);

            _logger.LogInformation(
                "Poruka za e-mail {MessageId} ({NotificationType}) objavljena na red {Queue} za {To}.",
                message.MessageId, message.NotificationType, RabbitMqQueueNames.EmailNotifications, message.To);
        }
        catch (Exception ex)
        {
            // Slanje e-maila je sporedni efekat notifikacije - kvar RabbitMQ konekcije
            // ne smije srusiti glavnu poslovnu transakciju (npr. potvrdu placanja).
            // Greska se ipak eksplicitno loguje, nikad se ne guta bez traga.
            _logger.LogError(ex, "Objavljivanje poruke za e-mail {MessageId} nije uspjelo.", message.MessageId);
        }

        return Task.CompletedTask;
    }

    private IConnection GetOrCreateConnection()
    {
        if (_connection is { IsOpen: true })
        {
            return _connection;
        }

        lock (_connectionLock)
        {
            if (_connection is { IsOpen: true })
            {
                return _connection;
            }

            _connection?.Dispose();
            _connection = _connectionFactory.CreateConnection("SkiPass.API");
            return _connection;
        }
    }

    public void Dispose() => _connection?.Dispose();
}
