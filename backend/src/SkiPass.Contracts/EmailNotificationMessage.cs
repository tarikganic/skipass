namespace SkiPass.Contracts;

/// <summary>
/// Poruka na RabbitMQ redu "skipass.email-notifications". SkiPass.API je objavljuje
/// (Infrastructure/Messaging/RabbitMqEmailPublisher), a SkiPass.Worker je konzumira i
/// stvarno salje e-mail (Services/SmtpEmailSender). Namjerno je jedina zavisnost koju
/// SkiPass.Worker ima prema ostatku rjesenja - drzi radnik kao stvarno odvojen servis,
/// umjesto da referencira citav web projekat.
/// </summary>
public class EmailNotificationMessage
{
    public Guid MessageId { get; set; } = Guid.NewGuid();
    public string To { get; set; } = string.Empty;
    public string? ToName { get; set; }
    public string Subject { get; set; } = string.Empty;
    public string Body { get; set; } = string.Empty;

    /// <summary>Naziv NotificationType vrijednosti sa API strane, radi logiranja/dijagnostike.</summary>
    public string NotificationType { get; set; } = string.Empty;

    public DateTime CreatedAtUtc { get; set; } = DateTime.UtcNow;
}
