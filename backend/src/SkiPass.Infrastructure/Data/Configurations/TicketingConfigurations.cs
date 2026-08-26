using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using SkiPass.Domain.Entities;

namespace SkiPass.Infrastructure.Data.Configurations;

public class TicketTypeConfiguration : IEntityTypeConfiguration<TicketType>
{
    public void Configure(EntityTypeBuilder<TicketType> builder)
    {
        builder.Property(e => e.Name).HasMaxLength(120).IsRequired();
        builder.Property(e => e.Description).HasMaxLength(1000);
        builder.Property(e => e.PricePerDay).HasPrecision(18, 2);
        builder.Property(e => e.DiscountPercentage).HasPrecision(5, 2);
        builder.HasIndex(e => new { e.SkiResortId, e.Name }).IsUnique().HasFilter("[IsDeleted] = 0");

        builder.HasOne(e => e.SkiResort)
            .WithMany(r => r.TicketTypes)
            .HasForeignKey(e => e.SkiResortId)
            .OnDelete(DeleteBehavior.Restrict);
    }
}

public class SkiPassOrderConfiguration : IEntityTypeConfiguration<SkiPassOrder>
{
    public void Configure(EntityTypeBuilder<SkiPassOrder> builder)
    {
        builder.Property(e => e.OrderNumber).HasMaxLength(30).IsRequired();
        builder.Property(e => e.TotalAmount).HasPrecision(18, 2);
        builder.Property(e => e.Status).HasConversion<string>().HasMaxLength(20).IsRequired();
        builder.Property(e => e.Note).HasMaxLength(500);
        builder.Property(e => e.CancellationReason).HasMaxLength(500);

        builder.HasIndex(e => e.OrderNumber).IsUnique();
        builder.HasIndex(e => new { e.UserId, e.OrderDate });

        builder.HasOne(e => e.User)
            .WithMany(u => u.Orders)
            .HasForeignKey(e => e.UserId)
            .OnDelete(DeleteBehavior.Restrict);

        builder.HasOne(e => e.PaymentMethod)
            .WithMany(p => p.Orders)
            .HasForeignKey(e => e.PaymentMethodId)
            .OnDelete(DeleteBehavior.Restrict);

        builder.HasOne(e => e.StatusChangedByUser)
            .WithMany()
            .HasForeignKey(e => e.StatusChangedByUserId)
            .OnDelete(DeleteBehavior.Restrict);
    }
}

public class SkiPassTicketConfiguration : IEntityTypeConfiguration<SkiPassTicket>
{
    public void Configure(EntityTypeBuilder<SkiPassTicket> builder)
    {
        builder.Property(e => e.QrCode).HasMaxLength(64).IsRequired();
        builder.Property(e => e.HolderFirstName).HasMaxLength(100).IsRequired();
        builder.Property(e => e.HolderLastName).HasMaxLength(100).IsRequired();
        builder.Property(e => e.Price).HasPrecision(18, 2);
        builder.Property(e => e.Status).HasConversion<string>().HasMaxLength(20).IsRequired();

        builder.HasIndex(e => e.QrCode).IsUnique();
        builder.HasIndex(e => new { e.ValidFrom, e.ValidTo });

        // Karte su sastavni dio narudzbe i brisu se zajedno sa njom.
        builder.HasOne(e => e.SkiPassOrder)
            .WithMany(o => o.Tickets)
            .HasForeignKey(e => e.SkiPassOrderId)
            .OnDelete(DeleteBehavior.Cascade);

        builder.HasOne(e => e.TicketType)
            .WithMany(t => t.Tickets)
            .HasForeignKey(e => e.TicketTypeId)
            .OnDelete(DeleteBehavior.Restrict);
    }
}

public class PaymentConfiguration : IEntityTypeConfiguration<Payment>
{
    public void Configure(EntityTypeBuilder<Payment> builder)
    {
        builder.Property(e => e.Amount).HasPrecision(18, 2);
        builder.Property(e => e.RefundedAmount).HasPrecision(18, 2);
        builder.Property(e => e.Currency).HasMaxLength(3).IsRequired();
        builder.Property(e => e.Status).HasConversion<string>().HasMaxLength(20).IsRequired();
        builder.Property(e => e.TransactionId).HasMaxLength(128);
        builder.Property(e => e.FailureReason).HasMaxLength(500);

        builder.HasIndex(e => e.TransactionId).IsUnique().HasFilter("[TransactionId] IS NOT NULL");
        builder.HasIndex(e => new { e.SkiPassOrderId, e.Status });

        builder.HasOne(e => e.SkiPassOrder)
            .WithMany(o => o.Payments)
            .HasForeignKey(e => e.SkiPassOrderId)
            .OnDelete(DeleteBehavior.Restrict);

        builder.HasOne(e => e.PaymentMethod)
            .WithMany(p => p.Payments)
            .HasForeignKey(e => e.PaymentMethodId)
            .OnDelete(DeleteBehavior.Restrict);
    }
}

public class TicketValidationConfiguration : IEntityTypeConfiguration<TicketValidation>
{
    public void Configure(EntityTypeBuilder<TicketValidation> builder)
    {
        builder.Property(e => e.FailureReason).HasMaxLength(300);
        builder.HasIndex(e => new { e.SkiPassTicketId, e.ValidatedAt });

        builder.HasOne(e => e.SkiPassTicket)
            .WithMany(t => t.Validations)
            .HasForeignKey(e => e.SkiPassTicketId)
            .OnDelete(DeleteBehavior.Restrict);

        builder.HasOne(e => e.SkiLift)
            .WithMany(l => l.Validations)
            .HasForeignKey(e => e.SkiLiftId)
            .OnDelete(DeleteBehavior.Restrict);

        builder.HasOne(e => e.ValidatedByUser)
            .WithMany()
            .HasForeignKey(e => e.ValidatedByUserId)
            .OnDelete(DeleteBehavior.Restrict);
    }
}
