using SkiPass.Application.DTOs.Home;

namespace SkiPass.Application.Services.Interfaces;

public interface IHomeService
{
    /// <summary>Objedinjeni prikaz za pocetnu stranicu mobilne aplikacije.</summary>
    Task<HomeSummaryDto> GetSummaryAsync(int userId, int? skiResortId, CancellationToken cancellationToken = default);
}
