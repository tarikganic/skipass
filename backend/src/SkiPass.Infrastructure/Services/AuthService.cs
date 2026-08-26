using Microsoft.AspNetCore.Identity;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.Logging;
using SkiPass.Application.DTOs.Auth;
using SkiPass.Application.Exceptions;
using SkiPass.Application.Services.Interfaces;
using SkiPass.Domain.Constants;
using SkiPass.Domain.Entities;
using SkiPass.Domain.Enums;
using SkiPass.Domain.Interfaces;
using SkiPass.Infrastructure.Data;

namespace SkiPass.Infrastructure.Services;

public class AuthService : IAuthService
{
    private readonly ApplicationDbContext _context;
    private readonly UserManager<ApplicationUser> _userManager;
    private readonly IJwtTokenService _jwtTokenService;
    private readonly IUnitOfWork _unitOfWork;
    private readonly ILogger<AuthService> _logger;
    private readonly bool _isDevelopment;

    public AuthService(
        ApplicationDbContext context,
        UserManager<ApplicationUser> userManager,
        IJwtTokenService jwtTokenService,
        IUnitOfWork unitOfWork,
        IHostEnvironment environment,
        ILogger<AuthService> logger)
    {
        _context = context;
        _userManager = userManager;
        _jwtTokenService = jwtTokenService;
        _unitOfWork = unitOfWork;
        _logger = logger;
        // Kod za reset se vraca klijentu samo u razvoju, dok e-mail servis ne bude implementiran.
        _isDevelopment = environment.IsDevelopment();
    }

    public async Task<AuthResponseDto> LoginAsync(LoginRequestDto request, CancellationToken cancellationToken = default)
    {
        var identityUser = await _userManager.FindByNameAsync(request.Username);

        // Ista poruka za nepostojeceg korisnika i pogresnu lozinku - klijentu se ne otkriva koji je od dva slucaja.
        if (identityUser is null || !await _userManager.CheckPasswordAsync(identityUser, request.Password))
        {
            _logger.LogWarning("Neuspjesna prijava za korisnicko ime {Username}.", request.Username);
            throw new BusinessException("Korisnicko ime ili lozinka nisu ispravni.");
        }

        var profile = await _context.UserProfiles
            .Include(u => u.City)
            .FirstOrDefaultAsync(u => u.IdentityUserId == identityUser.Id && !u.IsDeleted, cancellationToken)
            ?? throw new BusinessException("Korisnicki profil nije pronadjen.");

        if (!profile.IsActive)
        {
            throw new BusinessException("Korisnicki racun je deaktiviran. Obratite se administratoru skijalista.");
        }

        profile.LastLoginAt = DateTime.UtcNow;
        await _context.SaveChangesAsync(cancellationToken);

        return BuildResponse(profile, identityUser);
    }

    public async Task<AuthResponseDto> RegisterAsync(RegisterRequestDto request, CancellationToken cancellationToken = default)
    {
        if (await _userManager.FindByNameAsync(request.Username) is not null)
        {
            throw new ValidationException(nameof(request.Username), "Korisnicko ime je vec zauzeto.");
        }

        var emailTaken = await _context.UserProfiles
            .AnyAsync(u => u.Email == request.Email && !u.IsDeleted, cancellationToken);
        if (emailTaken)
        {
            throw new ValidationException(nameof(request.Email), "E-mail adresa je vec registrovana.");
        }

        if (request.CityId.HasValue)
        {
            var cityExists = await _context.Cities
                .AnyAsync(c => c.Id == request.CityId.Value && !c.IsDeleted, cancellationToken);
            if (!cityExists)
            {
                throw new ValidationException(nameof(request.CityId), "Odabrani grad ne postoji.");
            }
        }

        await _unitOfWork.BeginTransactionAsync(cancellationToken);
        try
        {
            var identityUser = new ApplicationUser
            {
                UserName = request.Username,
                Email = request.Email,
                PhoneNumber = request.Phone
            };

            var result = await _userManager.CreateAsync(identityUser, request.Password);
            if (!result.Succeeded)
            {
                throw new ValidationException(nameof(request.Password), string.Join(" ", result.Errors.Select(e => e.Description)));
            }

            // Rola se nikada ne prima od klijenta - registracijom se uvijek dobija rola skijasa.
            await _userManager.AddToRoleAsync(identityUser, Roles.Skier);

            var profile = new User
            {
                IdentityUserId = identityUser.Id,
                FirstName = request.FirstName.Trim(),
                LastName = request.LastName.Trim(),
                Email = request.Email.Trim(),
                Phone = request.Phone?.Trim(),
                BirthDate = request.BirthDate,
                CityId = request.CityId,
                Role = UserRole.Skier,
                IsActive = true,
                LastLoginAt = DateTime.UtcNow
            };

            _context.UserProfiles.Add(profile);
            await _context.SaveChangesAsync(cancellationToken);
            await _unitOfWork.CommitTransactionAsync(cancellationToken);

            _logger.LogInformation("Registrovan novi korisnik {UserId}.", profile.Id);
            return BuildResponse(profile, identityUser);
        }
        catch
        {
            await _unitOfWork.RollbackTransactionAsync(cancellationToken);
            throw;
        }
    }

