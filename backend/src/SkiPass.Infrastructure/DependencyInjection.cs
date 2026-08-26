using Microsoft.AspNetCore.Identity;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using SkiPass.Application.Services.Interfaces;
using SkiPass.Domain.Entities;
using SkiPass.Domain.Interfaces;
using SkiPass.Infrastructure.Data;
using SkiPass.Infrastructure.Messaging;
using SkiPass.Infrastructure.Repositories;
using SkiPass.Infrastructure.Services;
using SkiPass.Infrastructure.Services.Reference;

namespace SkiPass.Infrastructure;

public static class DependencyInjection
{
    public static IServiceCollection AddInfrastructure(this IServiceCollection services, IConfiguration configuration)
    {
        // Jedna konekcija za citav zivotni vijek aplikacije - zato Singleton, ne Scoped.
        services.AddSingleton<IEmailQueuePublisher, RabbitMqEmailPublisher>();

        services.AddDbContext<ApplicationDbContext>(options =>
            options.UseSqlServer(
                configuration.GetConnectionString("DefaultConnection"),
                sql => sql
                    .MigrationsAssembly(typeof(ApplicationDbContext).Assembly.FullName)
                    // Vise Include-ova nad kolekcijama u jednom upitu dovodi do
                    // Kartezijevog umnoska; EF zato izvrsava odvojene upite po kolekciji.
                    .UseQuerySplittingBehavior(QuerySplittingBehavior.SplitQuery)));

        services.AddIdentityCore<ApplicationUser>(options =>
            {
                options.User.RequireUniqueEmail = true;
                // Nastavni demo nalozi koriste lozinku "test", pa je minimalna duzina uskladjena sa tim.
                options.Password.RequiredLength = 4;
                options.Password.RequireDigit = false;
                options.Password.RequireLowercase = false;
                options.Password.RequireUppercase = false;
                options.Password.RequireNonAlphanumeric = false;
            })
            .AddRoles<IdentityRole<int>>()
            .AddEntityFrameworkStores<ApplicationDbContext>()
            .AddDefaultTokenProviders();

        // Kod za reset lozinke vazi jedan sat.
        services.Configure<DataProtectionTokenProviderOptions>(options =>
            options.TokenLifespan = TimeSpan.FromHours(1));

        services.AddMemoryCache();

        services.AddScoped(typeof(IRepository<>), typeof(Repository<>));
        services.AddScoped<IUnitOfWork, UnitOfWork>();

        // Svi servisi koji koriste DbContext moraju biti Scoped.
        services.AddScoped<ICurrentUserService, CurrentUserService>();
        services.AddScoped<IJwtTokenService, JwtTokenService>();
        services.AddScoped<IAuthService, AuthService>();

        // Referentni podaci
        services.AddScoped<ICountryService, CountryService>();
        services.AddScoped<ICityService, CityService>();
        services.AddScoped<ITrailDifficultyService, TrailDifficultyService>();
        services.AddScoped<ILiftTypeService, LiftTypeService>();
        services.AddScoped<IIncidentTypeService, IncidentTypeService>();
        services.AddScoped<IBenefitCategoryService, BenefitCategoryService>();
        services.AddScoped<IAnnouncementCategoryService, AnnouncementCategoryService>();
        services.AddScoped<IPaymentMethodService, PaymentMethodService>();
        services.AddSingleton<IEnumLookupService, EnumLookupService>();

        // Glavni entiteti
        services.AddScoped<IUserService, UserService>();
        services.AddScoped<ISkiResortService, SkiResortService>();
        services.AddScoped<ITrailService, TrailService>();
        services.AddScoped<ITrailConditionLogService, TrailConditionLogService>();
        services.AddScoped<ISkiLiftService, SkiLiftService>();
        services.AddScoped<ILiftMaintenanceService, LiftMaintenanceService>();
        services.AddScoped<ITicketTypeService, TicketTypeService>();
        services.AddScoped<ISkiPassOrderService, SkiPassOrderService>();
        services.AddScoped<ISkiPassTicketService, SkiPassTicketService>();
        services.AddScoped<IPaymentService, PaymentService>();
        services.AddScoped<IPartnerService, PartnerService>();
        services.AddScoped<IBenefitService, BenefitService>();
        services.AddScoped<IBenefitPurchaseService, BenefitPurchaseService>();
        services.AddScoped<IBenefitViewService, BenefitViewService>();
        services.AddScoped<IRecommenderService, RecommenderService>();
        services.AddScoped<IIncidentService, IncidentService>();
        services.AddScoped<IAnnouncementService, AnnouncementService>();
        services.AddScoped<INotificationService, NotificationService>();
        services.AddScoped<IReviewService, ReviewService>();
        services.AddScoped<IWeatherLogService, WeatherLogService>();
        services.AddScoped<IHomeService, HomeService>();
        services.AddScoped<IReportService, ReportService>();

        return services;
    }
}
