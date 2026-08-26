using System.ComponentModel.DataAnnotations;
using SkiPass.Application.Common;

namespace SkiPass.Application.DTOs.Lifts;

public class SkiLiftDto
{
    public int Id { get; set; }
    public string Name { get; set; } = string.Empty;
    public string Code { get; set; } = string.Empty;
    public string? Description { get; set; }
    public int LengthMeters { get; set; }
    public int CapacityPerHour { get; set; }
    public int RideDurationMinutes { get; set; }
    public bool IsOperational { get; set; }
    public int CurrentRiders { get; set; }
    public DateTime? LastMaintenanceAt { get; set; }

    public int SkiResortId { get; set; }
    public string SkiResortName { get; set; } = string.Empty;

    public int LiftTypeId { get; set; }
    public string LiftTypeName { get; set; } = string.Empty;

    /// <summary>Broj otvorenih kvarova koji jos nisu rijeseni.</summary>
    public int OpenMaintenanceCount { get; set; }
}

public class SkiLiftUpsertDto
{
    [Required(ErrorMessage = "Naziv lifta je obavezan.")]
    [StringLength(150, MinimumLength = 2, ErrorMessage = "Naziv lifta mora imati izmedju 2 i 150 znakova.")]
    public string Name { get; set; } = string.Empty;

    [Required(ErrorMessage = "Oznaka lifta je obavezna.")]
    [RegularExpression("^[A-Z0-9-]{2,20}$", ErrorMessage = "Oznaka lifta moze sadrzavati velika slova, cifre i crticu, npr. LIFT-01.")]
    public string Code { get; set; } = string.Empty;

    [StringLength(1000, ErrorMessage = "Opis moze imati najvise 1000 znakova.")]
    public string? Description { get; set; }

    [Range(50, 20000, ErrorMessage = "Duzina lifta mora biti izmedju 50 i 20000 metara.")]
    public int LengthMeters { get; set; }

    [Range(1, 10000, ErrorMessage = "Kapacitet mora biti izmedju 1 i 10000 korisnika na sat.")]
    public int CapacityPerHour { get; set; }

    [Range(1, 120, ErrorMessage = "Trajanje voznje mora biti izmedju 1 i 120 minuta.")]
    public int RideDurationMinutes { get; set; }

    public bool IsOperational { get; set; } = true;

    [Range(1, int.MaxValue, ErrorMessage = "Odaberite skijaliste iz padajuce liste.")]
    public int SkiResortId { get; set; }

    [Range(1, int.MaxValue, ErrorMessage = "Odaberite tip lifta iz padajuce liste.")]
    public int LiftTypeId { get; set; }
}

/// <summary>Brza promjena statusa rada lifta iz administracije.</summary>
public class SkiLiftStatusUpdateDto
{
    public bool IsOperational { get; set; }
}

public class SkiLiftSearchDto : PagedRequest
{
    /// <summary>Pretraga po nazivu, oznaci ili opisu lifta.</summary>
    public string? Query { get; set; }
    public int? SkiResortId { get; set; }
    public int? LiftTypeId { get; set; }
    public bool? IsOperational { get; set; }
}

public class LiftMaintenanceRecordDto
{
    public int Id { get; set; }
    public DateTime ReportedAt { get; set; }
    public DateTime? ResolvedAt { get; set; }
    public string Description { get; set; } = string.Empty;
    public string? ResolutionNote { get; set; }
    public string Status { get; set; } = string.Empty;
    public bool RequiresShutdown { get; set; }

    public int SkiLiftId { get; set; }
    public string SkiLiftName { get; set; } = string.Empty;

    public int ReportedByUserId { get; set; }
    public string ReportedByUserName { get; set; } = string.Empty;

    public int? ResolvedByUserId { get; set; }
    public string? ResolvedByUserName { get; set; }

    /// <summary>Statusi u koje zapis moze preci - klijent na osnovu njih onemogucava nedostupne akcije.</summary>
    public List<string> AllowedNextStatuses { get; set; } = [];
}

public class LiftMaintenanceRecordCreateDto
{
    [Range(1, int.MaxValue, ErrorMessage = "Odaberite ski lift iz padajuce liste.")]
    public int SkiLiftId { get; set; }

    [Required(ErrorMessage = "Opis kvara je obavezan.")]
    [StringLength(1000, MinimumLength = 5, ErrorMessage = "Opis kvara mora imati izmedju 5 i 1000 znakova.")]
    public string Description { get; set; } = string.Empty;

    /// <summary>Ako je oznaceno, lift se automatski stavlja van pogona.</summary>
    public bool RequiresShutdown { get; set; }
}

public class LiftMaintenanceStatusUpdateDto
{
    [Required(ErrorMessage = "Odaberite novi status kvara.")]
    public string Status { get; set; } = string.Empty;

    /// <summary>Obrazlozenje. Obavezno pri zatvaranju ili otkazivanju zapisa o kvaru.</summary>
    [StringLength(1000, ErrorMessage = "Obrazlozenje moze imati najvise 1000 znakova.")]
    public string? ResolutionNote { get; set; }
}

public class LiftMaintenanceSearchDto : PagedRequest
{
    /// <summary>Pretraga po opisu kvara ili obrazlozenju.</summary>
    public string? Query { get; set; }
    public int? SkiLiftId { get; set; }
    public int? SkiResortId { get; set; }
    public string? Status { get; set; }
    public bool? RequiresShutdown { get; set; }
    public DateTime? ReportedFrom { get; set; }
    public DateTime? ReportedTo { get; set; }
}
