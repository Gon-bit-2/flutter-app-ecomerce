import 'package:app_fe_ecomerce/features/chat/data/models/message_model.dart';
import 'package:app_fe_ecomerce/features/chat/domain/entities/conversation_entity.dart';

class ConversationModel extends ConversationEntity {
  const ConversationModel({
    required super.id,
    required super.otherUser,
    super.lastMessage,
    super.createdAt,
    super.updatedAt,
  });

  factory ConversationModel.fromJson(Map<String, dynamic> json) {
    // Xử lý thông tin người chat (otherUser)
    final otherUserJson = json['otherUser'] ?? json['user'] ?? {};
    final otherUser = ConversationUserModel.fromJson(
      otherUserJson is Map<String, dynamic> ? otherUserJson : {},
    );

    // Xử lý tin nhắn gần nhất
    MessageModel? lastMessage;
    if (json['lastMessage'] != null && json['lastMessage'] is Map<String, dynamic>) {
      lastMessage = MessageModel.fromJson(json['lastMessage']);
    }

    return ConversationModel(
      id: json['id'] as int? ?? 0,
      otherUser: otherUser,
      lastMessage: lastMessage,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'].toString())
          : null,
    );
  }
}

class ConversationUserModel extends ConversationUserEntity {
  const ConversationUserModel({
    required super.id,
    required super.name,
    super.avatar,
    super.email,
  });

  factory ConversationUserModel.fromJson(Map<String, dynamic> json) {
    return ConversationUserModel(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? 'Người dùng',
      avatar: json['avatar'] as String?,
      email: json['email'] as String?,
    );
  }
}
