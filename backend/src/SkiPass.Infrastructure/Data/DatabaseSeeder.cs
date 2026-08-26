using Microsoft.AspNetCore.Identity;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Logging;
using SkiPass.Domain.Constants;
using SkiPass.Domain.Entities;
using SkiPass.Domain.Enums;

namespace SkiPass.Infrastructure.Data;

/// <summary>
/// Puni bazu podacima potrebnim za testiranje aplikacije. Seeder je idempotentan -
/// pokrece se pri svakom startu, ali dodaje samo ono sto jos ne postoji.
/// Lozinke se hashiraju iskljucivo kroz ASP.NET Identity, pa je format hasha
/// identican onom koji se koristi pri registraciji kroz aplikaciju.
/// </summary>
public static class DatabaseSeeder
{
    public static async Task SeedAsync(IServiceProvider services, CancellationToken cancellationToken = default)
    {
        var context = services.GetRequiredService<ApplicationDbContext>();
        var configuration = services.GetRequiredService<IConfiguration>();
        var logger = services.GetRequiredService<ILoggerFactory>().CreateLogger(typeof(DatabaseSeeder));

        await SeedRolesAsync(services, cancellationToken);
        await SeedReferenceDataAsync(context, cancellationToken);
        var users = await SeedUsersAsync(services, context, configuration, cancellationToken);
        var resort = await SeedResortAsync(context, cancellationToken);
        await SeedTrailsAndLiftsAsync(context, resort, users, cancellationToken);
        await SeedTicketTypesAsync(context, resort, cancellationToken);
        await SeedPartnersAndBenefitsAsync(context, resort, cancellationToken);
        await SeedOrdersAsync(context, resort, users, cancellationToken);
        await SeedOperationalDataAsync(context, resort, users, cancellationToken);

        logger.LogInformation("Seed podataka je zavrsen.");
    }

    private static async Task SeedRolesAsync(IServiceProvider services, CancellationToken cancellationToken)
    {
        var roleManager = services.GetRequiredService<RoleManager<IdentityRole<int>>>();

        foreach (var role in Roles.All)
        {
            if (!await roleManager.RoleExistsAsync(role))
            {
                await roleManager.CreateAsync(new IdentityRole<int>(role));
            }
        }
    }

    private static async Task SeedReferenceDataAsync(ApplicationDbContext context, CancellationToken cancellationToken)
    {
        if (!await context.Countries.AnyAsync(cancellationToken))
        {
            context.Countries.AddRange(
                new Country { Name = "Bosna i Hercegovina", IsoCode = "BIH" },
                new Country { Name = "Hrvatska", IsoCode = "HRV" },
                new Country { Name = "Srbija", IsoCode = "SRB" },
                new Country { Name = "Austrija", IsoCode = "AUT" });

            await context.SaveChangesAsync(cancellationToken);
        }

        if (!await context.Cities.AnyAsync(cancellationToken))
        {
            var bih = await context.Countries.FirstAsync(c => c.IsoCode == "BIH", cancellationToken);
            var hrv = await context.Countries.FirstAsync(c => c.IsoCode == "HRV", cancellationToken);

            context.Cities.AddRange(
                new City { Name = "Mostar", PostalCode = "88000", CountryId = bih.Id },
                new City { Name = "Sarajevo", PostalCode = "71000", CountryId = bih.Id },
                new City { Name = "Konjic", PostalCode = "88400", CountryId = bih.Id },
                new City { Name = "Jablanica", PostalCode = "88420", CountryId = bih.Id },
                new City { Name = "Banja Luka", PostalCode = "78000", CountryId = bih.Id },
                new City { Name = "Zagreb", PostalCode = "10000", CountryId = hrv.Id });

            await context.SaveChangesAsync(cancellationToken);
        }

        if (!await context.TrailDifficulties.AnyAsync(cancellationToken))
        {
            context.TrailDifficulties.AddRange(
                new TrailDifficulty { Name = "Plava", Description = "Laka staza, pogodna za pocetnike.", ColorHex = "#1E88E5", SortOrder = 1 },
                new TrailDifficulty { Name = "Crvena", Description = "Srednje zahtjevna staza za iskusnije skijase.", ColorHex = "#E53935", SortOrder = 2 },
                new TrailDifficulty { Name = "Crna", Description = "Zahtjevna staza za napredne skijase.", ColorHex = "#212121", SortOrder = 3 });

            await context.SaveChangesAsync(cancellationToken);
        }

        if (!await context.LiftTypes.AnyAsync(cancellationToken))
        {
            context.LiftTypes.AddRange(
                new LiftType { Name = "Sidro", Description = "Vucni lift sa sidrom za jednu ili dvije osobe." },
                new LiftType { Name = "Sjedeznica", Description = "Lift sa sjedistima, cetiri do sest osoba." },
                new LiftType { Name = "Gondola", Description = "Zatvorena kabina za prijevoz vise osoba." },
                new LiftType { Name = "Tepih", Description = "Pokretna traka za skijaliste za pocetnike." });

            await context.SaveChangesAsync(cancellationToken);
        }

        if (!await context.IncidentTypes.AnyAsync(cancellationToken))
        {
            context.IncidentTypes.AddRange(
                new IncidentType { Name = "Povreda korisnika", Description = "Skijas se povrijedio na stazi.", IsUrgentByDefault = true },
                new IncidentType { Name = "Lose stanje staze", Description = "Poledica, kamenje ili nedostatak snijega.", IsUrgentByDefault = false },
                new IncidentType { Name = "Kvar ski lifta", Description = "Lift je stao ili radi neispravno.", IsUrgentByDefault = true },
                new IncidentType { Name = "Izgubljena osoba", Description = "Prijava nestanka osobe na skijalistu.", IsUrgentByDefault = true });

            await context.SaveChangesAsync(cancellationToken);
        }

        if (!await context.BenefitCategories.AnyAsync(cancellationToken))
        {
            context.BenefitCategories.AddRange(
                new BenefitCategory { Name = "Iznajmljivanje opreme", Description = "Skije, stapovi, kacige i naocale.", IconName = "downhill_skiing" },
                new BenefitCategory { Name = "Ugostiteljstvo", Description = "Restorani i objekti na skijalistu.", IconName = "restaurant" },
                new BenefitCategory { Name = "Skola skijanja", Description = "Individualne i grupne obuke.", IconName = "school" },
                new BenefitCategory { Name = "Smjestaj", Description = "Partnerski smjestajni kapaciteti.", IconName = "hotel" },
                new BenefitCategory { Name = "Servis opreme", Description = "Brusenje i voskanje skija.", IconName = "build" });

            await context.SaveChangesAsync(cancellationToken);
        }

        if (!await context.AnnouncementCategories.AnyAsync(cancellationToken))
        {
            context.AnnouncementCategories.AddRange(
                new AnnouncementCategory { Name = "Vremenski uslovi", Description = "Obavijesti o vremenu i snijegu." },
                new AnnouncementCategory { Name = "Zatvaranje staza", Description = "Privremeno zatvaranje staza." },
                new AnnouncementCategory { Name = "Kvarovi ski liftova", Description = "Zastoji i odrzavanje liftova." },
                new AnnouncementCategory { Name = "Posebne pogodnosti", Description = "Novosti u ponudi pogodnosti." },
                new AnnouncementCategory { Name = "Akcijske ponude", Description = "Popusti na ski pass karte." });

            await context.SaveChangesAsync(cancellationToken);
        }

        if (!await context.PaymentMethods.AnyAsync(cancellationToken))
        {
            context.PaymentMethods.AddRange(
                // IsOnline = true ide preko Stripe-a (PaymentService.InitiateAsync) - stvarna
                // finalizacija se desava tek preko Stripe webhook-a, nikad na klijentu.
                new PaymentMethod { Name = "Platna kartica", Code = "CARD", IsOnline = true, IsActive = true },
                new PaymentMethod { Name = "Gotovina na blagajni", Code = "CASH", IsOnline = false, IsActive = true });

            await context.SaveChangesAsync(cancellationToken);
        }
    }

