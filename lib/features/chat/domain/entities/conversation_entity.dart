import 'package:equatable/equatable.dart';
import 'message_entity.dart';

class ConversationEntity extends Equatable {
  final int id;
  final ConversationUserEntity otherUser;
  final MessageEntity? lastMessage;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const ConversationEntity({
    required this.id,
    required this.otherUser,
    this.lastMessage,
    this.createdAt,
    this.updatedAt,
  });

  @override
  List<Object?> get props => [
    id,
    otherUser,
    lastMessage,
    createdAt,
    updatedAt,
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
