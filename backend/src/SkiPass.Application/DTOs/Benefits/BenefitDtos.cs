using System.ComponentModel.DataAnnotations;
using SkiPass.Application.Common;

namespace SkiPass.Application.DTOs.Benefits;

public class BenefitDto
{
    public int Id { get; set; }
    public string Name { get; set; } = string.Empty;
    public string Description { get; set; } = string.Empty;
    public string? ImageUrl { get; set; }
    public decimal Price { get; set; }
    public decimal DiscountPercentage { get; set; }

    /// <summary>Konacna cijena nakon popusta, izracunata na serveru.</summary>
    public decimal EffectivePrice { get; set; }

    public string? Brand { get; set; }
    public bool IsActive { get; set; }
    public double AverageRating { get; set; }
    public int RatingCount { get; set; }

    public int BenefitCategoryId { get; set; }
    public string BenefitCategoryName { get; set; } = string.Empty;

    public int SkiResortId { get; set; }
    public string SkiResortName { get; set; } = string.Empty;

    public int? PartnerId { get; set; }
    public string? PartnerName { get; set; }

    public int PurchaseCount { get; set; }
}

public class BenefitUpsertDto
{
    [Required(ErrorMessage = "Naziv pogodnosti je obavezan.")]
    [StringLength(150, MinimumLength = 2, ErrorMessage = "Naziv mora imati izmedju 2 i 150 znakova.")]
    public string Name { get; set; } = string.Empty;

    [Required(ErrorMessage = "Opis pogodnosti je obavezan.")]
    [StringLength(2000, MinimumLength = 10, ErrorMessage = "Opis mora imati izmedju 10 i 2000 znakova.")]
    public string Description { get; set; } = string.Empty;

    [StringLength(500, ErrorMessage = "Putanja do slike moze imati najvise 500 znakova.")]
    public string? ImageUrl { get; set; }

    [Range(0.01, 100000, ErrorMessage = "Cijena mora biti izmedju 0.01 i 100000.")]
    public decimal Price { get; set; }

    [Range(0, 100, ErrorMessage = "Popust mora biti izmedju 0 i 100 posto.")]
    public decimal DiscountPercentage { get; set; }

    [StringLength(100, ErrorMessage = "Naziv brenda moze imati najvise 100 znakova.")]
    public string? Brand { get; set; }

    public bool IsActive { get; set; } = true;

    [Range(1, int.MaxValue, ErrorMessage = "Odaberite kategoriju pogodnosti iz padajuce liste.")]
    public int BenefitCategoryId { get; set; }

    [Range(1, int.MaxValue, ErrorMessage = "Odaberite skijaliste iz padajuce liste.")]
    public int SkiResortId { get; set; }

    public int? PartnerId { get; set; }
}

public class BenefitSearchDto : PagedRequest
{
    /// <summary>Pretraga po nazivu, opisu ili brendu pogodnosti.</summary>
    public string? Query { get; set; }
    public int? BenefitCategoryId { get; set; }
    public int? SkiResortId { get; set; }
    public int? PartnerId { get; set; }
    public string? Brand { get; set; }
    public bool? IsActive { get; set; }

    [Range(0, 100000, ErrorMessage = "Minimalna cijena mora biti izmedju 0 i 100000.")]
    public decimal? MinPrice { get; set; }

    [Range(0, 100000, ErrorMessage = "Maksimalna cijena mora biti izmedju 0 i 100000.")]
    public decimal? MaxPrice { get; set; }

    [Range(1, 5, ErrorMessage = "Minimalna ocjena mora biti izmedju 1 i 5.")]
    public double? MinAverageRating { get; set; }
}

public class BenefitPurchaseDto
{
    public int Id { get; set; }
    public DateTime PurchasedAt { get; set; }
    public int Quantity { get; set; }
    public decimal TotalPrice { get; set; }
    public string Status { get; set; } = string.Empty;
    public string? CancellationReason { get; set; }

    public int UserId { get; set; }
    public string UserFullName { get; set; } = string.Empty;

    public int BenefitId { get; set; }
    public string BenefitName { get; set; } = string.Empty;
    public string BenefitCategoryName { get; set; } = string.Empty;
    public string? BenefitImageUrl { get; set; }

    public List<string> AllowedNextStatuses { get; set; } = [];
}

public class BenefitPurchaseCreateDto
{
    [Range(1, int.MaxValue, ErrorMessage = "Odaberite pogodnost iz ponude.")]
    public int BenefitId { get; set; }

    [Range(1, 50, ErrorMessage = "Kolicina mora biti izmedju 1 i 50.")]
    public int Quantity { get; set; } = 1;
}

public class BenefitPurchaseStatusUpdateDto
{
    [Required(ErrorMessage = "Odaberite novi status kupovine.")]
    public string Status { get; set; } = string.Empty;

    [StringLength(500, ErrorMessage = "Razlog moze imati najvise 500 znakova.")]
    public string? CancellationReason { get; set; }
}

public class BenefitPurchaseSearchDto : PagedRequest
{
    /// <summary>Pretraga po nazivu pogodnosti ili imenu korisnika.</summary>
    public string? Query { get; set; }
    public int? UserId { get; set; }
    public int? BenefitId { get; set; }
    public int? BenefitCategoryId { get; set; }
    public string? Status { get; set; }
    public DateTime? PurchasedFrom { get; set; }
    public DateTime? PurchasedTo { get; set; }
}

/// <summary>Evidentiranje pregleda pogodnosti - ulazni signal za sistem preporuke.</summary>
public class BenefitViewCreateDto
{
    [Range(1, int.MaxValue, ErrorMessage = "Odaberite pogodnost cija se posjeta evidentira.")]
    public int BenefitId { get; set; }

    [Range(0, 7200, ErrorMessage = "Trajanje pregleda mora biti izmedju 0 i 7200 sekundi.")]
    public int DurationSeconds { get; set; }
}

public class BenefitViewDto
{
    public int Id { get; set; }
    public DateTime ViewedAt { get; set; }
    public int DurationSeconds { get; set; }
    public int UserId { get; set; }
    public string UserFullName { get; set; } = string.Empty;
    public int BenefitId { get; set; }
    public string BenefitName { get; set; } = string.Empty;
    public string BenefitCategoryName { get; set; } = string.Empty;
}

public class BenefitViewSearchDto : PagedRequest
{
    /// <summary>Pretraga po nazivu pogodnosti ili imenu korisnika.</summary>
    public string? Query { get; set; }
    public int? UserId { get; set; }
    public int? BenefitId { get; set; }
    public DateTime? ViewedFrom { get; set; }
    public DateTime? ViewedTo { get; set; }
}
