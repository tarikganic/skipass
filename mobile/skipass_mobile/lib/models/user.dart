import '../core/utils/json.dart';

/// Rezultat uspjesne prijave ili registracije.
class AuthSession {
  const AuthSession({
    required this.accessToken,
    required this.expiresAt,
    required this.userId,
    required this.username,
    required this.fullName,
    required this.email,
    required this.role,
    this.profileImageUrl,
  });

  final String accessToken;
  final DateTime expiresAt;
  final int userId;
  final String username;
  final String fullName;
  final String email;
  final String role;
  final String? profileImageUrl;

  factory AuthSession.fromJson(Map<String, dynamic> json) => AuthSession(
        accessToken: Json.str(json['accessToken']),
        expiresAt: Json.date(json['expiresAt']),
        userId: Json.integer(json['userId']),
        username: Json.str(json['username']),
        fullName: Json.str(json['fullName']),
        email: Json.str(json['email']),
        role: Json.str(json['role']),
        profileImageUrl: Json.strOrNull(json['profileImageUrl']),
      );
}

class AppUser {
  const AppUser({
    required this.id,
    required this.username,
    required this.firstName,
    required this.lastName,
    required this.fullName,
    required this.email,
    required this.role,
    required this.isActive,
    required this.createdAt,
    required this.orderCount,
    this.phone,
    this.birthDate,
    this.profileImageUrl,
    this.cityId,
    this.cityName,
    this.lastLoginAt,
  });

  final int id;
  final String username;
  final String firstName;
  final String lastName;
  final String fullName;
  final String email;
  final String role;
  final bool isActive;
  final DateTime createdAt;
  final int orderCount;
  final String? phone;
  final DateTime? birthDate;
  final String? profileImageUrl;
  final int? cityId;
  final String? cityName;
  final DateTime? lastLoginAt;

  /// Inicijali za avatar kada korisnik nema postavljenu sliku.
  String get initials {
    final first = firstName.isNotEmpty ? firstName[0] : '';
    final last = lastName.isNotEmpty ? lastName[0] : '';
    final value = '$first$last'.trim();
    return value.isEmpty ? '?' : value.toUpperCase();
  }

  factory AppUser.fromJson(Map<String, dynamic> json) => AppUser(
        id: Json.integer(json['id']),
        username: Json.str(json['username']),
        firstName: Json.str(json['firstName']),
        lastName: Json.str(json['lastName']),
        fullName: Json.str(json['fullName']),
        email: Json.str(json['email']),
        role: Json.str(json['role']),
        isActive: Json.boolean(json['isActive'], true),
        createdAt: Json.date(json['createdAt']),
        orderCount: Json.integer(json['orderCount']),
        phone: Json.strOrNull(json['phone']),
        birthDate: Json.dateOrNull(json['birthDate']),
        profileImageUrl: Json.strOrNull(json['profileImageUrl']),
        cityId: Json.integerOrNull(json['cityId']),
        cityName: Json.strOrNull(json['cityName']),
        lastLoginAt: Json.dateOrNull(json['lastLoginAt']),
      );
}
