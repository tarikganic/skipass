using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using SkiPass.Domain.Entities;

namespace SkiPass.Infrastructure.Data.Configurations;

public class PartnerConfiguration : IEntityTypeConfiguration<Partner>
{
    public void Configure(EntityTypeBuilder<Partner> builder)
    {
        builder.Property(e => e.Name).HasMaxLength(150).IsRequired();
        builder.Property(e => e.Description).HasMaxLength(2000);
        builder.Property(e => e.ContactEmail).HasMaxLength(256);
        builder.Property(e => e.ContactPhone).HasMaxLength(20);
        builder.Property(e => e.Website).HasMaxLength(500);
        builder.Property(e => e.LogoUrl).HasMaxLength(500);
        builder.Property(e => e.Address).HasMaxLength(300);
        builder.HasIndex(e => e.Name).IsUnique().HasFilter("[IsDeleted] = 0");

        builder.HasOne(e => e.City)
            .WithMany(c => c.Partners)
            .HasForeignKey(e => e.CityId)
            .OnDelete(DeleteBehavior.Restrict);
    }
}

public class BenefitConfiguration : IEntityTypeConfiguration<Benefit>
{
    public void Configure(EntityTypeBuilder<Benefit> builder)
    {
        builder.Property(e => e.Name).HasMaxLength(150).IsRequired();
        builder.Property(e => e.Description).HasMaxLength(2000).IsRequired();
        builder.Property(e => e.ImageUrl).HasMaxLength(500);
        builder.Property(e => e.Brand).HasMaxLength(100);
        builder.Property(e => e.Price).HasPrecision(18, 2);
        builder.Property(e => e.DiscountPercentage).HasPrecision(5, 2);
        builder.HasIndex(e => new { e.SkiResortId, e.Name }).IsUnique().HasFilter("[IsDeleted] = 0");

        builder.HasOne(e => e.BenefitCategory)
            .WithMany(c => c.Benefits)
            .HasForeignKey(e => e.BenefitCategoryId)
            .OnDelete(DeleteBehavior.Restrict);

        builder.HasOne(e => e.SkiResort)
            .WithMany(r => r.Benefits)
            .HasForeignKey(e => e.SkiResortId)
            .OnDelete(DeleteBehavior.Restrict);

        builder.HasOne(e => e.Partner)
            .WithMany(p => p.Benefits)
            .HasForeignKey(e => e.PartnerId)
            .OnDelete(DeleteBehavior.Restrict);
    }
}

public class BenefitPurchaseConfiguration : IEntityTypeConfiguration<BenefitPurchase>
{
    public void Configure(EntityTypeBuilder<BenefitPurchase> builder)
    {
        builder.Property(e => e.TotalPrice).HasPrecision(18, 2);
        builder.Property(e => e.Status).HasConversion<string>().HasMaxLength(20).IsRequired();
        builder.Property(e => e.CancellationReason).HasMaxLength(500);
        builder.HasIndex(e => new { e.UserId, e.PurchasedAt });

        builder.HasOne(e => e.User)
            .WithMany(u => u.BenefitPurchases)
            .HasForeignKey(e => e.UserId)
            .OnDelete(DeleteBehavior.Restrict);

        builder.HasOne(e => e.Benefit)
            .WithMany(b => b.Purchases)
            .HasForeignKey(e => e.BenefitId)
            .OnDelete(DeleteBehavior.Restrict);
    }
}

public class BenefitViewConfiguration : IEntityTypeConfiguration<BenefitView>
{
    public void Configure(EntityTypeBuilder<BenefitView> builder)
    {
        builder.HasIndex(e => new { e.UserId, e.ViewedAt });

        builder.HasOne(e => e.User)
            .WithMany(u => u.BenefitViews)
            .HasForeignKey(e => e.UserId)
            .OnDelete(DeleteBehavior.Cascade);

        builder.HasOne(e => e.Benefit)
            .WithMany(b => b.Views)
            .HasForeignKey(e => e.BenefitId)
            .OnDelete(DeleteBehavior.Restrict);
    }
}