    private static async Task<SeedUsers> SeedUsersAsync(
        IServiceProvider services,
        ApplicationDbContext context,
        IConfiguration configuration,
        CancellationToken cancellationToken)
    {
        var userManager = services.GetRequiredService<UserManager<ApplicationUser>>();

        var mostar = await context.Cities.FirstAsync(c => c.Name == "Mostar", cancellationToken);
        var sarajevo = await context.Cities.FirstAsync(c => c.Name == "Sarajevo", cancellationToken);
        var konjic = await context.Cities.FirstAsync(c => c.Name == "Konjic", cancellationToken);

        var adminPassword = configuration["Seed:AdminPassword"] ?? "test";
        var staffPassword = configuration["Seed:StaffPassword"] ?? "test";
        var skierPassword = configuration["Seed:SkierPassword"] ?? "test";

        var admin = await EnsureUserAsync(userManager, context,
            "desktop", "admin@skipass.ba", "Tarik", "Ganic", UserRole.Admin, adminPassword,
            mostar.Id, "+387 61 100 100", new DateTime(1996, 4, 12), cancellationToken);

        var staff = await EnsureUserAsync(userManager, context,
            "osoblje", "osoblje@skipass.ba", "Amina", "Hodzic", UserRole.Staff, staffPassword,
            mostar.Id, "+387 61 200 200", new DateTime(1993, 9, 3), cancellationToken);

        var staffSecond = await EnsureUserAsync(userManager, context,
            "osoblje2", "osoblje2@skipass.ba", "Emir", "Balic", UserRole.Staff, staffPassword,
            konjic.Id, "+387 61 200 201", new DateTime(1990, 1, 25), cancellationToken);

        var skier = await EnsureUserAsync(userManager, context,
            "mobile", "skijas@skipass.ba", "Lejla", "Music", UserRole.Skier, skierPassword,
            sarajevo.Id, "+387 62 300 300", new DateTime(1999, 11, 8), cancellationToken);

        var skierSecond = await EnsureUserAsync(userManager, context,
            "mobile2", "skijas2@skipass.ba", "Haris", "Softic", UserRole.Skier, skierPassword,
            konjic.Id, "+387 62 300 301", new DateTime(2002, 6, 17), cancellationToken);

        var skierThird = await EnsureUserAsync(userManager, context,
            "mobile3", "skijas3@skipass.ba", "Ivana", "Peric", UserRole.Skier, skierPassword,
            mostar.Id, "+387 62 300 302", new DateTime(1988, 2, 2), cancellationToken);

        return new SeedUsers(admin, staff, staffSecond, skier, skierSecond, skierThird);
    }

    private static async Task<User> EnsureUserAsync(
        UserManager<ApplicationUser> userManager,
        ApplicationDbContext context,
        string username,
        string email,
        string firstName,
        string lastName,
        UserRole role,
        string password,
        int cityId,
        string phone,
        DateTime birthDate,
        CancellationToken cancellationToken)
    {
        var existingProfile = await context.UserProfiles.FirstOrDefaultAsync(u => u.Email == email, cancellationToken);
        if (existingProfile is not null)
        {
            return existingProfile;
        }

        var identityUser = await userManager.FindByNameAsync(username);
        if (identityUser is null)
        {
            identityUser = new ApplicationUser
            {
                UserName = username,
                Email = email,
                PhoneNumber = phone,
                EmailConfirmed = true
            };

            var result = await userManager.CreateAsync(identityUser, password);
            if (!result.Succeeded)
            {
                throw new InvalidOperationException(
                    $"Kreiranje seed korisnika \"{username}\" nije uspjelo: {string.Join(", ", result.Errors.Select(e => e.Description))}");
            }
        }

        if (!await userManager.IsInRoleAsync(identityUser, role.ToString()))
        {
            await userManager.AddToRoleAsync(identityUser, role.ToString());
        }

        var profile = new User
        {
            IdentityUserId = identityUser.Id,
            FirstName = firstName,
            LastName = lastName,
            Email = email,
            Phone = phone,
            BirthDate = birthDate,
            CityId = cityId,
            Role = role,
            IsActive = true
        };

        context.UserProfiles.Add(profile);
        await context.SaveChangesAsync(cancellationToken);

        return profile;
    }

