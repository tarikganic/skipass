using Microsoft.EntityFrameworkCore;
using SkiPass.Application.DTOs.Reports;
using SkiPass.Application.Exceptions;
using SkiPass.Application.Services.Interfaces;
using SkiPass.Domain.Enums;
using SkiPass.Infrastructure.Data;

namespace SkiPass.Infrastructure.Services;

/// <summary>
/// Agregatni izvjestaji za sekciju Izvjestaji u desktop administraciji.
/// Svaki izvjestaj se racuna jednim GroupBy upitom, u skladu sa zahtjevom da se
/// agregacije ne rade kroz vise odvojenih upita niti ucitavanjem svih zapisa u memoriju.
/// </summary>
public class ReportService : IReportService
{
    private const int MaxRangeDays = 366;

    private readonly ApplicationDbContext _context;

    public ReportService(ApplicationDbContext context)
    {
        _context = context;
    }

    public async Task<SalesReportDto> GetSalesByDayAsync(SalesReportRequestDto request, CancellationToken cancellationToken = default)
    {
        if (request.DateTo < request.DateFrom)
        {
            throw new ValidationException(nameof(request.DateTo), "Krajnji datum mora biti nakon pocetnog datuma.");
        }

        if (request.DateTo.DayNumber - request.DateFrom.DayNumber > MaxRangeDays)
        {
            throw new ValidationException(nameof(request.DateTo), $"Raspon izvjestaja ne moze biti duzi od {MaxRangeDays} dana.");
        }

        var fromUtc = request.DateFrom.ToDateTime(TimeOnly.MinValue);
        var toUtcExclusive = request.DateTo.AddDays(1).ToDateTime(TimeOnly.MinValue);

        var query = _context.SkiPassTickets
            .Where(t => !t.IsDeleted && t.Status != TicketStatus.Cancelled)
            .Where(t => t.CreatedAt >= fromUtc && t.CreatedAt < toUtcExclusive);

        if (request.SkiResortId.HasValue)
        {
            query = query.Where(t => t.TicketType.SkiResortId == request.SkiResortId.Value);
        }

        var rows = await query
            .GroupBy(t => t.CreatedAt.Date)
            .Select(g => new { Date = g.Key, Count = g.Count(), Revenue = g.Sum(t => t.Price) })
            .ToListAsync(cancellationToken);

        var byDate = rows.ToDictionary(r => DateOnly.FromDateTime(r.Date), r => r);

        // Dani bez prodaje se popunjavaju nulama kako bi graf ostao neprekinut.
        var days = new List<SalesByDayDto>();
        for (var date = request.DateFrom; date <= request.DateTo; date = date.AddDays(1))
        {
            byDate.TryGetValue(date, out var row);
            days.Add(new SalesByDayDto
            {
                Date = date,
                TicketCount = row?.Count ?? 0,
                Revenue = row?.Revenue ?? 0
            });
        }

        return new SalesReportDto
        {
            DateFrom = request.DateFrom,
            DateTo = request.DateTo,
            TotalTicketCount = days.Sum(d => d.TicketCount),
            TotalRevenue = days.Sum(d => d.Revenue),
            Days = days
        };
    }

    public async Task<TopUsersReportDto> GetTopUsersAsync(int top, CancellationToken cancellationToken = default)
    {
        var clampedTop = Math.Clamp(top, 1, 50);

        var aggregates = await _context.SkiPassTickets
            .Where(t => !t.IsDeleted && t.Status != TicketStatus.Cancelled)
            .GroupBy(t => t.SkiPassOrder.UserId)
            .Select(g => new { UserId = g.Key, Count = g.Count(), Total = g.Sum(t => t.Price) })
            .OrderByDescending(g => g.Count)
            .ThenByDescending(g => g.Total)
            .Take(clampedTop)
            .ToListAsync(cancellationToken);

        var userIds = aggregates.Select(a => a.UserId).ToList();

        var users = await _context.UserProfiles
            .Where(u => userIds.Contains(u.Id))
            .Select(u => new { u.Id, FullName = u.FirstName + " " + u.LastName, u.Email })
            .ToDictionaryAsync(u => u.Id, cancellationToken);

        var result = aggregates
            .Where(a => users.ContainsKey(a.UserId))
            .Select(a => new TopUserDto
            {
                UserId = a.UserId,
                FullName = users[a.UserId].FullName,
                Email = users[a.UserId].Email,
                TicketCount = a.Count,
                TotalSpent = a.Total
            })
            .ToList();

        return new TopUsersReportDto { Top = clampedTop, Users = result };
    }
}
