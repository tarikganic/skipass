using System.ComponentModel.DataAnnotations;
using SkiPass.Application.Common;

namespace SkiPass.Application.DTOs.Reference;

public class TrailDifficultyDto
{
    public int Id { get; set; }
    public string Name { get; set; } = string.Empty;
    public string? Description { get; set; }
    public string ColorHex { get; set; } = string.Empty;
    public int SortOrder { get; set; }
    public int TrailCount { get; set; }
}

public class TrailDifficultyUpsertDto
{
    [Required(ErrorMessage = "Naziv tezine staze je obavezan.")]
    [StringLength(50, MinimumLength = 2, ErrorMessage = "Naziv mora imati izmedju 2 i 50 znakova.")]
    public string Name { get; set; } = string.Empty;

    [StringLength(300, ErrorMessage = "Opis moze imati najvise 300 znakova.")]
    public string? Description { get; set; }

    [Required(ErrorMessage = "Boja oznake je obavezna.")]
    [RegularExpression("^#(?:[0-9a-fA-F]{3}|[0-9a-fA-F]{6})$", ErrorMessage = "Boja mora biti u HEX formatu, npr. #1E88E5.")]
    public string ColorHex { get; set; } = string.Empty;

    [Range(0, 100, ErrorMessage = "Redoslijed prikaza mora biti izmedju 0 i 100.")]
    public int SortOrder { get; set; }
}

public class TrailDifficultySearchDto : PagedRequest
{
    /// <summary>Pretraga po nazivu tezine staze.</summary>
    public string? Query { get; set; }
}