    private static async Task<SkiResort> SeedResortAsync(ApplicationDbContext context, CancellationToken cancellationToken)
    {
        var existing = await context.SkiResorts.OrderBy(r => r.Id).FirstOrDefaultAsync(cancellationToken);
        if (existing is not null)
        {
            return existing;
        }

        var konjic = await context.Cities.FirstAsync(c => c.Name == "Konjic", cancellationToken);

        var resort = new SkiResort
        {
            Name = "Ski centar Bjelasnica",
            Description = "Skijaliste sa uredjenim stazama razlicite tezine, modernim liftovima i bogatom dodatnom ponudom.",
            ContactEmail = "info@skipass.ba",
            ContactPhone = "+387 36 555 100",
            Latitude = 43.7107,
            Longitude = 18.2686,
            BaseAltitudeMeters = 1266,
            PeakAltitudeMeters = 2067,
            OpeningTime = new TimeOnly(08, 30),
            ClosingTime = new TimeOnly(16, 00),
            IsActive = true,
            CityId = konjic.Id
        };

        context.SkiResorts.Add(resort);
        await context.SaveChangesAsync(cancellationToken);

        return resort;
    }

    private static async Task SeedTrailsAndLiftsAsync(
        ApplicationDbContext context,
        SkiResort resort,
        SeedUsers users,
        CancellationToken cancellationToken)
    {
        if (!await context.Trails.AnyAsync(cancellationToken))
        {
            var blue = await context.TrailDifficulties.FirstAsync(d => d.Name == "Plava", cancellationToken);
            var red = await context.TrailDifficulties.FirstAsync(d => d.Name == "Crvena", cancellationToken);
            var black = await context.TrailDifficulties.FirstAsync(d => d.Name == "Crna", cancellationToken);

            context.Trails.AddRange(
                NewTrail("Vlasic", "STAZA-01", 1800, 320, blue.Id, resort.Id, CrowdLevel.Moderate, nightSkiing: true),
                NewTrail("Kolijevka", "STAZA-02", 1200, 180, blue.Id, resort.Id, CrowdLevel.High, nightSkiing: true),
                NewTrail("Stit", "STAZA-03", 2400, 540, red.Id, resort.Id, CrowdLevel.Moderate),
                NewTrail("Vrelo", "STAZA-04", 2900, 610, red.Id, resort.Id, CrowdLevel.Low),
                NewTrail("Ponor", "STAZA-05", 3200, 780, black.Id, resort.Id, CrowdLevel.Low),
                NewTrail("Orlov krs", "STAZA-06", 2100, 690, black.Id, resort.Id, CrowdLevel.Low, isOpen: false));

            await context.SaveChangesAsync(cancellationToken);
        }

        if (!await context.SkiLifts.AnyAsync(cancellationToken))
        {
            var anchor = await context.LiftTypes.FirstAsync(t => t.Name == "Sidro", cancellationToken);
            var chair = await context.LiftTypes.FirstAsync(t => t.Name == "Sjedeznica", cancellationToken);
            var gondola = await context.LiftTypes.FirstAsync(t => t.Name == "Gondola", cancellationToken);
            var carpet = await context.LiftTypes.FirstAsync(t => t.Name == "Tepih", cancellationToken);

            context.SkiLifts.AddRange(
                NewLift("Gondola Bjelasnica", "LIFT-01", 2600, 2400, 9, gondola.Id, resort.Id, currentRiders: 84),
                NewLift("Sjedeznica Stit", "LIFT-02", 1900, 1800, 7, chair.Id, resort.Id, currentRiders: 46),
                NewLift("Sjedeznica Vrelo", "LIFT-03", 1500, 1600, 6, chair.Id, resort.Id, currentRiders: 31),
                NewLift("Sidro Kolijevka", "LIFT-04", 700, 900, 4, anchor.Id, resort.Id, currentRiders: 12),
                NewLift("Tepih Pocetnik", "LIFT-05", 120, 600, 2, carpet.Id, resort.Id, currentRiders: 8),
                NewLift("Sidro Ponor", "LIFT-06", 1100, 800, 5, anchor.Id, resort.Id, isOperational: false));

            await context.SaveChangesAsync(cancellationToken);
        }

        if (!await context.TrailConditionLogs.AnyAsync(cancellationToken))
        {
            var trails = await context.Trails.OrderBy(t => t.Id).ToListAsync(cancellationToken);
            var notes = new[]
            {
                "Staza uredjena, snijeg zbijen i pogodan za skijanje.",
                "Jutarnja poledica na donjem dijelu staze, preporucen oprez.",
                "Svjez snijeg, odlicni uslovi za skijanje.",
                "Vjetar na vrhu staze, vidljivost smanjena."
            };

            for (var i = 0; i < trails.Count; i++)
            {
                for (var day = 1; day <= 3; day++)
                {
                    context.TrailConditionLogs.Add(new TrailConditionLog
                    {
                        TrailId = trails[i].Id,
                        RecordedAt = DateTime.UtcNow.AddDays(-day).AddHours(-i),
                        SnowDepthCm = 60 + (i * 5) - (day * 3),
                        ConditionNote = notes[(i + day) % notes.Length],
                        IsTrailOpen = trails[i].IsOpen,
                        RecordedByUserId = day % 2 == 0 ? users.Staff.Id : users.StaffSecond.Id
                    });
                }
            }

            await context.SaveChangesAsync(cancellationToken);
        }

        if (!await context.LiftMaintenanceRecords.AnyAsync(cancellationToken))
        {
            var brokenLift = await context.SkiLifts.FirstAsync(l => l.Code == "LIFT-06", cancellationToken);
            var workingLift = await context.SkiLifts.FirstAsync(l => l.Code == "LIFT-02", cancellationToken);

            context.LiftMaintenanceRecords.AddRange(
                new LiftMaintenanceRecord
                {
                    SkiLiftId = brokenLift.Id,
                    ReportedAt = DateTime.UtcNow.AddDays(-2),
                    Description = "Kvar na pogonskom motoru, lift se ne pokrece.",
                    Status = MaintenanceStatus.InProgress,
                    RequiresShutdown = true,
                    ReportedByUserId = users.Staff.Id
                },
                new LiftMaintenanceRecord
                {
                    SkiLiftId = workingLift.Id,
                    ReportedAt = DateTime.UtcNow.AddDays(-14),
                    ResolvedAt = DateTime.UtcNow.AddDays(-13),
                    Description = "Redovno servisiranje sajle i podmazivanje lezajeva.",
                    ResolutionNote = "Servis zavrsen, lift vracen u pogon.",
                    Status = MaintenanceStatus.Completed,
                    RequiresShutdown = false,
                    ReportedByUserId = users.StaffSecond.Id,
                    ResolvedByUserId = users.Staff.Id
                });

            await context.SaveChangesAsync(cancellationToken);
        }
    }

