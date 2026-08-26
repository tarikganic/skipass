using System.ComponentModel.DataAnnotations;
using SkiPass.Application.Common;

namespace SkiPass.Application.DTOs.Reference;

public class CityDto
{
    public int Id { get; set; }
    public string Name { get; set; } = string.Empty;
    public string? PostalCode { get; set; }
    public int CountryId { get; set; }
    public string CountryName { get; set; } = string.Empty;
}

public class CityUpsertDto
{
    [Required(ErrorMessage = "Naziv grada je obavezan.")]
    [StringLength(100, MinimumLength = 2, ErrorMessage = "Naziv grada mora imati izmedju 2 i 100 znakova.")]
    public string Name { get; set; } = string.Empty;

    [RegularExpression("^[0-9]{5}$", ErrorMessage = "Postanski broj mora sadrzavati tacno 5 cifara, npr. 88000.")]
    public string? PostalCode { get; set; }

    [Range(1, int.MaxValue, ErrorMessage = "Odaberite drzavu iz padajuce liste.")]
    public int CountryId { get; set; }
}

public class CitySearchDto : PagedRequest
{
    /// <summary>Pretraga po nazivu grada ili postanskom broju.</summary>
    public string? Query { get; set; }
    public int? CountryId { get; set; }
}
