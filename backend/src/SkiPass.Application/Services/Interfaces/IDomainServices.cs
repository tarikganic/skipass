using SkiPass.Application.Common;
using SkiPass.Application.DTOs.Announcements;
using SkiPass.Application.DTOs.Benefits;
using SkiPass.Application.DTOs.Incidents;
using SkiPass.Application.DTOs.Lifts;
using SkiPass.Application.DTOs.Notifications;
using SkiPass.Application.DTOs.Orders;
using SkiPass.Application.DTOs.Payments;
using SkiPass.Application.DTOs.Recommendations;
using SkiPass.Application.DTOs.Resorts;
using SkiPass.Application.DTOs.Reviews;
using SkiPass.Application.DTOs.Tickets;
using SkiPass.Application.DTOs.Trails;
using SkiPass.Application.DTOs.Users;
using SkiPass.Application.DTOs.Weather;

namespace SkiPass.Application.Services.Interfaces;

public interface IUserService
    : ICrudService<UserDto, UserCreateDto, UserUpdateDto, UserSearchDto>
{
    Task<UserDto> GetProfileAsync(int userId, CancellationToken cancellationToken = default);
    Task<UserDto> UpdateProfileAsync(int userId, UserProfileUpdateDto dto, CancellationToken cancellationToken = default);
}

public interface ISkiResortService
    : ICrudService<SkiResortDto, SkiResortUpsertDto, SkiResortSearchDto>, ILookupProvider
{
}

public interface ITrailService
    : ICrudService<TrailDto, TrailUpsertDto, TrailSearchDto>, ILookupProvider
{
    Task<TrailDto> UpdateStatusAsync(int id, TrailStatusUpdateDto dto, CancellationToken cancellationToken = default);
}

public interface ITrailConditionLogService
    : ICrudService<TrailConditionLogDto, TrailConditionLogCreateDto, TrailConditionLogCreateDto, TrailConditionLogSearchDto>
{
}

public interface ISkiLiftService
    : ICrudService<SkiLiftDto, SkiLiftUpsertDto, SkiLiftSearchDto>, ILookupProvider
{
    Task<SkiLiftDto> UpdateStatusAsync(int id, SkiLiftStatusUpdateDto dto, CancellationToken cancellationToken = default);
}

public interface ILiftMaintenanceService
    : ICrudService<LiftMaintenanceRecordDto, LiftMaintenanceRecordCreateDto, LiftMaintenanceRecordCreateDto, LiftMaintenanceSearchDto>
{
    Task<LiftMaintenanceRecordDto> UpdateStatusAsync(int id, LiftMaintenanceStatusUpdateDto dto, CancellationToken cancellationToken = default);
}

public interface ITicketTypeService
    : ICrudService<TicketTypeDto, TicketTypeUpsertDto, TicketTypeSearchDto>, ILookupProvider
{
}

public interface ISkiPassOrderService
{
    Task<PagedResult<SkiPassOrderDto>> SearchAsync(SkiPassOrderSearchDto request, CancellationToken cancellationToken = default);
    Task<SkiPassOrderDetailsDto> GetByIdAsync(int id, CancellationToken cancellationToken = default);
    Task<SkiPassOrderDetailsDto> CreateAsync(SkiPassOrderCreateDto dto, int userId, CancellationToken cancellationToken = default);
    Task<SkiPassOrderDetailsDto> UpdateStatusAsync(int id, SkiPassOrderStatusUpdateDto dto, int actingUserId, CancellationToken cancellationToken = default);
    Task DeleteAsync(int id, CancellationToken cancellationToken = default);
}

public interface ISkiPassTicketService
{
    Task<PagedResult<SkiPassTicketDto>> SearchAsync(SkiPassTicketSearchDto request, CancellationToken cancellationToken = default);
    Task<SkiPassTicketDto> GetByIdAsync(int id, CancellationToken cancellationToken = default);
    Task<TicketValidationDto> ValidateAsync(TicketValidationRequestDto dto, int validatedByUserId, CancellationToken cancellationToken = default);
    Task<PagedResult<TicketValidationDto>> SearchValidationsAsync(TicketValidationSearchDto request, CancellationToken cancellationToken = default);
}

public interface IPaymentService
{
    Task<PagedResult<PaymentDto>> SearchAsync(PaymentSearchDto request, CancellationToken cancellationToken = default);
    Task<PaymentDto> GetByIdAsync(int id, CancellationToken cancellationToken = default);
    Task<PaymentDto> InitiateAsync(PaymentCreateDto dto, int userId, CancellationToken cancellationToken = default);
    Task<PaymentDto> ConfirmAsync(int id, PaymentConfirmDto dto, CancellationToken cancellationToken = default);
    Task<PaymentDto> RefundAsync(int id, PaymentRefundDto dto, CancellationToken cancellationToken = default);