    private static async Task SeedTicketTypesAsync(ApplicationDbContext context, SkiResort resort, CancellationToken cancellationToken)
    {
        if (await context.TicketTypes.AnyAsync(cancellationToken))
        {
            return;
        }

        context.TicketTypes.AddRange(
            new TicketType
            {
                Name = "Dnevna karta - odrasli",
                Description = "Neograniceno koristenje svih liftova tokom jednog dana.",
                PricePerDay = 45.00m, MaxDays = 1, DiscountPercentage = 0, MinAge = 18, SkiResortId = resort.Id
            },
            new TicketType
            {
                Name = "Dnevna karta - djeca",
                Description = "Dnevna karta za djecu do 14 godina uz pratnju odrasle osobe.",
                PricePerDay = 45.00m, MaxDays = 1, DiscountPercentage = 50, MinAge = 0, MaxAge = 14, SkiResortId = resort.Id
            },
            new TicketType
            {
                Name = "Visednevna karta",
                Description = "Karta za dva do sedam uzastopnih dana skijanja.",
                PricePerDay = 42.00m, MaxDays = 7, DiscountPercentage = 10, MinAge = 18, SkiResortId = resort.Id
            },
            new TicketType
            {
                Name = "Sedmicna karta",
                Description = "Sedam dana skijanja po povoljnijoj cijeni.",
                PricePerDay = 38.00m, MaxDays = 7, DiscountPercentage = 15, SkiResortId = resort.Id
            },
            new TicketType
            {
                Name = "Studentska karta",
                Description = "Popust za studente uz predocenje indeksa na blagajni.",
                PricePerDay = 45.00m, MaxDays = 5, DiscountPercentage = 25, MinAge = 18, MaxAge = 26, SkiResortId = resort.Id
            },
            new TicketType
            {
                Name = "Nocno skijanje",
                Description = "Vazi na osvijetljenim stazama od 17 do 21 sat.",
                PricePerDay = 25.00m, MaxDays = 1, DiscountPercentage = 0, SkiResortId = resort.Id
            });

        await context.SaveChangesAsync(cancellationToken);
    }

    private static async Task SeedPartnersAndBenefitsAsync(ApplicationDbContext context, SkiResort resort, CancellationToken cancellationToken)
    {
        if (!await context.Partners.AnyAsync(cancellationToken))
        {
            var konjic = await context.Cities.FirstAsync(c => c.Name == "Konjic", cancellationToken);
            var sarajevo = await context.Cities.FirstAsync(c => c.Name == "Sarajevo", cancellationToken);

            context.Partners.AddRange(
                new Partner
                {
                    Name = "Alpina Sport", Description = "Iznajmljivanje i servis skijaske opreme.",
                    ContactEmail = "info@alpinasport.ba", ContactPhone = "+387 36 555 200",
                    Website = "https://www.alpinasport.ba", Address = "Podnozje staze 1", CityId = konjic.Id
                },
                new Partner
                {
                    Name = "Restoran Vidikovac", Description = "Restoran domace kuhinje na vrhu skijalista.",
                    ContactEmail = "rezervacije@vidikovac.ba", ContactPhone = "+387 36 555 300",
                    Address = "Vrh Bjelasnice bb", CityId = konjic.Id
                },
                new Partner
                {
                    Name = "Ski skola Snjezana", Description = "Licencirani instruktori skijanja i snowboarda.",
                    ContactEmail = "skola@snjezana.ba", ContactPhone = "+387 61 555 400",
                    Address = "Pocetnicka staza bb", CityId = konjic.Id
                },
                new Partner
                {
                    Name = "Hotel Bjelasnica", Description = "Smjestaj u neposrednoj blizini staza.",
                    ContactEmail = "booking@hotelbjelasnica.ba", ContactPhone = "+387 33 555 500",
                    Website = "https://www.hotelbjelasnica.ba", Address = "Babin do bb", CityId = sarajevo.Id
                });

            await context.SaveChangesAsync(cancellationToken);
        }

        if (await context.Benefits.AnyAsync(cancellationToken))
        {
            return;
        }

        var equipment = await context.BenefitCategories.FirstAsync(c => c.Name == "Iznajmljivanje opreme", cancellationToken);
        var food = await context.BenefitCategories.FirstAsync(c => c.Name == "Ugostiteljstvo", cancellationToken);
        var school = await context.BenefitCategories.FirstAsync(c => c.Name == "Skola skijanja", cancellationToken);
        var lodging = await context.BenefitCategories.FirstAsync(c => c.Name == "Smjestaj", cancellationToken);
        var servicing = await context.BenefitCategories.FirstAsync(c => c.Name == "Servis opreme", cancellationToken);

        var alpina = await context.Partners.FirstAsync(p => p.Name == "Alpina Sport", cancellationToken);
        var restaurant = await context.Partners.FirstAsync(p => p.Name == "Restoran Vidikovac", cancellationToken);
        var skiSchool = await context.Partners.FirstAsync(p => p.Name == "Ski skola Snjezana", cancellationToken);
        var hotel = await context.Partners.FirstAsync(p => p.Name == "Hotel Bjelasnica", cancellationToken);

        context.Benefits.AddRange(
            NewBenefit("Iznajmljivanje skija - dnevno", "Kompletan set skija sa vezovima, prilagodjen visini i tezini korisnika.", 30m, 0, "Atomic", equipment.Id, resort.Id, alpina.Id),
            NewBenefit("Iznajmljivanje snowboarda", "Snowboard daska sa vezovima za jedan dan.", 35m, 0, "Burton", equipment.Id, resort.Id, alpina.Id),
            NewBenefit("Iznajmljivanje stapova", "Aluminijski skijaski stapovi, dnevni najam.", 8m, 0, "Atomic", equipment.Id, resort.Id, alpina.Id),
            NewBenefit("Iznajmljivanje kacige", "Zastitna kaciga sa podesivim obimom.", 12m, 0, "Salomon", equipment.Id, resort.Id, alpina.Id),
            NewBenefit("Iznajmljivanje naocala", "Skijaske naocale sa UV zastitom.", 10m, 10, "Uvex", equipment.Id, resort.Id, alpina.Id),
            NewBenefit("Iznajmljivanje pancerica", "Skijaske cizme svih velicina.", 18m, 0, "Salomon", equipment.Id, resort.Id, alpina.Id),
            NewBenefit("Dnevni meni Vidikovac", "Supa, glavno jelo i napitak u restoranu na vrhu.", 22m, 15, null, food.Id, resort.Id, restaurant.Id),
            NewBenefit("Topli napitak i kolac", "Kuhano vino ili topla cokolada uz domaci kolac.", 9m, 0, null, food.Id, resort.Id, restaurant.Id),
            NewBenefit("Individualna obuka skijanja", "Jedan sat obuke sa licenciranim instruktorom.", 60m, 0, null, school.Id, resort.Id, skiSchool.Id),
            NewBenefit("Grupna obuka skijanja", "Dva sata obuke u grupi do sest osoba.", 35m, 10, null, school.Id, resort.Id, skiSchool.Id),
            NewBenefit("Nocenje sa doruckom", "Nocenje u dvokrevetnoj sobi uz dorucak.", 95m, 20, null, lodging.Id, resort.Id, hotel.Id),
            NewBenefit("Brusenje i voskanje skija", "Kompletan servis skija u roku od 24 sata.", 25m, 0, "Atomic", servicing.Id, resort.Id, alpina.Id));

        await context.SaveChangesAsync(cancellationToken);
    }

