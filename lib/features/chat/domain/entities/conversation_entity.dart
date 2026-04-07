import 'package:equatable/equatable.dart';
import 'message_entity.dart';

class ConversationEntity extends Equatable {
  final int id;
  final ConversationUserEntity otherUser;
  final MessageEntity? lastMessage;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int unreadCount;

  const ConversationEntity({
    required this.id,
    required this.otherUser,
    this.lastMessage,
    this.createdAt,
    this.updatedAt,
    this.unreadCount = 0,
  });

  @override
  List<Object?> get props => [
    id,
    otherUser,
    lastMessage,
    createdAt,
    updatedAt,
    unreadCount,
  ];
}

class ConversationUserEntity extends Equatable {
  final int id;
  final String name;
  final String? avatar;
  final String? email;

  const ConversationUserEntity({
    required this.id,
    required this.name,
    this.avatar,
    this.email,
  });

  @override
  List<Object?> get props => [id, name, avatar, email];
}