    /// <summary>Obradjuje Stripe webhook dogadjaj - jedino mjesto gdje se online placanje stvarno finalizira.</summary>
    Task HandleStripeWebhookAsync(string jsonPayload, string stripeSignatureHeader, CancellationToken cancellationToken = default);
}

public interface IPartnerService
    : ICrudService<PartnerDto, PartnerUpsertDto, PartnerSearchDto>, ILookupProvider
{
}

public interface IBenefitService
    : ICrudService<BenefitDto, BenefitUpsertDto, BenefitSearchDto>, ILookupProvider
{
}

public interface IBenefitPurchaseService
    : ICrudService<BenefitPurchaseDto, BenefitPurchaseCreateDto, BenefitPurchaseCreateDto, BenefitPurchaseSearchDto>
{
    Task<BenefitPurchaseDto> CreateForUserAsync(BenefitPurchaseCreateDto dto, int userId, CancellationToken cancellationToken = default);
    Task<BenefitPurchaseDto> UpdateStatusAsync(int id, BenefitPurchaseStatusUpdateDto dto, CancellationToken cancellationToken = default);
}

public interface IBenefitViewService
{
    Task<PagedResult<BenefitViewDto>> SearchAsync(BenefitViewSearchDto request, CancellationToken cancellationToken = default);
    Task<BenefitViewDto> TrackAsync(BenefitViewCreateDto dto, int userId, CancellationToken cancellationToken = default);
}

public interface IRecommenderService
{
    Task<List<RecommendedBenefitDto>> GetRecommendedBenefitsAsync(int userId, int take, CancellationToken cancellationToken = default);
}

public interface IIncidentService
{
    Task<PagedResult<IncidentDto>> SearchAsync(IncidentSearchDto request, CancellationToken cancellationToken = default);
    Task<IncidentDto> GetByIdAsync(int id, CancellationToken cancellationToken = default);
    Task<IncidentDto> CreateAsync(IncidentCreateDto dto, int reportedByUserId, CancellationToken cancellationToken = default);
    Task<IncidentDto> UpdateStatusAsync(int id, IncidentStatusUpdateDto dto, int handledByUserId, CancellationToken cancellationToken = default);
    Task DeleteAsync(int id, CancellationToken cancellationToken = default);
}

public interface IAnnouncementService
    : ICrudService<AnnouncementDto, AnnouncementUpsertDto, AnnouncementSearchDto>
{
    Task<AnnouncementDto> CreateForUserAsync(AnnouncementUpsertDto dto, int userId, CancellationToken cancellationToken = default);
}

public interface INotificationService
{
    Task<PagedResult<NotificationDto>> SearchAsync(NotificationSearchDto request, CancellationToken cancellationToken = default);
    Task<NotificationDto> GetByIdAsync(int id, CancellationToken cancellationToken = default);
    Task<NotificationDto> CreateAsync(NotificationCreateDto dto, CancellationToken cancellationToken = default);
    Task<NotificationDto> MarkAsReadAsync(int id, int userId, CancellationToken cancellationToken = default);
    Task<int> MarkAllAsReadAsync(int userId, CancellationToken cancellationToken = default);
    Task<UnreadNotificationCountDto> GetUnreadCountAsync(int userId, CancellationToken cancellationToken = default);
    Task DeleteAsync(int id, CancellationToken cancellationToken = default);
}

public interface IReviewService
{
    Task<PagedResult<ReviewDto>> SearchAsync(ReviewSearchDto request, CancellationToken cancellationToken = default);
    Task<ReviewDto> GetByIdAsync(int id, CancellationToken cancellationToken = default);
    Task<ReviewDto> CreateAsync(ReviewCreateDto dto, int userId, CancellationToken cancellationToken = default);
    Task<ReviewDto> UpdateAsync(int id, ReviewUpdateDto dto, int userId, bool isAdmin, CancellationToken cancellationToken = default);
    Task DeleteAsync(int id, int userId, bool isAdmin, CancellationToken cancellationToken = default);
}

public interface IWeatherLogService
    : ICrudService<WeatherLogDto, WeatherLogUpsertDto, WeatherLogSearchDto>
{
    Task<WeatherLogDto?> GetLatestAsync(int skiResortId, CancellationToken cancellationToken = default);
}
