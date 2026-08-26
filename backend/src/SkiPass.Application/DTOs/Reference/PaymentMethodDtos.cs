using System.ComponentModel.DataAnnotations;
using SkiPass.Application.Common;

namespace SkiPass.Application.DTOs.Reference;

public class PaymentMethodDto
{
    public int Id { get; set; }
    public string Name { get; set; } = string.Empty;
    public string Code { get; set; } = string.Empty;
    public bool IsOnline { get; set; }
    public bool IsActive { get; set; }
    public int OrderCount { get; set; }
}

public class PaymentMethodUpsertDto
{
    [Required(ErrorMessage = "Naziv nacina placanja je obavezan.")]
    [StringLength(80, MinimumLength = 2, ErrorMessage = "Naziv mora imati izmedju 2 i 80 znakova.")]
    public string Name { get; set; } = string.Empty;

    [Required(ErrorMessage = "Oznaka nacina placanja je obavezna.")]
    [RegularExpression("^[A-Z0-9_]{2,30}$", ErrorMessage = "Oznaka moze sadrzavati samo velika slova, cifre i podvlaku, npr. PAYPAL.")]
    public string Code { get; set; } = string.Empty;

    public bool IsOnline { get; set; }
    public bool IsActive { get; set; } = true;
}

public class PaymentMethodSearchDto : PagedRequest
{
    /// <summary>Pretraga po nazivu ili oznaci nacina placanja.</summary>
    public string? Query { get; set; }
    public bool? IsActive { get; set; }
    public bool? IsOnline { get; set; }
}
