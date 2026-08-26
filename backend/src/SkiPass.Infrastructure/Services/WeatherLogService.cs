using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;
using SkiPass.Application.DTOs.Weather;
using SkiPass.Application.Exceptions;
using SkiPass.Application.Services.Interfaces;
using SkiPass.Domain.Entities;
using SkiPass.Infrastructure.Data;

namespace SkiPass.Infrastructure.Services;

public class WeatherLogService
    : CrudServiceBase<WeatherLog, WeatherLogDto, WeatherLogUpsertDto, WeatherLogSearchDto>, IWeatherLogService
{
    public WeatherLogService(ApplicationDbContext context, ILogger<WeatherLogService> logger)
        : base(context, logger)
    {
    }

    protected override string EntityName => "Vremenski uslovi";

    protected override IQueryable<WeatherLog> BaseQuery() => Context.WeatherLogs.Include(w => w.SkiResort);

    protected override IQueryable<WeatherLog> ApplyFilters(IQueryable<WeatherLog> query, WeatherLogSearchDto request)
    {
        if (!string.IsNullOrWhiteSpace(request.Query))
        {
            var term = request.Query.Trim();
            query = query.Where(w => w.Conditions.Contains(term) || w.SkiResort.Name.Contains(term));
        }

        if (request.SkiResortId.HasValue)
        {
            query = query.Where(w => w.SkiResortId == request.SkiResortId.Value);
        }

        if (request.RecordedFrom.HasValue)
        {
            query = query.Where(w => w.RecordedAt >= request.RecordedFrom.Value);
        }

        if (request.RecordedTo.HasValue)
        {
            query = query.Where(w => w.RecordedAt <= request.RecordedTo.Value);
        }

        return query;
    }

    protected override IQueryable<WeatherLog> ApplyDefaultSort(IQueryable<WeatherLog> query) =>
        query.OrderByDescending(w => w.RecordedAt);

    protected override WeatherLogDto MapToDto(WeatherLog e) => new()
    {
        Id = e.Id,
        RecordedAt = e.RecordedAt,
        TemperatureCelsius = e.TemperatureCelsius,
        WindSpeedKmh = e.WindSpeedKmh,
        SnowfallCm = e.SnowfallCm,
        SnowDepthCm = e.SnowDepthCm,
        Conditions = e.Conditions,
        VisibilityMeters = e.VisibilityMeters,
        SkiResortId = e.SkiResortId,
        SkiResortName = e.SkiResort.Name
    };

    protected override async Task MapAsync(WeatherLog entity, WeatherLogUpsertDto dto, CancellationToken cancellationToken)
    {
        var resortExists = await Context.SkiResorts
            .AnyAsync(r => r.Id == dto.SkiResortId && !r.IsDeleted, cancellationToken);
        if (!resortExists)
        {
            throw new ValidationException(nameof(dto.SkiResortId), "Odabrano skijaliste ne postoji.");
        }

        if (dto.RecordedAt > DateTime.UtcNow.AddHours(1))
        {
            throw new ValidationException(nameof(dto.RecordedAt), "Datum mjerenja ne moze biti u buducnosti.");
        }

        entity.RecordedAt = dto.RecordedAt;
        entity.TemperatureCelsius = dto.TemperatureCelsius;
        entity.WindSpeedKmh = dto.WindSpeedKmh;
        entity.SnowfallCm = dto.SnowfallCm;
        entity.SnowDepthCm = dto.SnowDepthCm;
        entity.Conditions = dto.Conditions.Trim();
        entity.VisibilityMeters = dto.VisibilityMeters;
        entity.SkiResortId = dto.SkiResortId;
    }

    public async Task<WeatherLogDto?> GetLatestAsync(int skiResortId, CancellationToken cancellationToken = default)
    {
        var entity = await BaseQuery()
            .Where(w => !w.IsDeleted && w.SkiResortId == skiResortId)
            .OrderByDescending(w => w.RecordedAt)
            .AsNoTracking()
            .FirstOrDefaultAsync(cancellationToken);

        return entity is null ? null : MapToDto(entity);
    }
}
