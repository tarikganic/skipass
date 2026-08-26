namespace SkiPass.Contracts;

/// <summary>Nazivi RabbitMQ redova, dijeljeni izmedju objavljivaoca (API) i konzumenta (Worker).</summary>
public static class RabbitMqQueueNames
{
    public const string EmailNotifications = "skipass.email-notifications";
}
