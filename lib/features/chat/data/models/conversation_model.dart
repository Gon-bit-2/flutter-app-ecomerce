import 'package:app_fe_ecomerce/features/chat/data/models/message_model.dart';
import 'package:app_fe_ecomerce/features/chat/domain/entities/conversation_entity.dart';

class ConversationModel extends ConversationEntity {
  const ConversationModel({
    required super.id,
    required super.otherUser,
    super.lastMessage,
    super.unreadCount,
    super.createdAt,
    super.updatedAt,
  });

  factory ConversationModel.fromJson(Map<String, dynamic> json) {
    // Xử lý thông tin người chat (otherUser)
    var otherUserJson = json['otherUser'] ?? json['user'] ?? json['shop'];
    
    if (otherUserJson == null || otherUserJson is! Map<String, dynamic>) {
      // Fallback cho trường hợp dữ liệu được làm phẳng (flattened)
      otherUserJson = <String, dynamic>{
        'id': json['shopId'] ?? json['partnerId'] ?? json['userId'],
        'name': json['shopName'] ?? json['partnerName'] ?? json['userName'],
        'avatar': json['shopLogo'] ?? json['shopAvatar'] ?? json['partnerAvatar'] ?? json['userAvatar'],
      };
    }
    
    final otherUser = ConversationUserModel.fromJson(
      otherUserJson,
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
      unreadCount: json['unreadCount'] is num ? (json['unreadCount'] as num).toInt() : (int.tryParse(json['unreadCount']?.toString() ?? '0') ?? 0),
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
    final parsedId = json['id'] ?? json['userId'] ?? json['shopId'] ?? json['partnerId'];
    return ConversationUserModel(
      id: parsedId is num ? parsedId.toInt() : (int.tryParse(parsedId?.toString() ?? '0') ?? 0),
      name: json['name'] as String? ?? json['shopName'] as String? ?? json['userName'] as String? ?? 'Người dùng',
      avatar: json['avatar'] as String? ?? json['logo'] as String? ?? json['shopAvatar'] as String?,
      email: json['email'] as String?,
    );
  }
}
