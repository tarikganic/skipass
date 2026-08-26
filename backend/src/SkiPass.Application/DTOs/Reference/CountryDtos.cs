using System.ComponentModel.DataAnnotations;
using SkiPass.Application.Common;

namespace SkiPass.Application.DTOs.Reference;

public class CountryDto
{
    public int Id { get; set; }
    public string Name { get; set; } = string.Empty;
    public string IsoCode { get; set; } = string.Empty;
    public int CityCount { get; set; }
}

public class CountryUpsertDto
{
    [Required(ErrorMessage = "Naziv drzave je obavezan.")]
    [StringLength(100, MinimumLength = 2, ErrorMessage = "Naziv drzave mora imati izmedju 2 i 100 znakova.")]
    public string Name { get; set; } = string.Empty;

    [Required(ErrorMessage = "ISO oznaka je obavezna.")]
    [RegularExpression("^[A-Z]{2,3}$", ErrorMessage = "ISO oznaka mora sadrzavati 2 ili 3 velika slova, npr. BA ili BIH.")]
    public string IsoCode { get; set; } = string.Empty;
}

public class CountrySearchDto : PagedRequest
{
    /// <summary>Pretraga po nazivu ili ISO oznaci drzave.</summary>
    public string? Query { get; set; }
}