    private static async Task SeedOrdersAsync(
        ApplicationDbContext context,
        SkiResort resort,
        SeedUsers users,
        CancellationToken cancellationToken)
    {
        if (await context.SkiPassOrders.AnyAsync(cancellationToken))
        {
            return;
        }

        var card = await context.PaymentMethods.FirstAsync(p => p.Code == "CARD", cancellationToken);
        var cash = await context.PaymentMethods.FirstAsync(p => p.Code == "CASH", cancellationToken);

        var daily = await context.TicketTypes.FirstAsync(t => t.Name == "Dnevna karta - odrasli", cancellationToken);
        var child = await context.TicketTypes.FirstAsync(t => t.Name == "Dnevna karta - djeca", cancellationToken);
        var multiDay = await context.TicketTypes.FirstAsync(t => t.Name == "Visednevna karta", cancellationToken);
        var weekly = await context.TicketTypes.FirstAsync(t => t.Name == "Sedmicna karta", cancellationToken);

        var today = DateOnly.FromDateTime(DateTime.UtcNow);

        // Placena i potvrdjena porodicna narudzba - karte su aktivne.
        var familyOrder = NewOrder("SP-SEED-0001", users.Skier.Id, card.Id, OrderStatus.Confirmed, DateTime.UtcNow.AddDays(-3));
        // Sedmicna karta nosioca narudzbe ostaje upotrebljiva jos sedam dana od seed-a,
        // pa se QR validacija moze testirati i danima nakon prvog pokretanja.
        familyOrder.Tickets.Add(NewTicket("SP-SEEDFAMILY00001", "Lejla", "Music", today, 7, weekly, 226.10m, TicketStatus.Active));
        familyOrder.Tickets.Add(NewTicket("SP-SEEDFAMILY00002", "Adna", "Music", today, 1, child, 22.50m, TicketStatus.Active));
        familyOrder.Tickets.Add(NewTicket("SP-SEEDFAMILY00003", "Kenan", "Music", today, 1, child, 22.50m, TicketStatus.Active));
        familyOrder.TotalAmount = familyOrder.Tickets.Sum(t => t.Price);
        familyOrder.ConfirmedAt = DateTime.UtcNow.AddDays(-3);
        familyOrder.StatusChangedByUserId = users.Staff.Id;

        // Visednevna karta kupljena unaprijed.
        var futureOrder = NewOrder("SP-SEED-0002", users.SkierSecond.Id, card.Id, OrderStatus.Confirmed, DateTime.UtcNow.AddDays(-1));
        futureOrder.Tickets.Add(NewTicket("SP-SEEDFUTURE00001", "Haris", "Softic", today.AddDays(5), 3, multiDay, 113.40m, TicketStatus.Active));
        futureOrder.TotalAmount = futureOrder.Tickets.Sum(t => t.Price);
        futureOrder.ConfirmedAt = DateTime.UtcNow.AddDays(-1);
        futureOrder.StatusChangedByUserId = users.Staff.Id;

        // Narudzba koja ceka placanje na blagajni.
        var pendingOrder = NewOrder("SP-SEED-0003", users.SkierThird.Id, cash.Id, OrderStatus.Pending, DateTime.UtcNow.AddHours(-5));
        pendingOrder.Tickets.Add(NewTicket("SP-SEEDPENDING0001", "Ivana", "Peric", today.AddDays(1), 7, weekly, 226.10m, TicketStatus.Pending));
        pendingOrder.TotalAmount = pendingOrder.Tickets.Sum(t => t.Price);

        // Otkazana narudzba sa evidentiranim razlogom.
        var cancelledOrder = NewOrder("SP-SEED-0004", users.Skier.Id, card.Id, OrderStatus.Cancelled, DateTime.UtcNow.AddDays(-10));
        cancelledOrder.Tickets.Add(NewTicket("SP-SEEDCANCEL00001", "Lejla", "Music", today.AddDays(-6), 1, daily, daily.PricePerDay, TicketStatus.Cancelled));
        cancelledOrder.TotalAmount = cancelledOrder.Tickets.Sum(t => t.Price);
        cancelledOrder.CancelledAt = DateTime.UtcNow.AddDays(-9);
        cancelledOrder.CancellationReason = "Skijaliste je bilo zatvoreno zbog nevremena.";
        cancelledOrder.StatusChangedByUserId = users.Staff.Id;

        context.SkiPassOrders.AddRange(familyOrder, futureOrder, pendingOrder, cancelledOrder);
        await context.SaveChangesAsync(cancellationToken);

        context.Payments.AddRange(
            new Payment
            {
                SkiPassOrderId = familyOrder.Id, PaymentMethodId = card.Id, Amount = familyOrder.TotalAmount,
                Currency = "BAM", Status = PaymentStatus.Completed, TransactionId = "SEED-STRIPE-0001",
                PaidAt = DateTime.UtcNow.AddDays(-3)
            },
            new Payment
            {
                SkiPassOrderId = futureOrder.Id, PaymentMethodId = card.Id, Amount = futureOrder.TotalAmount,
                Currency = "BAM", Status = PaymentStatus.Completed, TransactionId = "SEED-CARD-0002",
                PaidAt = DateTime.UtcNow.AddDays(-1)
            },
            new Payment
            {
                SkiPassOrderId = cancelledOrder.Id, PaymentMethodId = card.Id, Amount = cancelledOrder.TotalAmount,
                Currency = "BAM", Status = PaymentStatus.Refunded, TransactionId = "SEED-CARD-0003",
                PaidAt = DateTime.UtcNow.AddDays(-10), RefundedAmount = cancelledOrder.TotalAmount,
                RefundedAt = DateTime.UtcNow.AddDays(-9)
            });

        await context.SaveChangesAsync(cancellationToken);

        var gondola = await context.SkiLifts.FirstAsync(l => l.Code == "LIFT-01", cancellationToken);
        var chairLift = await context.SkiLifts.FirstAsync(l => l.Code == "LIFT-02", cancellationToken);
        var activeTicket = familyOrder.Tickets.First();

        context.TicketValidations.AddRange(
            new TicketValidation
            {
                SkiPassTicketId = activeTicket.Id, SkiLiftId = gondola.Id, ValidatedByUserId = users.Staff.Id,
                ValidatedAt = DateTime.UtcNow.AddHours(-4), IsSuccessful = true
            },
            new TicketValidation
            {
                SkiPassTicketId = activeTicket.Id, SkiLiftId = chairLift.Id, ValidatedByUserId = users.StaffSecond.Id,
                ValidatedAt = DateTime.UtcNow.AddHours(-3), IsSuccessful = true
            },
            new TicketValidation
            {
                SkiPassTicketId = cancelledOrder.Tickets.First().Id, SkiLiftId = gondola.Id,
                ValidatedByUserId = users.Staff.Id, ValidatedAt = DateTime.UtcNow.AddDays(-6),
                IsSuccessful = false, FailureReason = "Karta je otkazana."
            });

        await context.SaveChangesAsync(cancellationToken);
    }

