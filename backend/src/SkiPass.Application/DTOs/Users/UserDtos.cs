using System.ComponentModel.DataAnnotations;
using SkiPass.Application.Common;

namespace SkiPass.Application.DTOs.Users;

public class UserDto
{
    public int Id { get; set; }
    public string Username { get; set; } = string.Empty;
    public string FirstName { get; set; } = string.Empty;
    public string LastName { get; set; } = string.Empty;
    public string FullName { get; set; } = string.Empty;
    public string Email { get; set; } = string.Empty;
    public string? Phone { get; set; }
    public DateTime? BirthDate { get; set; }
    public string? ProfileImageUrl { get; set; }
    public string Role { get; set; } = string.Empty;
    public bool IsActive { get; set; }
    public DateTime? LastLoginAt { get; set; }
    public int? CityId { get; set; }
    public string? CityName { get; set; }
    public DateTime CreatedAt { get; set; }
    public int OrderCount { get; set; }
}

/// <summary>Kreiranje korisnika iz desktop administracije - rola se bira eksplicitno.</summary>
public class UserCreateDto
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
    public string Email { get; set; } = string.Empty;

    [RegularExpression(@"^\+?[0-9\s/-]{6,20}$", ErrorMessage = "Unesite validan broj telefona u formatu: +387 61 123 456")]
    public string? Phone { get; set; }

    public DateTime? BirthDate { get; set; }

    [StringLength(500, ErrorMessage = "Putanja do slike moze imati najvise 500 znakova.")]
    public string? ProfileImageUrl { get; set; }

    public int? CityId { get; set; }

    [Required(ErrorMessage = "Odaberite rolu korisnika.")]
    public string Role { get; set; } = string.Empty;

    public bool IsActive { get; set; } = true;

    [Required(ErrorMessage = "Lozinka je obavezna.")]
    [StringLength(128, MinimumLength = 4, ErrorMessage = "Lozinka mora imati najmanje 4 znaka.")]
    public string Password { get; set; } = string.Empty;

    [Required(ErrorMessage = "Potvrda lozinke je obavezna.")]
    [Compare(nameof(Password), ErrorMessage = "Potvrda lozinke se ne podudara sa unesenom lozinkom.")]
    public string ConfirmPassword { get; set; } = string.Empty;
}

/// <summary>
/// Izmjena korisnika iz administracije. Lozinka se ne trazi pri uredjivanju -
/// mijenja se samo ako je polje za novu lozinku popunjeno.
/// </summary>
public class UserUpdateDto
{
    [Required(ErrorMessage = "Ime je obavezno.")]
    [StringLength(100, MinimumLength = 2, ErrorMessage = "Ime mora imati izmedju 2 i 100 znakova.")]
    public string FirstName { get; set; } = string.Empty;

    [Required(ErrorMessage = "Prezime je obavezno.")]
    [StringLength(100, MinimumLength = 2, ErrorMessage = "Prezime mora imati izmedju 2 i 100 znakova.")]
    public string LastName { get; set; } = string.Empty;

    [Required(ErrorMessage = "E-mail adresa je obavezna.")]
    [EmailAddress(ErrorMessage = "Unesite validnu e-mail adresu u formatu: ime@domena.ba")]
    public string Email { get; set; } = string.Empty;

    [RegularExpression(@"^\+?[0-9\s/-]{6,20}$", ErrorMessage = "Unesite validan broj telefona u formatu: +387 61 123 456")]
    public string? Phone { get; set; }

    public DateTime? BirthDate { get; set; }

    [StringLength(500, ErrorMessage = "Putanja do slike moze imati najvise 500 znakova.")]
    public string? ProfileImageUrl { get; set; }

    public int? CityId { get; set; }

    [Required(ErrorMessage = "Odaberite rolu korisnika.")]
    public string Role { get; set; } = string.Empty;

    public bool IsActive { get; set; } = true;

    /// <summary>Nova lozinka. Ostavite prazno ako se lozinka ne mijenja.</summary>
    [StringLength(128, MinimumLength = 4, ErrorMessage = "Nova lozinka mora imati najmanje 4 znaka.")]
    public string? NewPassword { get; set; }

    [Compare(nameof(NewPassword), ErrorMessage = "Potvrda lozinke se ne podudara sa novom lozinkom.")]
    public string? ConfirmNewPassword { get; set; }
}

/// <summary>Izmjena vlastitog profila iz mobilne aplikacije - rola i status se ne mogu mijenjati.</summary>
public class UserProfileUpdateDto
{
    [Required(ErrorMessage = "Ime je obavezno.")]
    [StringLength(100, MinimumLength = 2, ErrorMessage = "Ime mora imati izmedju 2 i 100 znakova.")]
    public string FirstName { get; set; } = string.Empty;

    [Required(ErrorMessage = "Prezime je obavezno.")]
    [StringLength(100, MinimumLength = 2, ErrorMessage = "Prezime mora imati izmedju 2 i 100 znakova.")]
    public string LastName { get; set; } = string.Empty;

    [Required(ErrorMessage = "E-mail adresa je obavezna.")]
    [EmailAddress(ErrorMessage = "Unesite validnu e-mail adresu u formatu: ime@domena.ba")]
    public string Email { get; set; } = string.Empty;

    [RegularExpression(@"^\+?[0-9\s/-]{6,20}$", ErrorMessage = "Unesite validan broj telefona u formatu: +387 61 123 456")]
    public string? Phone { get; set; }

    public DateTime? BirthDate { get; set; }

    [StringLength(500, ErrorMessage = "Putanja do slike moze imati najvise 500 znakova.")]
    public string? ProfileImageUrl { get; set; }

    public int? CityId { get; set; }
}

public class UserSearchDto : PagedRequest
{
    /// <summary>Pretraga po imenu, prezimenu, e-mailu ili korisnickom imenu.</summary>
    public string? Query { get; set; }
    public string? Role { get; set; }
    public bool? IsActive { get; set; }
    public int? CityId { get; set; }
}