public class IncidentConfiguration : IEntityTypeConfiguration<Incident>
{
    public void Configure(EntityTypeBuilder<Incident> builder)
    {
        builder.Property(e => e.Description).HasMaxLength(2000).IsRequired();
        builder.Property(e => e.ImageUrl).HasMaxLength(500);
        builder.Property(e => e.ResolutionNote).HasMaxLength(1000);
        builder.Property(e => e.Status).HasConversion<string>().HasMaxLength(20).IsRequired();
        builder.HasIndex(e => new { e.Status, e.ReportedAt });

        builder.HasOne(e => e.ReportedByUser)
            .WithMany(u => u.ReportedIncidents)
            .HasForeignKey(e => e.ReportedByUserId)
            .OnDelete(DeleteBehavior.Restrict);

        builder.HasOne(e => e.HandledByUser)
            .WithMany()
            .HasForeignKey(e => e.HandledByUserId)
            .OnDelete(DeleteBehavior.Restrict);

        builder.HasOne(e => e.IncidentType)
            .WithMany(t => t.Incidents)
            .HasForeignKey(e => e.IncidentTypeId)
            .OnDelete(DeleteBehavior.Restrict);

        builder.HasOne(e => e.Trail)
            .WithMany(t => t.Incidents)
            .HasForeignKey(e => e.TrailId)
            .OnDelete(DeleteBehavior.Restrict);

        builder.HasOne(e => e.SkiLift)
            .WithMany(l => l.Incidents)
            .HasForeignKey(e => e.SkiLiftId)
            .OnDelete(DeleteBehavior.Restrict);
    }
}

public class AnnouncementConfiguration : IEntityTypeConfiguration<Announcement>
{
    public void Configure(EntityTypeBuilder<Announcement> builder)
    {
        builder.Property(e => e.Title).HasMaxLength(200).IsRequired();
        builder.Property(e => e.Content).HasMaxLength(5000).IsRequired();
        builder.Property(e => e.ImageUrl).HasMaxLength(500);
        builder.HasIndex(e => new { e.SkiResortId, e.PublishedAt });

        builder.HasOne(e => e.AnnouncementCategory)
            .WithMany(c => c.Announcements)
            .HasForeignKey(e => e.AnnouncementCategoryId)
            .OnDelete(DeleteBehavior.Restrict);

        builder.HasOne(e => e.SkiResort)
            .WithMany(r => r.Announcements)
            .HasForeignKey(e => e.SkiResortId)
            .OnDelete(DeleteBehavior.Restrict);

        builder.HasOne(e => e.CreatedByUser)
            .WithMany()
            .HasForeignKey(e => e.CreatedByUserId)
            .OnDelete(DeleteBehavior.Restrict);
    }
}

public class NotificationConfiguration : IEntityTypeConfiguration<Notification>
{
    public void Configure(EntityTypeBuilder<Notification> builder)
    {
        builder.Property(e => e.Title).HasMaxLength(200).IsRequired();
        builder.Property(e => e.Message).HasMaxLength(1000).IsRequired();
        builder.Property(e => e.Type).HasConversion<string>().HasMaxLength(40).IsRequired();
        builder.Property(e => e.TargetRoute).HasMaxLength(200);
        builder.HasIndex(e => new { e.UserId, e.IsRead });

        builder.HasOne(e => e.User)
            .WithMany(u => u.Notifications)
            .HasForeignKey(e => e.UserId)
            .OnDelete(DeleteBehavior.Cascade);
    }
}

public class ReviewConfiguration : IEntityTypeConfiguration<Review>
{
    public void Configure(EntityTypeBuilder<Review> builder)
    {
        builder.Property(e => e.Comment).HasMaxLength(1000);
        builder.Property(e => e.TargetType).HasConversion<string>().HasMaxLength(20).IsRequired();

        // Jedan korisnik moze ostaviti samo jednu ocjenu po stavci.
        builder.HasIndex(e => new { e.UserId, e.TrailId }).IsUnique().HasFilter("[TrailId] IS NOT NULL AND [IsDeleted] = 0");
        builder.HasIndex(e => new { e.UserId, e.BenefitId }).IsUnique().HasFilter("[BenefitId] IS NOT NULL AND [IsDeleted] = 0");
        builder.HasIndex(e => new { e.UserId, e.SkiResortId }).IsUnique().HasFilter("[SkiResortId] IS NOT NULL AND [IsDeleted] = 0");

        builder.HasOne(e => e.User)
            .WithMany(u => u.Reviews)
            .HasForeignKey(e => e.UserId)
            .OnDelete(DeleteBehavior.Restrict);

        builder.HasOne(e => e.Trail)
            .WithMany(t => t.Reviews)
            .HasForeignKey(e => e.TrailId)
            .OnDelete(DeleteBehavior.Restrict);

        builder.HasOne(e => e.Benefit)
            .WithMany(b => b.Reviews)
            .HasForeignKey(e => e.BenefitId)
            .OnDelete(DeleteBehavior.Restrict);

        builder.HasOne(e => e.SkiResort)
            .WithMany()
            .HasForeignKey(e => e.SkiResortId)
            .OnDelete(DeleteBehavior.Restrict);
    }
}
