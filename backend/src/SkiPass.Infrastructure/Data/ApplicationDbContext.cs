using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Identity.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore;
using SkiPass.Contracts;
using SkiPass.Domain.Entities;
using SkiPass.Infrastructure.Messaging;

namespace SkiPass.Infrastructure.Data;

public class ApplicationDbContext : IdentityDbContext<ApplicationUser, IdentityRole<int>, int>
{
    private readonly IEmailQueuePublisher _emailQueuePublisher;

    public ApplicationDbContext(DbContextOptions<ApplicationDbContext> options, IEmailQueuePublisher emailQueuePublisher)
        : base(options)
    {
        _emailQueuePublisher = emailQueuePublisher;
    }

    // Referentne tabele
    public DbSet<Country> Countries => Set<Country>();
    public DbSet<City> Cities => Set<City>();
    public DbSet<TrailDifficulty> TrailDifficulties => Set<TrailDifficulty>();
    public DbSet<LiftType> LiftTypes => Set<LiftType>();
    public DbSet<IncidentType> IncidentTypes => Set<IncidentType>();
    public DbSet<BenefitCategory> BenefitCategories => Set<BenefitCategory>();
    public DbSet<AnnouncementCategory> AnnouncementCategories => Set<AnnouncementCategory>();
    public DbSet<PaymentMethod> PaymentMethods => Set<PaymentMethod>();

    // Glavne tabele
    public DbSet<User> UserProfiles => Set<User>();
    public DbSet<SkiResort> SkiResorts => Set<SkiResort>();
    public DbSet<Trail> Trails => Set<Trail>();
    public DbSet<TrailConditionLog> TrailConditionLogs => Set<TrailConditionLog>();
    public DbSet<SkiLift> SkiLifts => Set<SkiLift>();
    public DbSet<LiftMaintenanceRecord> LiftMaintenanceRecords => Set<LiftMaintenanceRecord>();
    public DbSet<TicketType> TicketTypes => Set<TicketType>();
    public DbSet<SkiPassOrder> SkiPassOrders => Set<SkiPassOrder>();
    public DbSet<SkiPassTicket> SkiPassTickets => Set<SkiPassTicket>();
    public DbSet<Payment> Payments => Set<Payment>();
    public DbSet<TicketValidation> TicketValidations => Set<TicketValidation>();
    public DbSet<Partner> Partners => Set<Partner>();
    public DbSet<Benefit> Benefits => Set<Benefit>();
    public DbSet<BenefitPurchase> BenefitPurchases => Set<BenefitPurchase>();
    public DbSet<BenefitView> BenefitViews => Set<BenefitView>();
    public DbSet<Incident> Incidents => Set<Incident>();
    public DbSet<Announcement> Announcements => Set<Announcement>();
    public DbSet<Notification> Notifications => Set<Notification>();
    public DbSet<Review> Reviews => Set<Review>();
    public DbSet<WeatherLog> WeatherLogs => Set<WeatherLog>();

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        base.OnModelCreating(modelBuilder);
        modelBuilder.ApplyConfigurationsFromAssembly(typeof(ApplicationDbContext).Assembly);
    }

    public override async Task<int> SaveChangesAsync(CancellationToken cancellationToken = default)
    {
        ApplyAuditTimestamps();

        // Zapisi se skupljaju prije snimanja (ChangeTracker se cisti nakon SaveChanges),
        // a e-mail se objavljuje tek nakon uspjesnog upisa - notifikacija koja nije
        // stvarno snimljena ne smije generisati e-mail.
        var newNotifications = ChangeTracker.Entries<Notification>()
            .Where(entry => entry.State == EntityState.Added)
            .Select(entry => entry.Entity)
            .ToList();

        var result = await base.SaveChangesAsync(cancellationToken);

        if (newNotifications.Count > 0)
        {
            await PublishEmailNotificationsAsync(newNotifications, cancellationToken);
        }

        return result;
    }

    /// <summary>
    /// Svaka nova sistemska notifikacija (upisana bilo gdje u servisnom sloju) automatski
    /// objavljuje odgovarajuci e-mail posao na RabbitMQ, umjesto da svaki servis to radi
    /// pojedinacno - jedna tacka integracije za citav sistem notifikacija.
    /// </summary>
    private async Task PublishEmailNotificationsAsync(List<Notification> notifications, CancellationToken cancellationToken)
    {
        var userIds = notifications.Select(n => n.UserId).Distinct().ToList();
        var recipients = await Set<Domain.Entities.User>()
            .Where(u => userIds.Contains(u.Id))
            .Select(u => new { u.Id, u.Email, u.FirstName })
            .ToDictionaryAsync(u => u.Id, cancellationToken);

        foreach (var notification in notifications)
        {
            if (!recipients.TryGetValue(notification.UserId, out var recipient) || string.IsNullOrWhiteSpace(recipient.Email))
            {
                continue;
            }

            await _emailQueuePublisher.PublishAsync(new EmailNotificationMessage
            {
                To = recipient.Email,
                ToName = recipient.FirstName,
                Subject = notification.Title,
                Body = notification.Message,
                NotificationType = notification.Type.ToString()
            }, cancellationToken);
        }
    }

    /// <summary>
    /// Sva audit vremena se biljeze u UTC-u kako bi zapisi bili konzistentni
    /// bez obzira na vremensku zonu hosta ili kontejnera.
    /// </summary>
    private void ApplyAuditTimestamps()
    {
        foreach (var entry in ChangeTracker.Entries<BaseEntity>())
        {
            switch (entry.State)
            {
                case EntityState.Added:
                    entry.Entity.CreatedAt = DateTime.UtcNow;
                    break;
                case EntityState.Modified:
                    entry.Entity.UpdatedAt = DateTime.UtcNow;
                    break;
            }
        }
    }
}
