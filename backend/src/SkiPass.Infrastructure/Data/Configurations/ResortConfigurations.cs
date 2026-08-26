using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using SkiPass.Domain.Entities;

namespace SkiPass.Infrastructure.Data.Configurations;

public class UserConfiguration : IEntityTypeConfiguration<User>
{
    public void Configure(EntityTypeBuilder<User> builder)
    {
        builder.ToTable("Users");
        builder.Property(e => e.FirstName).HasMaxLength(100).IsRequired();
        builder.Property(e => e.LastName).HasMaxLength(100).IsRequired();
        builder.Property(e => e.Email).HasMaxLength(256).IsRequired();
        builder.Property(e => e.Phone).HasMaxLength(20);
        builder.Property(e => e.ProfileImageUrl).HasMaxLength(500);
        builder.Property(e => e.Role).HasConversion<string>().HasMaxLength(20).IsRequired();

        builder.HasIndex(e => e.Email).IsUnique().HasFilter("[IsDeleted] = 0");
        builder.HasIndex(e => e.IdentityUserId).IsUnique().HasFilter("[IdentityUserId] IS NOT NULL AND [IsDeleted] = 0");

        builder.HasOne(e => e.IdentityUser)
            .WithMany()
            .HasForeignKey(e => e.IdentityUserId)
            .OnDelete(DeleteBehavior.Restrict);

        builder.HasOne(e => e.City)
            .WithMany(c => c.Users)
            .HasForeignKey(e => e.CityId)
            .OnDelete(DeleteBehavior.Restrict);
    }
}

public class SkiResortConfiguration : IEntityTypeConfiguration<SkiResort>
{
    public void Configure(EntityTypeBuilder<SkiResort> builder)
    {
        builder.Property(e => e.Name).HasMaxLength(150).IsRequired();
        builder.Property(e => e.Description).HasMaxLength(2000).IsRequired();
        builder.Property(e => e.LogoUrl).HasMaxLength(500);
        builder.Property(e => e.ContactEmail).HasMaxLength(256);
        builder.Property(e => e.ContactPhone).HasMaxLength(20);
        builder.HasIndex(e => e.Name).IsUnique().HasFilter("[IsDeleted] = 0");

        builder.HasOne(e => e.City)
            .WithMany(c => c.SkiResorts)
            .HasForeignKey(e => e.CityId)
            .OnDelete(DeleteBehavior.Restrict);
    }
}

public class TrailConfiguration : IEntityTypeConfiguration<Trail>
{
    public void Configure(EntityTypeBuilder<Trail> builder)
    {
        builder.Property(e => e.Name).HasMaxLength(150).IsRequired();
        builder.Property(e => e.Code).HasMaxLength(20).IsRequired();
        builder.Property(e => e.Description).HasMaxLength(1500);
        builder.Property(e => e.ImageUrl).HasMaxLength(500);
        builder.Property(e => e.EstimatedCrowdLevel).HasConversion<string>().HasMaxLength(20).IsRequired();

        builder.HasIndex(e => new { e.SkiResortId, e.Code }).IsUnique().HasFilter("[IsDeleted] = 0");

        builder.HasOne(e => e.SkiResort)
            .WithMany(r => r.Trails)
            .HasForeignKey(e => e.SkiResortId)
            .OnDelete(DeleteBehavior.Restrict);

        builder.HasOne(e => e.TrailDifficulty)
            .WithMany(d => d.Trails)
            .HasForeignKey(e => e.TrailDifficultyId)
            .OnDelete(DeleteBehavior.Restrict);
    }
}

public class TrailConditionLogConfiguration : IEntityTypeConfiguration<TrailConditionLog>
{
    public void Configure(EntityTypeBuilder<TrailConditionLog> builder)
    {
        builder.Property(e => e.ConditionNote).HasMaxLength(500).IsRequired();
        builder.HasIndex(e => new { e.TrailId, e.RecordedAt });

        // Evidencija stanja pripada stazi, pa se brise zajedno sa njom.
        builder.HasOne(e => e.Trail)
            .WithMany(t => t.ConditionLogs)
            .HasForeignKey(e => e.TrailId)
            .OnDelete(DeleteBehavior.Cascade);

        builder.HasOne(e => e.RecordedByUser)
            .WithMany()
            .HasForeignKey(e => e.RecordedByUserId)
            .OnDelete(DeleteBehavior.Restrict);
    }
}

public class SkiLiftConfiguration : IEntityTypeConfiguration<SkiLift>
{
    public void Configure(EntityTypeBuilder<SkiLift> builder)
    {
        builder.Property(e => e.Name).HasMaxLength(150).IsRequired();
        builder.Property(e => e.Code).HasMaxLength(20).IsRequired();
        builder.Property(e => e.Description).HasMaxLength(1000);
        builder.HasIndex(e => new { e.SkiResortId, e.Code }).IsUnique().HasFilter("[IsDeleted] = 0");

        builder.HasOne(e => e.SkiResort)
            .WithMany(r => r.SkiLifts)
            .HasForeignKey(e => e.SkiResortId)
            .OnDelete(DeleteBehavior.Restrict);

        builder.HasOne(e => e.LiftType)
            .WithMany(t => t.SkiLifts)
            .HasForeignKey(e => e.LiftTypeId)
            .OnDelete(DeleteBehavior.Restrict);
    }
}

public class LiftMaintenanceRecordConfiguration : IEntityTypeConfiguration<LiftMaintenanceRecord>
{
    public void Configure(EntityTypeBuilder<LiftMaintenanceRecord> builder)
    {
        builder.Property(e => e.Description).HasMaxLength(1000).IsRequired();
        builder.Property(e => e.ResolutionNote).HasMaxLength(1000);
        builder.Property(e => e.Status).HasConversion<string>().HasMaxLength(20).IsRequired();
        builder.HasIndex(e => new { e.SkiLiftId, e.Status });

        builder.HasOne(e => e.SkiLift)
            .WithMany(l => l.MaintenanceRecords)
            .HasForeignKey(e => e.SkiLiftId)
            .OnDelete(DeleteBehavior.Cascade);

        builder.HasOne(e => e.ReportedByUser)
            .WithMany()
            .HasForeignKey(e => e.ReportedByUserId)
            .OnDelete(DeleteBehavior.Restrict);

        builder.HasOne(e => e.ResolvedByUser)
            .WithMany()
            .HasForeignKey(e => e.ResolvedByUserId)
            .OnDelete(DeleteBehavior.Restrict);
    }
}

public class WeatherLogConfiguration : IEntityTypeConfiguration<WeatherLog>
{
    public void Configure(EntityTypeBuilder<WeatherLog> builder)
    {
        builder.Property(e => e.Conditions).HasMaxLength(200).IsRequired();
        builder.HasIndex(e => new { e.SkiResortId, e.RecordedAt });

        builder.HasOne(e => e.SkiResort)
            .WithMany(r => r.WeatherLogs)
            .HasForeignKey(e => e.SkiResortId)
            .OnDelete(DeleteBehavior.Cascade);
    }
}
