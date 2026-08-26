using System.ComponentModel.DataAnnotations;
using SkiPass.Application.Common;

namespace SkiPass.Application.DTOs.Reference;

public class AnnouncementCategoryDto
{
    public int Id { get; set; }
    public string Name { get; set; } = string.Empty;
    public string? Description { get; set; }
    public int AnnouncementCount { get; set; }
}

public class AnnouncementCategoryUpsertDto
{
    [Required(ErrorMessage = "Naziv kategorije obavijesti je obavezan.")]
    [StringLength(100, MinimumLength = 2, ErrorMessage = "Naziv mora imati izmedju 2 i 100 znakova.")]
    public string Name { get; set; } = string.Empty;

    [StringLength(300, ErrorMessage = "Opis moze imati najvise 300 znakova.")]
    public string? Description { get; set; }
}

public class AnnouncementCategorySearchDto : PagedRequest
{
    /// <summary>Pretraga po nazivu kategorije obavijesti.</summary>
    public string? Query { get; set; }
}
