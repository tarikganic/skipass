using System.ComponentModel.DataAnnotations;

namespace SkiPass.Application.DTOs.Reports;

/// <summary>Zahtjev za izvjestaj prodaje po danima. Raspon datuma je parametar pretrage.</summary>
public class SalesReportRequestDto
{
    [Required(ErrorMessage = "Pocetni datum je obavezan.")]
    public DateOnly DateFrom { get; set; }

    [Required(ErrorMessage = "Krajnji datum je obavezan.")]
    public DateOnly DateTo { get; set; }

    public int? SkiResortId { get; set; }
}

/// <summary>Jedan red grafa prodaje - broj prodatih karata i ostvareni prihod za jedan dan.</summary>
public class SalesByDayDto
{
    public DateOnly Date { get; set; }
    public int TicketCount { get; set; }
    public decimal Revenue { get; set; }
}

public class SalesReportDto
{
    public DateOnly DateFrom { get; set; }
    public DateOnly DateTo { get; set; }
    public int TotalTicketCount { get; set; }
    public decimal TotalRevenue { get; set; }
    public List<SalesByDayDto> Days { get; set; } = [];
}

/// <summary>
/// Jedan red izvjestaja o najboljim korisnicima. Prikaz top 5 korisnika je primjer
/// iz uputa gdje pretraga nije potrebna jer je obim rezultata unaprijed odredjen.
/// </summary>
public class TopUserDto
{
    public int UserId { get; set; }
    public string FullName { get; set; } = string.Empty;
    public string Email { get; set; } = string.Empty;
    public int TicketCount { get; set; }
    public decimal TotalSpent { get; set; }
}

public class TopUsersReportDto
{
    public int Top { get; set; }
    public List<TopUserDto> Users { get; set; } = [];
}