    private static async Task SeedOperationalDataAsync(
        ApplicationDbContext context,
        SkiResort resort,
        SeedUsers users,
        CancellationToken cancellationToken)
    {
        if (!await context.WeatherLogs.AnyAsync(cancellationToken))
        {
            var conditions = new[] { "Suncano", "Djelimicno oblacno", "Snijeg", "Snijeg sa vjetrom", "Magla" };

            for (var day = 0; day < 7; day++)
            {
                context.WeatherLogs.Add(new WeatherLog
                {
                    SkiResortId = resort.Id,
                    RecordedAt = DateTime.UtcNow.AddDays(-day),
                    TemperatureCelsius = -2.5 - day * 0.8,
                    WindSpeedKmh = 12 + day * 3,
                    SnowfallCm = day % 3 == 0 ? 6.5 : 0,
                    SnowDepthCm = 72 - day * 2,
                    Conditions = conditions[day % conditions.Length],
                    VisibilityMeters = day % 4 == 0 ? 800 : 5000
                });
            }

            await context.SaveChangesAsync(cancellationToken);
        }

        if (!await context.Announcements.AnyAsync(cancellationToken))
        {
            var weather = await context.AnnouncementCategories.FirstAsync(c => c.Name == "Vremenski uslovi", cancellationToken);
            var closures = await context.AnnouncementCategories.FirstAsync(c => c.Name == "Zatvaranje staza", cancellationToken);
            var lifts = await context.AnnouncementCategories.FirstAsync(c => c.Name == "Kvarovi ski liftova", cancellationToken);
            var offers = await context.AnnouncementCategories.FirstAsync(c => c.Name == "Akcijske ponude", cancellationToken);

            context.Announcements.AddRange(
                NewAnnouncement("Novi snijeg na Bjelasnici", "Tokom noci palo je 15 cm novog snijega. Uslovi za skijanje su odlicni na svim otvorenim stazama.", weather.Id, resort.Id, users.Staff.Id, false, -1),
                NewAnnouncement("Staza Orlov krs privremeno zatvorena", "Zbog nedovoljnog snjeznog pokrivaca staza Orlov krs je zatvorena do daljnjeg.", closures.Id, resort.Id, users.Staff.Id, true, -2),
                NewAnnouncement("Kvar na sidru Ponor", "Lift Sidro Ponor je van pogona zbog kvara na pogonskom motoru. Servis je u toku.", lifts.Id, resort.Id, users.StaffSecond.Id, true, -2),
                NewAnnouncement("Popust na sedmicne karte", "Do kraja mjeseca sedmicne karte su dodatno snizene za sve korisnike aplikacije.", offers.Id, resort.Id, users.Admin.Id, false, -5),
                NewAnnouncement("Produzeno nocno skijanje", "Nocno skijanje se produzava do 22 sata svakim petkom i subotom.", offers.Id, resort.Id, users.Admin.Id, false, -7));

            await context.SaveChangesAsync(cancellationToken);
        }

        if (!await context.Incidents.AnyAsync(cancellationToken))
        {
            var injury = await context.IncidentTypes.FirstAsync(t => t.Name == "Povreda korisnika", cancellationToken);
            var conditionIssue = await context.IncidentTypes.FirstAsync(t => t.Name == "Lose stanje staze", cancellationToken);
            var liftFailure = await context.IncidentTypes.FirstAsync(t => t.Name == "Kvar ski lifta", cancellationToken);

            var trail = await context.Trails.FirstAsync(t => t.Code == "STAZA-03", cancellationToken);
            var trailSecond = await context.Trails.FirstAsync(t => t.Code == "STAZA-01", cancellationToken);
            var lift = await context.SkiLifts.FirstAsync(l => l.Code == "LIFT-06", cancellationToken);

            context.Incidents.AddRange(
                new Incident
                {
                    IncidentTypeId = injury.Id, TrailId = trail.Id, ReportedByUserId = users.Skier.Id,
                    ReportedAt = DateTime.UtcNow.AddHours(-6), Description = "Skijas je pao na sredini staze i zali se na bol u koljenu.",
                    Latitude = 43.7112, Longitude = 18.2691, Status = IncidentStatus.Resolved, IsUrgent = true,
                    ResolutionNote = "Ekipa spasilaca je intervenisala i prevezla skijasa do ambulante.",
                    HandledByUserId = users.Staff.Id, HandledAt = DateTime.UtcNow.AddHours(-5)
                },
                new Incident
                {
                    IncidentTypeId = conditionIssue.Id, TrailId = trailSecond.Id, ReportedByUserId = users.SkierSecond.Id,
                    ReportedAt = DateTime.UtcNow.AddHours(-3), Description = "Poledica na donjem dijelu staze, otezano koceenje.",
                    Latitude = 43.7098, Longitude = 18.2673, Status = IncidentStatus.InProgress, IsUrgent = false,
                    HandledByUserId = users.StaffSecond.Id, HandledAt = DateTime.UtcNow.AddHours(-2)
                },
                new Incident
                {
                    IncidentTypeId = liftFailure.Id, SkiLiftId = lift.Id, ReportedByUserId = users.SkierThird.Id,
                    ReportedAt = DateTime.UtcNow.AddDays(-2), Description = "Lift je stao dok sam bio na pola puta, cekali smo desetak minuta.",
                    Latitude = 43.7121, Longitude = 18.2702, Status = IncidentStatus.Reported, IsUrgent = true
                },
                new Incident
                {
                    IncidentTypeId = conditionIssue.Id, TrailId = trail.Id, ReportedByUserId = users.Skier.Id,
                    ReportedAt = DateTime.UtcNow.AddDays(-8), Description = "Navodno kamenje na stazi, ali provjerom nije pronadjeno.",
                    Latitude = 43.7105, Longitude = 18.2688, Status = IncidentStatus.Rejected, IsUrgent = false,
                    ResolutionNote = "Ekipa je obisla dionicu i nije utvrdila nepravilnosti.",
                    HandledByUserId = users.Staff.Id, HandledAt = DateTime.UtcNow.AddDays(-8).AddHours(2)
                });

            await context.SaveChangesAsync(cancellationToken);
        }

        if (!await context.BenefitPurchases.AnyAsync(cancellationToken))
        {
            var skiRental = await context.Benefits.FirstAsync(b => b.Name == "Iznajmljivanje skija - dnevno", cancellationToken);
            var helmet = await context.Benefits.FirstAsync(b => b.Name == "Iznajmljivanje kacige", cancellationToken);
            var menu = await context.Benefits.FirstAsync(b => b.Name == "Dnevni meni Vidikovac", cancellationToken);
            var lesson = await context.Benefits.FirstAsync(b => b.Name == "Grupna obuka skijanja", cancellationToken);
            var servicing = await context.Benefits.FirstAsync(b => b.Name == "Brusenje i voskanje skija", cancellationToken);

            context.BenefitPurchases.AddRange(
                NewPurchase(users.Skier.Id, skiRental.Id, 1, 30m, OrderStatus.Completed, -3),
                NewPurchase(users.Skier.Id, helmet.Id, 1, 12m, OrderStatus.Completed, -3),
                NewPurchase(users.Skier.Id, menu.Id, 2, 37.40m, OrderStatus.Completed, -3),
                NewPurchase(users.SkierSecond.Id, lesson.Id, 1, 31.50m, OrderStatus.Confirmed, -1),
                NewPurchase(users.SkierSecond.Id, skiRental.Id, 1, 30m, OrderStatus.Confirmed, -1),
                NewPurchase(users.SkierThird.Id, servicing.Id, 1, 25m, OrderStatus.Pending, 0));

            await context.SaveChangesAsync(cancellationToken);

            var benefitIds = new[] { skiRental.Id, helmet.Id, menu.Id, lesson.Id, servicing.Id };
            var userIds = new[] { users.Skier.Id, users.SkierSecond.Id, users.SkierThird.Id };

            for (var i = 0; i < 18; i++)
            {
                context.BenefitViews.Add(new BenefitView
                {
                    UserId = userIds[i % userIds.Length],
                    BenefitId = benefitIds[i % benefitIds.Length],
                    ViewedAt = DateTime.UtcNow.AddHours(-i * 5),
                    DurationSeconds = 20 + (i * 7 % 90)
                });
            }

            await context.SaveChangesAsync(cancellationToken);
        }

        if (!await context.Reviews.AnyAsync(cancellationToken))
        {
            var trail = await context.Trails.FirstAsync(t => t.Code == "STAZA-01", cancellationToken);
            var trailSecond = await context.Trails.FirstAsync(t => t.Code == "STAZA-03", cancellationToken);
            var skiRental = await context.Benefits.FirstAsync(b => b.Name == "Iznajmljivanje skija - dnevno", cancellationToken);
            var menu = await context.Benefits.FirstAsync(b => b.Name == "Dnevni meni Vidikovac", cancellationToken);

            context.Reviews.AddRange(
                new Review { UserId = users.Skier.Id, TrailId = trail.Id, TargetType = ReviewTargetType.Trail, Rating = 5, Comment = "Odlicno uredjena staza, idealna za cijelu porodicu." },
                new Review { UserId = users.SkierSecond.Id, TrailId = trail.Id, TargetType = ReviewTargetType.Trail, Rating = 4, Comment = "Guzva u popodnevnim satima, inace sve pohvale." },
                new Review { UserId = users.SkierThird.Id, TrailId = trailSecond.Id, TargetType = ReviewTargetType.Trail, Rating = 4, Comment = "Zahtjevnija staza, ali odlicno pripremljena." },
                new Review { UserId = users.Skier.Id, BenefitId = skiRental.Id, TargetType = ReviewTargetType.Benefit, Rating = 5, Comment = "Oprema je nova i dobro servisirana." },
                new Review { UserId = users.SkierSecond.Id, BenefitId = skiRental.Id, TargetType = ReviewTargetType.Benefit, Rating = 4, Comment = "Brza usluga, ali red ujutro zna biti dug." },
                new Review { UserId = users.Skier.Id, BenefitId = menu.Id, TargetType = ReviewTargetType.Benefit, Rating = 5, Comment = "Domaca hrana i sjajan pogled." },
                new Review { UserId = users.SkierThird.Id, SkiResortId = resort.Id, TargetType = ReviewTargetType.Resort, Rating = 5, Comment = "Sve na jednom mjestu, aplikacija dosta olaksava kupovinu." });

            await context.SaveChangesAsync(cancellationToken);
            await RecalculateBenefitRatingsAsync(context, cancellationToken);
        }

        if (!await context.Notifications.AnyAsync(cancellationToken))
        {
            context.Notifications.AddRange(
                new Notification
                {
                    UserId = users.Skier.Id, Title = "Karte su aktivne",
                    Message = "Vase ski pass karte za narudzbu SP-SEED-0001 su aktivne i spremne za koristenje.",
                    Type = NotificationType.TicketActivated, TargetRoute = "/orders", IsRead = true,
                    ReadAt = DateTime.UtcNow.AddDays(-2)
                },
                new Notification
                {
                    UserId = users.Skier.Id, Title = "Prijava incidenta je rijesena",
                    Message = "Vasa prijava povrede je obradjena. Hvala na prijavi.",
                    Type = NotificationType.IncidentStatusChanged, TargetRoute = "/incidents"
                },
                new Notification
                {
                    UserId = users.SkierSecond.Id, Title = "Placanje je uspjesno",
                    Message = "Placanje narudzbe SP-SEED-0002 je evidentirano.",
                    Type = NotificationType.PaymentCompleted, TargetRoute = "/orders"
                },
                new Notification
                {
                    UserId = users.SkierThird.Id, Title = "Nova obavijest",
                    Message = "Objavljena je nova akcijska ponuda za sedmicne karte.",
                    Type = NotificationType.NewAnnouncement, TargetRoute = "/announcements"
                });

            await context.SaveChangesAsync(cancellationToken);
        }
    }

