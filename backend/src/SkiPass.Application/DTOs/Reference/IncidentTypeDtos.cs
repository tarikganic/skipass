using System.ComponentModel.DataAnnotations;
using SkiPass.Application.Common;

namespace SkiPass.Application.DTOs.Reference;

public class IncidentTypeDto
{
    public int Id { get; set; }
    public string Name { get; set; } = string.Empty;
    public string? Description { get; set; }
    public bool IsUrgentByDefault { get; set; }
    public int IncidentCount { get; set; }
}

public class IncidentTypeUpsertDto
{
    [Required(ErrorMessage = "Naziv tipa incidenta je obavezan.")]
    [StringLength(100, MinimumLength = 2, ErrorMessage = "Naziv mora imati izmedju 2 i 100 znakova.")]
    public string Name { get; set; } = string.Empty;

    [StringLength(300, ErrorMessage = "Opis moze imati najvise 300 znakova.")]
    public string? Description { get; set; }

    public bool IsUrgentByDefault { get; set; }
}

public class IncidentTypeSearchDto : PagedRequest
{
    /// <summary>Pretraga po nazivu tipa incidenta.</summary>
    public string? Query { get; set; }
    public bool? IsUrgentByDefault { get; set; }
}
