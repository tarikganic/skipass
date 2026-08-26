using System.ComponentModel.DataAnnotations;
using SkiPass.Application.Common;

namespace SkiPass.Application.DTOs.Benefits;

public class PartnerDto
{
    public int Id { get; set; }
    public string Name { get; set; } = string.Empty;
    public string? Description { get; set; }
    public string? ContactEmail { get; set; }
    public string? ContactPhone { get; set; }
    public string? Website { get; set; }
    public string? LogoUrl { get; set; }
    public string? Address { get; set; }
    public bool IsActive { get; set; }
    public int? CityId { get; set; }
    public string? CityName { get; set; }
    public int BenefitCount { get; set; }
}

public class PartnerUpsertDto
{
    [Required(ErrorMessage = "Naziv partnera je obavezan.")]
    [StringLength(150, MinimumLength = 2, ErrorMessage = "Naziv mora imati izmedju 2 i 150 znakova.")]
    public string Name { get; set; } = string.Empty;

    [StringLength(2000, ErrorMessage = "Opis moze imati najvise 2000 znakova.")]
    public string? Description { get; set; }

    [EmailAddress(ErrorMessage = "Unesite validnu e-mail adresu u formatu: kontakt@domena.ba")]
    [StringLength(256, ErrorMessage = "E-mail adresa moze imati najvise 256 znakova.")]
    public string? ContactEmail { get; set; }

    [RegularExpression(@"^\+?[0-9\s/-]{6,20}$", ErrorMessage = "Unesite validan broj telefona u formatu: +387 36 123 456")]
    public string? ContactPhone { get; set; }

    [Url(ErrorMessage = "Unesite validnu web adresu u formatu: https://www.domena.ba")]
    [StringLength(500, ErrorMessage = "Web adresa moze imati najvise 500 znakova.")]
    public string? Website { get; set; }

    [StringLength(500, ErrorMessage = "Putanja do logotipa moze imati najvise 500 znakova.")]
    public string? LogoUrl { get; set; }

    [StringLength(300, ErrorMessage = "Adresa moze imati najvise 300 znakova.")]
    public string? Address { get; set; }

    public bool IsActive { get; set; } = true;

    public int? CityId { get; set; }
}

public class PartnerSearchDto : PagedRequest
{
    /// <summary>Pretraga po nazivu, opisu ili adresi partnera.</summary>
    public string? Query { get; set; }
    public int? CityId { get; set; }
    public bool? IsActive { get; set; }
}