    private static async Task RecalculateBenefitRatingsAsync(ApplicationDbContext context, CancellationToken cancellationToken)
    {
        var stats = await context.Reviews
            .Where(r => r.BenefitId != null && !r.IsDeleted)
            .GroupBy(r => r.BenefitId!.Value)
            .Select(g => new { BenefitId = g.Key, Count = g.Count(), Average = g.Average(r => (double)r.Rating) })
            .ToListAsync(cancellationToken);

        foreach (var stat in stats)
        {
            var benefit = await context.Benefits.FirstAsync(b => b.Id == stat.BenefitId, cancellationToken);
            benefit.RatingCount = stat.Count;
            benefit.AverageRating = Math.Round(stat.Average, 2);
        }

        await context.SaveChangesAsync(cancellationToken);
    }

    private static Trail NewTrail(
        string name, string code, int length, int drop, int difficultyId, int resortId,
        CrowdLevel crowd, bool nightSkiing = false, bool isOpen = true) => new()
    {
        Name = name,
        Code = code,
        Description = $"Staza {name} duzine {length} metara sa visinskom razlikom od {drop} metara.",
        LengthMeters = length,
        VerticalDropMeters = drop,
        IsOpen = isOpen,
        HasNightSkiing = nightSkiing,
        HasSnowmaking = true,
        EstimatedCrowdLevel = crowd,
        TrailDifficultyId = difficultyId,
        SkiResortId = resortId
    };

