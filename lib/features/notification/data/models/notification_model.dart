import '../../domain/entities/notification_entity.dart';

class NotificationModel extends NotificationEntity {
  const NotificationModel({
    required super.id,
    required super.title,
    required super.body,
    required super.type,
    super.data,
    super.isRead,
    super.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    // Parse data field — có thể là Map hoặc null
    Map<String, dynamic>? dataMap;
    if (json['data'] != null && json['data'] is Map) {
      dataMap = Map<String, dynamic>.from(json['data'] as Map);
    }

    return NotificationModel(
      id: (json['id'] as num).toInt(),
      title: json['title'] as String? ?? '',
      body: json['body'] as String? ?? '',
      type: json['type'] as String? ?? 'SYSTEM',
      data: dataMap,
      isRead: json['isRead'] as bool? ?? false,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.tryParse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'title': title,
        'body': body,
        'type': type,
        'data': data,
        'isRead': isRead,
        'createdAt': createdAt?.toIso8601String(),
      };
}