    public async Task ChangePasswordAsync(int userId, ChangePasswordRequestDto request, CancellationToken cancellationToken = default)
    {
        var (profile, identityUser) = await LoadAsync(userId, cancellationToken);

        var result = await _userManager.ChangePasswordAsync(identityUser, request.CurrentPassword, request.NewPassword);
        if (!result.Succeeded)
        {
            throw new ValidationException(nameof(request.CurrentPassword), "Trenutna lozinka nije ispravna.");
        }

        // Promjena lozinke rotira sigurnosni pecat, cime ranije izdati tokeni prestaju vaziti.
        await _userManager.UpdateSecurityStampAsync(identityUser);
        _logger.LogInformation("Korisnik {UserId} je promijenio lozinku.", profile.Id);
    }

    public async Task LogoutAsync(int userId, CancellationToken cancellationToken = default)
    {
        var (_, identityUser) = await LoadAsync(userId, cancellationToken);

        await _userManager.UpdateSecurityStampAsync(identityUser);
        _logger.LogInformation("Korisnik {UserId} se odjavio, token je invalidiran.", userId);
    }

    private async Task<(User Profile, ApplicationUser IdentityUser)> LoadAsync(int userId, CancellationToken cancellationToken)
    {
        var profile = await _context.UserProfiles
            .FirstOrDefaultAsync(u => u.Id == userId && !u.IsDeleted, cancellationToken)
            ?? throw NotFoundException.For("Korisnik", userId);

        if (profile.IdentityUserId is null)
        {
            throw new BusinessException("Korisnicki racun nema povezane kredencijale.");
        }

        var identityUser = await _userManager.FindByIdAsync(profile.IdentityUserId.Value.ToString())
            ?? throw new BusinessException("Korisnicki racun nema povezane kredencijale.");

        return (profile, identityUser);
    }

    private AuthResponseDto BuildResponse(User profile, ApplicationUser identityUser)
    {
        var role = profile.Role.ToString();
        var (token, expiresAt) = _jwtTokenService.CreateToken(
            profile.Id,
            identityUser.UserName ?? profile.Email,
            profile.Email,
            role,
            identityUser.SecurityStamp ?? string.Empty);

        return new AuthResponseDto
        {
            AccessToken = token,
            ExpiresAt = expiresAt,
            UserId = profile.Id,
            Username = identityUser.UserName ?? profile.Email,
            FullName = $"{profile.FirstName} {profile.LastName}",
            Email = profile.Email,
            Role = role,
            ProfileImageUrl = profile.ProfileImageUrl
        };
    }

    /// <summary>
    /// Generise kod za reset lozinke. Koristi se ASP.NET Identity token provider,
    /// pa se kod nigdje ne cuva u citljivom obliku i ima definisan rok vazenja.
    /// Sam kod ce u narednoj fazi slati pomocni servis putem e-maila.
    /// </summary>
    public async Task<ForgotPasswordResponseDto> ForgotPasswordAsync(ForgotPasswordRequestDto request, CancellationToken cancellationToken = default)
    {
        // Poruka je uvijek ista kako se ne bi otkrivalo koje su adrese registrovane.
        var response = new ForgotPasswordResponseDto
        {
            Message = "Ako je adresa registrovana, poslali smo kod za reset lozinke."
        };

        var profile = await _context.UserProfiles
            .FirstOrDefaultAsync(u => u.Email == request.Email && !u.IsDeleted && u.IsActive, cancellationToken);

        if (profile?.IdentityUserId is null)
        {
            _logger.LogInformation("Zatrazen reset lozinke za nepostojecu adresu.");
            return response;
        }

        var identityUser = await _userManager.FindByIdAsync(profile.IdentityUserId.Value.ToString());
        if (identityUser is null)
        {
            return response;
        }

        var token = await _userManager.GeneratePasswordResetTokenAsync(identityUser);
        _logger.LogInformation("Generisan kod za reset lozinke korisnika {UserId}.", profile.Id);

        if (_isDevelopment)
        {
            response.DevelopmentToken = token;
        }

        return response;
    }

    public async Task ResetPasswordAsync(ResetPasswordRequestDto request, CancellationToken cancellationToken = default)
    {
        var profile = await _context.UserProfiles
            .FirstOrDefaultAsync(u => u.Email == request.Email && !u.IsDeleted && u.IsActive, cancellationToken);

        if (profile?.IdentityUserId is null)
        {
            throw new ValidationException(nameof(request.Token), "Kod za reset lozinke nije ispravan ili je istekao.");
        }

        var identityUser = await _userManager.FindByIdAsync(profile.IdentityUserId.Value.ToString())
            ?? throw new ValidationException(nameof(request.Token), "Kod za reset lozinke nije ispravan ili je istekao.");

        var result = await _userManager.ResetPasswordAsync(identityUser, request.Token, request.NewPassword);
        if (!result.Succeeded)
        {
            throw new ValidationException(nameof(request.Token), "Kod za reset lozinke nije ispravan ili je istekao.");
        }

        // Reset lozinke rotira sigurnosni pecat i time ponistava sve ranije izdate tokene.
        await _userManager.UpdateSecurityStampAsync(identityUser);
        _logger.LogInformation("Korisnik {UserId} je resetovao lozinku.", profile.Id);
    }
}
