using System.Text;
using System.Text.Json;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.Logging;
using RabbitMQ.Client;
using RabbitMQ.Client.Events;
using SkiPass.Contracts;
using SkiPass.Worker.Services;

namespace SkiPass.Worker;

/// <summary>
/// Konzumira red "skipass.email-notifications" i stvarno salje e-mail preko SMTP-a.
/// Ovo je stvarno odvojen mikroservis: sopstveni proces, sopstveni Dockerfile,
/// sopstveni unos u docker-compose.yml - ne IHostedService unutar API projekta.
/// </summary>
public class EmailConsumerService : BackgroundService
{
    /// <summary>Eksponencijalni backoff izmedju pokusaja slanja jedne poruke: 1s, 2s, 4s, 8s.</summary>
    private static readonly TimeSpan[] RetryDelays =
    [
        TimeSpan.FromSeconds(1),
        TimeSpan.FromSeconds(2),
        TimeSpan.FromSeconds(4),
        TimeSpan.FromSeconds(8)
    ];

    private readonly IConfiguration _configuration;
    private readonly ISmtpEmailSender _emailSender;
    private readonly ILogger<EmailConsumerService> _logger;

    public EmailConsumerService(IConfiguration configuration, ISmtpEmailSender emailSender, ILogger<EmailConsumerService> logger)
    {
        _configuration = configuration;
        _emailSender = emailSender;
        _logger = logger;
    }

    protected override async Task ExecuteAsync(CancellationToken stoppingToken)
    {
        var connectionFactory = new ConnectionFactory
        {
            HostName = _configuration["RabbitMQ:Host"] ?? "localhost",
            Port = int.TryParse(_configuration["RabbitMQ:Port"], out var port) ? port : 5672,
            UserName = _configuration["RabbitMQ:Username"] ?? "guest",
            Password = _configuration["RabbitMQ:Password"] ?? "guest",
            DispatchConsumersAsync = true
        };

        // Radnik se moze pokrenuti prije nego sto je RabbitMQ zaista spreman da prima
        // konekcije (docker-compose healthcheck ublazava ovo, ali ne garantuje potpuno) -
        // pa se konekcija ponavlja sa istim backoff-om kao i slanje pojedinacne poruke.
        while (!stoppingToken.IsCancellationRequested)
        {
            try
            {
                using var connection = connectionFactory.CreateConnection("SkiPass.Worker");
                using var channel = connection.CreateModel();

                channel.QueueDeclare(RabbitMqQueueNames.EmailNotifications, durable: true, exclusive: false, autoDelete: false);
                channel.BasicQos(prefetchSize: 0, prefetchCount: 5, global: false);

                var consumer = new AsyncEventingBasicConsumer(channel);
                consumer.Received += async (_, args) => await HandleMessageAsync(channel, args, stoppingToken);

                channel.BasicConsume(RabbitMqQueueNames.EmailNotifications, autoAck: false, consumer);

                _logger.LogInformation("SkiPass.Worker povezan na RabbitMQ, slusa red {Queue}.", RabbitMqQueueNames.EmailNotifications);

                // Kanal ostaje otvoren dok se servis ne zaustavi ili konekcija ne padne.
                while (connection.IsOpen && !stoppingToken.IsCancellationRequested)
                {
                    await Task.Delay(TimeSpan.FromSeconds(5), stoppingToken);
                }
            }
            catch (OperationCanceledException) when (stoppingToken.IsCancellationRequested)
            {
                break;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Konekcija na RabbitMQ je prekinuta ili nije uspostavljena. Pokusaj ponovo za 5 sekundi.");
                await Task.Delay(TimeSpan.FromSeconds(5), stoppingToken);
            }
        }
    }

    private async Task HandleMessageAsync(IModel channel, BasicDeliverEventArgs args, CancellationToken stoppingToken)
    {
        EmailNotificationMessage? message;
        try
        {
            var json = Encoding.UTF8.GetString(args.Body.ToArray());
            message = JsonSerializer.Deserialize<EmailNotificationMessage>(json);
        }
        catch (JsonException ex)
        {
            // Poruka je nepopravljivo losa (nije nas ugovor) - nema smisla je vracati u red
            // beskonacno; loguje se kao greska i potvrdjuje da se ne ponavlja zauvijek.
            _logger.LogError(ex, "Poruka na redu {Queue} se ne moze parsirati - odbacena.", RabbitMqQueueNames.EmailNotifications);
            channel.BasicAck(args.DeliveryTag, multiple: false);
            return;
        }

        if (message is null)
        {
            channel.BasicAck(args.DeliveryTag, multiple: false);
            return;
        }

        for (var attempt = 0; ; attempt++)
        {
            try
            {
                await _emailSender.SendAsync(message, stoppingToken);
                channel.BasicAck(args.DeliveryTag, multiple: false);
                return;
            }
            catch (Exception ex) when (attempt < RetryDelays.Length)
            {
                var delay = RetryDelays[attempt];
                _logger.LogWarning(
                    ex,
                    "Slanje e-maila {MessageId} nije uspjelo (pokusaj {Attempt}/{Max}). Ponovni pokusaj za {Delay}.",
                    message.MessageId, attempt + 1, RetryDelays.Length + 1, delay);
                await Task.Delay(delay, stoppingToken);
            }
            catch (Exception ex)
            {
                // Svi pokusaji su iscrpljeni - greska se eksplicitno loguje (nikad tiho gutanje),
                // a poruka se potvrdjuje da se izbjegne beskonacna petlja ponavljanja za istu poruku.
                _logger.LogError(
                    ex,
                    "Slanje e-maila {MessageId} nije uspjelo nakon {Attempts} pokusaja. Poruka se odbacuje.",
                    message.MessageId, RetryDelays.Length + 1);
                channel.BasicAck(args.DeliveryTag, multiple: false);
                return;
            }
        }
    }
}
