import 'package:app_fe_ecomerce/features/chat/domain/entities/message_entity.dart';

class MessageModel extends MessageEntity {
  const MessageModel({
    required super.id,
    required super.senderId,
    required super.receiverId,
    required super.content,
    super.type,
    super.conversationId,
    super.createdAt,
    super.updatedAt,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    int parseIntRobust(dynamic val) {
      if (val == null) return 0;
      if (val is num) return val.toInt();
      if (val is String) return int.tryParse(val) ?? 0;
      return 0;
    }

    return MessageModel(
      id: parseIntRobust(json['id']),
      senderId: parseIntRobust(json['senderId'] ?? json['sender']?['id'] ?? json['fromUserId']),
      receiverId: parseIntRobust(json['receiverId'] ?? json['receiver']?['id'] ?? json['toUserId']),
      content: json['content'] as String? ?? '',
      type: json['type'] as String? ?? 'TEXT',
      conversationId: parseIntRobust(json['conversationId']),
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'receiverId': receiverId,
      'content': content,
      'type': type,
    };
  }
}
