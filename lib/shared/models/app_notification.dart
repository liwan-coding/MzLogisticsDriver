import '../../core/api/json_readers.dart';

class AppNotification {
  const AppNotification({
    required this.id,
    required this.title,
    required this.body,
    this.titleAr,
    this.titleEn,
    this.bodyAr,
    this.bodyEn,
    this.targetType,
    this.targetId,
    this.readAt,
    this.createdAt,
  });

  final String id;
  final String title;
  final String body;
  final String? titleAr;
  final String? titleEn;
  final String? bodyAr;
  final String? bodyEn;
  final String? targetType;
  final String? targetId;
  final String? readAt;
  final String? createdAt;

  bool get isUnread => readAt == null;

  String textTitle(String languageCode) {
    if (languageCode == 'en') {
      return titleEn ?? title;
    }
    return titleAr ?? title;
  }

  String textBody(String languageCode) {
    if (languageCode == 'en') {
      return bodyEn ?? body;
    }
    return bodyAr ?? body;
  }

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    final data = readMap(json['data']) ?? const {};
    return AppNotification(
      id: readString(json['id']) ?? '',
      title: readString(data['title']) ??
          readString(json['type'])?.split('\\').last ??
          '',
      body: readString(data['body']) ??
          readString(data['message']) ??
          readString(json['data']) ??
          '',
      titleAr: readString(data['title_ar']),
      titleEn: readString(data['title_en']),
      bodyAr: readString(data['body_ar']),
      bodyEn: readString(data['body_en']),
      targetType: readString(data['target_type']),
      targetId: readString(data['target_id']),
      readAt: readString(json['read_at']),
      createdAt: readString(json['created_at']),
    );
  }
}
