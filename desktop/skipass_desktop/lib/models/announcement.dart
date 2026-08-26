import '../core/utils/json.dart';

class Announcement {
  const Announcement({
    required this.id,
    required this.title,
    required this.content,
    required this.publishedAt,
    required this.isUrgent,
    required this.isActive,
    required this.categoryId,
    required this.categoryName,
    required this.skiResortId,
    required this.skiResortName,
    required this.createdByUserName,
    this.imageUrl,
    this.expiresAt,
  });

  final int id;
  final String title;
  final String content;
  final DateTime publishedAt;
  final bool isUrgent;
  final bool isActive;
  final int categoryId;
  final String categoryName;
  final int skiResortId;
  final String skiResortName;
  final String createdByUserName;
  final String? imageUrl;
  final DateTime? expiresAt;

  factory Announcement.fromJson(Map<String, dynamic> json) => Announcement(
        id: Json.integer(json['id']),
        title: Json.str(json['title']),
        content: Json.str(json['content']),
        publishedAt: Json.date(json['publishedAt']),
        isUrgent: Json.boolean(json['isUrgent']),
        isActive: Json.boolean(json['isActive'], true),
        categoryId: Json.integer(json['announcementCategoryId']),
        categoryName: Json.str(json['announcementCategoryName']),
        skiResortId: Json.integer(json['skiResortId']),
        skiResortName: Json.str(json['skiResortName']),
        createdByUserName: Json.str(json['createdByUserName']),
        imageUrl: Json.strOrNull(json['imageUrl']),
        expiresAt: Json.dateOrNull(json['expiresAt']),
      );
}

class AppNotification {
  const AppNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.isRead,
    required this.createdAt,
    this.readAt,
    this.targetRoute,
  });

  final int id;
  final String title;
  final String message;
  final String type;
  final bool isRead;
  final DateTime createdAt;
  final DateTime? readAt;
  final String? targetRoute;

  factory AppNotification.fromJson(Map<String, dynamic> json) => AppNotification(
        id: Json.integer(json['id']),
        title: Json.str(json['title']),
        message: Json.str(json['message']),
        type: Json.str(json['type']),
        isRead: Json.boolean(json['isRead']),
        createdAt: Json.date(json['createdAt']),
        readAt: Json.dateOrNull(json['readAt']),
        targetRoute: Json.strOrNull(json['targetRoute']),
      );
}

class Review {
  const Review({
    required this.id,
    required this.rating,
    required this.targetType,
    required this.createdAt,
    required this.userId,
    required this.userFullName,
    this.comment,
    this.userProfileImageUrl,
    this.trailName,
    this.benefitName,
    this.skiResortName,
  });

  final int id;
  final int rating;
  final String targetType;
  final DateTime createdAt;
  final int userId;
  final String userFullName;
  final String? comment;
  final String? userProfileImageUrl;
  final String? trailName;
  final String? benefitName;
  final String? skiResortName;

  factory Review.fromJson(Map<String, dynamic> json) => Review(
        id: Json.integer(json['id']),
        rating: Json.integer(json['rating']),
        targetType: Json.str(json['targetType']),
        createdAt: Json.date(json['createdAt']),
        userId: Json.integer(json['userId']),
        userFullName: Json.str(json['userFullName']),
        comment: Json.strOrNull(json['comment']),
        userProfileImageUrl: Json.strOrNull(json['userProfileImageUrl']),
        trailName: Json.strOrNull(json['trailName']),
        benefitName: Json.strOrNull(json['benefitName']),
        skiResortName: Json.strOrNull(json['skiResortName']),
      );
}
