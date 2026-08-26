using SkiPass.Application.DTOs.Auth;

namespace SkiPass.Application.Services.Interfaces;

public interface IAuthService
{
    Task<AuthResponseDto> LoginAsync(LoginRequestDto request, CancellationToken cancellationToken = default);
    Task<AuthResponseDto> RegisterAsync(RegisterRequestDto request, CancellationToken cancellationToken = default);
    Task ChangePasswordAsync(int userId, ChangePasswordRequestDto request, CancellationToken cancellationToken = default);

    /// <summary>
    /// Invalidira izdate tokene tako sto rotira sigurnosni pecat korisnika na serveru.
    /// </summary>
    Task LogoutAsync(int userId, CancellationToken cancellationToken = default);

    /// <summary>Generise kod za reset lozinke sa ogranicenim rokom vazenja.</summary>
    Task<ForgotPasswordResponseDto> ForgotPasswordAsync(ForgotPasswordRequestDto request, CancellationToken cancellationToken = default);

    /// <summary>Postavlja novu lozinku na osnovu koda za reset.</summary>
    Task ResetPasswordAsync(ResetPasswordRequestDto request, CancellationToken cancellationToken = default);
}

/// <summary>Podaci o trenutno prijavljenom korisniku, procitani iz JWT tokena.</summary>
public interface ICurrentUserService
{
    int? UserId { get; }
    string? Username { get; }
    string? Role { get; }
    bool IsAuthenticated { get; }
    bool IsAdmin { get; }
    bool IsStaffOrAdmin { get; }

    /// <summary>Vraca identifikator korisnika ili baca izuzetak ako zahtjev nije autentifikovan.</summary>
    int GetRequiredUserId();

    /// <summary>
    /// Osigurava da korisnik pristupa vlastitim podacima. Administratori i osoblje
    /// smiju raditi nad podacima drugih korisnika.
    /// </summary>
    void EnsureCanAccessUser(int targetUserId);
}

/// <summary>Izdavanje JWT tokena za prijavljenog korisnika.</summary>
public interface IJwtTokenService
{
    (string Token, DateTime ExpiresAt) CreateToken(int userId, string username, string email, string role, string securityStamp);
}
