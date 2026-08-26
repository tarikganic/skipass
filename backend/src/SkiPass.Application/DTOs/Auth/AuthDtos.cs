using System.ComponentModel.DataAnnotations;

namespace SkiPass.Application.DTOs.Auth;

public class LoginRequestDto
{
    [Required(ErrorMessage = "Korisnicko ime je obavezno.")]
    [StringLength(256, MinimumLength = 3, ErrorMessage = "Korisnicko ime mora imati izmedju 3 i 256 znakova.")]
    public string Username { get; set; } = string.Empty;

    [Required(ErrorMessage = "Lozinka je obavezna.")]
    [StringLength(128, MinimumLength = 4, ErrorMessage = "Lozinka mora imati najmanje 4 znaka.")]
    public string Password { get; set; } = string.Empty;
}

/// <summary>
/// Registracija skijasa. Rola se namjerno ne prima od klijenta - novi korisnik uvijek dobija rolu Skier.
/// </summary>
public class RegisterRequestDto
{
    [Required(ErrorMessage = "Korisnicko ime je obavezno.")]
    [RegularExpression("^[a-zA-Z0-9._-]{3,50}$", ErrorMessage = "Korisnicko ime moze sadrzavati slova, cifre, tacku, crticu i podvlaku (3-50 znakova).")]
    public string Username { get; set; } = string.Empty;

    [Required(ErrorMessage = "Ime je obavezno.")]
    [StringLength(100, MinimumLength = 2, ErrorMessage = "Ime mora imati izmedju 2 i 100 znakova.")]
    public string FirstName { get; set; } = string.Empty;

    [Required(ErrorMessage = "Prezime je obavezno.")]
    [StringLength(100, MinimumLength = 2, ErrorMessage = "Prezime mora imati izmedju 2 i 100 znakova.")]
    public string LastName { get; set; } = string.Empty;

    [Required(ErrorMessage = "E-mail adresa je obavezna.")]
    [EmailAddress(ErrorMessage = "Unesite validnu e-mail adresu u formatu: ime@domena.ba")]
    [StringLength(256, ErrorMessage = "E-mail adresa moze imati najvise 256 znakova.")]
    public string Email { get; set; } = string.Empty;

    [RegularExpression(@"^\+?[0-9\s/-]{6,20}$", ErrorMessage = "Unesite validan broj telefona u formatu: +387 61 123 456")]
    public string? Phone { get; set; }

    public DateTime? BirthDate { get; set; }

    public int? CityId { get; set; }

    [Required(ErrorMessage = "Lozinka je obavezna.")]
    [StringLength(128, MinimumLength = 4, ErrorMessage = "Lozinka mora imati najmanje 4 znaka.")]
    public string Password { get; set; } = string.Empty;

    [Required(ErrorMessage = "Potvrda lozinke je obavezna.")]
    [Compare(nameof(Password), ErrorMessage = "Potvrda lozinke se ne podudara sa unesenom lozinkom.")]
    public string ConfirmPassword { get; set; } = string.Empty;
}

public class AuthResponseDto
{
    public string AccessToken { get; set; } = string.Empty;
    public DateTime ExpiresAt { get; set; }
    public int UserId { get; set; }
    public string Username { get; set; } = string.Empty;
    public string FullName { get; set; } = string.Empty;
    public string Email { get; set; } = string.Empty;
    public string Role { get; set; } = string.Empty;
    public string? ProfileImageUrl { get; set; }
}

public class ChangePasswordRequestDto
{
    [Required(ErrorMessage = "Trenutna lozinka je obavezna.")]
    public string CurrentPassword { get; set; } = string.Empty;

    [Required(ErrorMessage = "Nova lozinka je obavezna.")]
    [StringLength(128, MinimumLength = 4, ErrorMessage = "Nova lozinka mora imati najmanje 4 znaka.")]
    public string NewPassword { get; set; } = string.Empty;

    [Required(ErrorMessage = "Potvrda nove lozinke je obavezna.")]
    [Compare(nameof(NewPassword), ErrorMessage = "Potvrda lozinke se ne podudara sa novom lozinkom.")]
    public string ConfirmNewPassword { get; set; } = string.Empty;
}

/// <summary>
/// Zahtjev za reset lozinke. Odgovor je uvijek isti bez obzira da li e-mail postoji,
/// kako se ne bi otkrivalo koje su adrese registrovane.
/// </summary>
public class ForgotPasswordRequestDto
{
    [Required(ErrorMessage = "E-mail adresa je obavezna.")]
    [EmailAddress(ErrorMessage = "Unesite validnu e-mail adresu u formatu: ime@domena.ba")]
    public string Email { get; set; } = string.Empty;
}

public class ForgotPasswordResponseDto
{
    public string Message { get; set; } = string.Empty;

    /// <summary>
    /// Kod za reset. Popunjava se iskljucivo u razvojnom okruzenju kako bi se tok
    /// mogao testirati bez e-mail servisa; u produkciji ostaje prazan.
    /// </summary>
    public string? DevelopmentToken { get; set; }
}

public class ResetPasswordRequestDto
{
    [Required(ErrorMessage = "E-mail adresa je obavezna.")]
    [EmailAddress(ErrorMessage = "Unesite validnu e-mail adresu u formatu: ime@domena.ba")]
    public string Email { get; set; } = string.Empty;

    [Required(ErrorMessage = "Kod za reset lozinke je obavezan.")]
    public string Token { get; set; } = string.Empty;

    [Required(ErrorMessage = "Nova lozinka je obavezna.")]
    [StringLength(128, MinimumLength = 4, ErrorMessage = "Nova lozinka mora imati najmanje 4 znaka.")]
    public string NewPassword { get; set; } = string.Empty;

    [Required(ErrorMessage = "Potvrda nove lozinke je obavezna.")]
    [Compare(nameof(NewPassword), ErrorMessage = "Potvrda lozinke se ne podudara sa novom lozinkom.")]
    public string ConfirmNewPassword { get; set; } = string.Empty;
}
