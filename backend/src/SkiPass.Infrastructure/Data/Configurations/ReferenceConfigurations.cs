using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using SkiPass.Domain.Entities;

namespace SkiPass.Infrastructure.Data.Configurations;

public class CountryConfiguration : IEntityTypeConfiguration<Country>
{
    public void Configure(EntityTypeBuilder<Country> builder)
    {
        builder.Property(e => e.Name).HasMaxLength(100).IsRequired();
        builder.Property(e => e.IsoCode).HasMaxLength(3).IsRequired();
        builder.HasIndex(e => e.Name).IsUnique().HasFilter("[IsDeleted] = 0");
        builder.HasIndex(e => e.IsoCode).IsUnique().HasFilter("[IsDeleted] = 0");
    }
}

public class CityConfiguration : IEntityTypeConfiguration<City>
{
    public void Configure(EntityTypeBuilder<City> builder)
    {
        builder.Property(e => e.Name).HasMaxLength(100).IsRequired();
        builder.Property(e => e.PostalCode).HasMaxLength(10);
        builder.HasIndex(e => new { e.CountryId, e.Name }).IsUnique().HasFilter("[IsDeleted] = 0");

        builder.HasOne(e => e.Country)
            .WithMany(c => c.Cities)
            .HasForeignKey(e => e.CountryId)
            .OnDelete(DeleteBehavior.Restrict);
    }
}

public class TrailDifficultyConfiguration : IEntityTypeConfiguration<TrailDifficulty>
{
    public void Configure(EntityTypeBuilder<TrailDifficulty> builder)
    {
        builder.Property(e => e.Name).HasMaxLength(50).IsRequired();
        builder.Property(e => e.Description).HasMaxLength(300);
        builder.Property(e => e.ColorHex).HasMaxLength(7).IsRequired();
        builder.HasIndex(e => e.Name).IsUnique().HasFilter("[IsDeleted] = 0");
    }
}

public class LiftTypeConfiguration : IEntityTypeConfiguration<LiftType>
{
    public void Configure(EntityTypeBuilder<LiftType> builder)
    {
        builder.Property(e => e.Name).HasMaxLength(80).IsRequired();
        builder.Property(e => e.Description).HasMaxLength(300);
        builder.HasIndex(e => e.Name).IsUnique().HasFilter("[IsDeleted] = 0");
    }
}

public class IncidentTypeConfiguration : IEntityTypeConfiguration<IncidentType>
{
    public void Configure(EntityTypeBuilder<IncidentType> builder)
    {
        builder.Property(e => e.Name).HasMaxLength(100).IsRequired();
        builder.Property(e => e.Description).HasMaxLength(300);
        builder.HasIndex(e => e.Name).IsUnique().HasFilter("[IsDeleted] = 0");
    }
}

public class BenefitCategoryConfiguration : IEntityTypeConfiguration<BenefitCategory>
{
    public void Configure(EntityTypeBuilder<BenefitCategory> builder)
    {
        builder.Property(e => e.Name).HasMaxLength(100).IsRequired();
        builder.Property(e => e.Description).HasMaxLength(300);
        builder.Property(e => e.IconName).HasMaxLength(50);
        builder.HasIndex(e => e.Name).IsUnique().HasFilter("[IsDeleted] = 0");
    }
}

public class AnnouncementCategoryConfiguration : IEntityTypeConfiguration<AnnouncementCategory>
{
    public void Configure(EntityTypeBuilder<AnnouncementCategory> builder)
    {
        builder.Property(e => e.Name).HasMaxLength(100).IsRequired();
        builder.Property(e => e.Description).HasMaxLength(300);
        builder.HasIndex(e => e.Name).IsUnique().HasFilter("[IsDeleted] = 0");
    }
}

public class PaymentMethodConfiguration : IEntityTypeConfiguration<PaymentMethod>
{
    public void Configure(EntityTypeBuilder<PaymentMethod> builder)
    {
        builder.Property(e => e.Name).HasMaxLength(80).IsRequired();
        builder.Property(e => e.Code).HasMaxLength(30).IsRequired();
        builder.HasIndex(e => e.Code).IsUnique().HasFilter("[IsDeleted] = 0");
    }
}
