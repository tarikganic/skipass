using System.ComponentModel.DataAnnotations;
using SkiPass.Application.Common;

namespace SkiPass.Application.DTOs.Reference;

public class LiftTypeDto
{
    public int Id { get; set; }
    public string Name { get; set; } = string.Empty;
    public string? Description { get; set; }
    public int SkiLiftCount { get; set; }
}

public class LiftTypeUpsertDto
{
    [Required(ErrorMessage = "Naziv tipa lifta je obavezan.")]
    [StringLength(80, MinimumLength = 2, ErrorMessage = "Naziv mora imati izmedju 2 i 80 znakova.")]
    public string Name { get; set; } = string.Empty;

    [StringLength(300, ErrorMessage = "Opis moze imati najvise 300 znakova.")]
    public string? Description { get; set; }
}

public class LiftTypeSearchDto : PagedRequest
{
    /// <summary>Pretraga po nazivu tipa lifta.</summary>
    public string? Query { get; set; }
}
