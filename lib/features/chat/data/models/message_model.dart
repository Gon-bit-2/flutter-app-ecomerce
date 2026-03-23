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
    return MessageModel(
      id: json['id'] as int,
      senderId: json['senderId'] as int? ?? json['sender']?['id'] as int? ?? 0,
      receiverId: json['receiverId'] as int? ?? json['receiver']?['id'] as int? ?? 0,
      content: json['content'] as String? ?? '',
      type: json['type'] as String? ?? 'TEXT',
      conversationId: json['conversationId'] as int?,
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