    private static SkiLift NewLift(
        string name, string code, int length, int capacity, int duration, int liftTypeId, int resortId,
        int currentRiders = 0, bool isOperational = true) => new()
    {
        Name = name,
        Code = code,
        Description = $"{name} kapaciteta {capacity} korisnika na sat.",
        LengthMeters = length,
        CapacityPerHour = capacity,
        RideDurationMinutes = duration,
        IsOperational = isOperational,
        CurrentRiders = isOperational ? currentRiders : 0,
        LastMaintenanceAt = DateTime.UtcNow.AddDays(-20),
        LiftTypeId = liftTypeId,
        SkiResortId = resortId
    };

    private static Benefit NewBenefit(
        string name, string description, decimal price, decimal discount, string? brand,
        int categoryId, int resortId, int partnerId) => new()
    {
        Name = name,
        Description = description,
        Price = price,
        DiscountPercentage = discount,
        Brand = brand,
        IsActive = true,
        BenefitCategoryId = categoryId,
        SkiResortId = resortId,
        PartnerId = partnerId
    };

    private static SkiPassOrder NewOrder(string orderNumber, int userId, int paymentMethodId, OrderStatus status, DateTime orderDate) => new()
    {
        OrderNumber = orderNumber,
        UserId = userId,
        PaymentMethodId = paymentMethodId,
        Status = status,
        OrderDate = orderDate
    };

    private static SkiPassTicket NewTicket(
        string qrCode, string firstName, string lastName, DateOnly validFrom, int days,
        TicketType ticketType, decimal price, TicketStatus status) => new()
    {
        QrCode = qrCode,
        HolderFirstName = firstName,
        HolderLastName = lastName,
        ValidFrom = validFrom,
        ValidTo = validFrom.AddDays(days - 1),
        NumberOfDays = days,
        Price = price,
        Status = status,
        ActivatedAt = status == TicketStatus.Active ? DateTime.UtcNow.AddDays(-1) : null,
        CancelledAt = status == TicketStatus.Cancelled ? DateTime.UtcNow.AddDays(-9) : null,
        TicketTypeId = ticketType.Id
    };

    private static BenefitPurchase NewPurchase(int userId, int benefitId, int quantity, decimal totalPrice, OrderStatus status, int daysAgo) => new()
    {
        UserId = userId,
        BenefitId = benefitId,
        Quantity = quantity,
        TotalPrice = totalPrice,
        Status = status,
        PurchasedAt = DateTime.UtcNow.AddDays(daysAgo)
    };

    private static Announcement NewAnnouncement(
        string title, string content, int categoryId, int resortId, int userId, bool isUrgent, int daysAgo) => new()
    {
        Title = title,
        Content = content,
        AnnouncementCategoryId = categoryId,
        SkiResortId = resortId,
        CreatedByUserId = userId,
        IsUrgent = isUrgent,
        IsActive = true,
        PublishedAt = DateTime.UtcNow.AddDays(daysAgo)
    };

    private sealed record SeedUsers(
        User Admin,
        User Staff,
        User StaffSecond,
        User Skier,
        User SkierSecond,
        User SkierThird);
}
