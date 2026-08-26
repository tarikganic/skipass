using System.ComponentModel.DataAnnotations;
using SkiPass.Application.Common;

namespace SkiPass.Application.DTOs.Reference;

public class BenefitCategoryDto
{
    public int Id { get; set; }
    public string Name { get; set; } = string.Empty;
    public string? Description { get; set; }
    public string? IconName { get; set; }
    public int BenefitCount { get; set; }
}

public class BenefitCategoryUpsertDto
{
    [Required(ErrorMessage = "Naziv kategorije je obavezan.")]
    [StringLength(100, MinimumLength = 2, ErrorMessage = "Naziv mora imati izmedju 2 i 100 znakova.")]
    public string Name { get; set; } = string.Empty;

    [StringLength(300, ErrorMessage = "Opis moze imati najvise 300 znakova.")]
    public string? Description { get; set; }

    [StringLength(50, ErrorMessage = "Naziv ikone moze imati najvise 50 znakova.")]
    public string? IconName { get; set; }
}

public class BenefitCategorySearchDto : PagedRequest
{
    /// <summary>Pretraga po nazivu kategorije pogodnosti.</summary>
    public string? Query { get; set; }
}
