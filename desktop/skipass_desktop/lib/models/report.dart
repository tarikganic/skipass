import '../core/utils/json.dart';

class SalesByDay {
  const SalesByDay({required this.date, required this.ticketCount, required this.revenue});

  final DateTime date;
  final int ticketCount;
  final double revenue;

  factory SalesByDay.fromJson(Map<String, dynamic> json) => SalesByDay(
        date: Json.dateOnly(json['date']),
        ticketCount: Json.integer(json['ticketCount']),
        revenue: Json.decimal(json['revenue']),
      );
}

class SalesReport {
  const SalesReport({
    required this.dateFrom,
    required this.dateTo,
    required this.totalTicketCount,
    required this.totalRevenue,
    required this.days,
  });

  final DateTime dateFrom;
  final DateTime dateTo;
  final int totalTicketCount;
  final double totalRevenue;
  final List<SalesByDay> days;

  factory SalesReport.fromJson(Map<String, dynamic> json) => SalesReport(
        dateFrom: Json.dateOnly(json['dateFrom']),
        dateTo: Json.dateOnly(json['dateTo']),
        totalTicketCount: Json.integer(json['totalTicketCount']),
        totalRevenue: Json.decimal(json['totalRevenue']),
        days: Json.list(json['days'], SalesByDay.fromJson),
      );
}

class TopUser {
  const TopUser({
    required this.userId,
    required this.fullName,
    required this.email,
    required this.ticketCount,
    required this.totalSpent,
  });

  final int userId;
  final String fullName;
  final String email;
  final int ticketCount;
  final double totalSpent;

  factory TopUser.fromJson(Map<String, dynamic> json) => TopUser(
        userId: Json.integer(json['userId']),
        fullName: Json.str(json['fullName']),
        email: Json.str(json['email']),
        ticketCount: Json.integer(json['ticketCount']),
        totalSpent: Json.decimal(json['totalSpent']),
      );
}

class TopUsersReport {
  const TopUsersReport({required this.top, required this.users});

  final int top;
  final List<TopUser> users;

  factory TopUsersReport.fromJson(Map<String, dynamic> json) => TopUsersReport(
        top: Json.integer(json['top']),
        users: Json.list(json['users'], TopUser.fromJson),
      );
}
