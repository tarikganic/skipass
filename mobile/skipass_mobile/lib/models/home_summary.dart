import '../core/utils/json.dart';
import 'announcement.dart';
import 'benefit.dart';
import 'weather.dart';

/// Objedinjeni podaci pocetne stranice, dohvaceni jednim pozivom API-ja.
class HomeSummary {
  const HomeSummary({
    required this.skiResortId,
    required this.skiResortName,
    required this.openingTime,
    required this.closingTime,
    required this.isResortOpen,
    required this.totalLiftCount,
    required this.operationalLiftCount,
    required this.totalTrailCount,
    required this.openTrailCount,
    required this.activeTicketCount,
    required this.unreadNotificationCount,
    required this.latestAnnouncements,
    required this.featuredBenefits,
    this.weather,
    this.skiResortLogoUrl,
  });

  final int skiResortId;
  final String skiResortName;
  final String openingTime;
  final String closingTime;
  final bool isResortOpen;
  final int totalLiftCount;
  final int operationalLiftCount;
  final int totalTrailCount;
  final int openTrailCount;
  final int activeTicketCount;
  final int unreadNotificationCount;
  final List<Announcement> latestAnnouncements;
  final List<Benefit> featuredBenefits;
  final WeatherLog? weather;
  final String? skiResortLogoUrl;

  int get closedLiftCount => totalLiftCount - operationalLiftCount;
  int get closedTrailCount => totalTrailCount - openTrailCount;

  factory HomeSummary.fromJson(Map<String, dynamic> json) => HomeSummary(
        skiResortId: Json.integer(json['skiResortId']),
        skiResortName: Json.str(json['skiResortName']),
        openingTime: Json.time(json['openingTime']),
        closingTime: Json.time(json['closingTime']),
        isResortOpen: Json.boolean(json['isResortOpen']),
        totalLiftCount: Json.integer(json['totalLiftCount']),
        operationalLiftCount: Json.integer(json['operationalLiftCount']),
        totalTrailCount: Json.integer(json['totalTrailCount']),
        openTrailCount: Json.integer(json['openTrailCount']),
        activeTicketCount: Json.integer(json['activeTicketCount']),
        unreadNotificationCount: Json.integer(json['unreadNotificationCount']),
        latestAnnouncements: Json.list(json['latestAnnouncements'], Announcement.fromJson),
        featuredBenefits: Json.list(json['featuredBenefits'], Benefit.fromJson),
        weather: json['weather'] is Map<String, dynamic>
            ? WeatherLog.fromJson(json['weather'] as Map<String, dynamic>)
            : null,
        skiResortLogoUrl: Json.strOrNull(json['skiResortLogoUrl']),
      );
}
