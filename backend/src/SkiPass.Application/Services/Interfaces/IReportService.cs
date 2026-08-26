using SkiPass.Application.DTOs.Reports;

namespace SkiPass.Application.Services.Interfaces;

/// <summary>
/// Agregatni izvjestaji za desktop administraciju. Svaki izvjestaj se racuna jednim
/// GroupBy upitom nad bazom, bez ucitavanja pojedinacnih zapisa u memoriju.
/// </summary>
public interface IReportService
{
    Task<SalesReportDto> GetSalesByDayAsync(SalesReportRequestDto request, CancellationToken cancellationToken = default);

    Task<TopUsersReportDto> GetTopUsersAsync(int top, CancellationToken cancellationToken = default);
}
