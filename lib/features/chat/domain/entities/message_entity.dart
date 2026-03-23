import 'package:equatable/equatable.dart';

class MessageEntity extends Equatable {
  final int id;
  final int senderId;
  final int receiverId;
  final String content;
  final String type;
  final int? conversationId;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const MessageEntity({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.content,
    this.type = 'TEXT',
    this.conversationId,
    this.createdAt,
    this.updatedAt,
  });

  @override
  List<Object?> get props => [
    id,
    senderId,
    receiverId,
    content,
    type,
    conversationId,
    createdAt,
    updatedAt,
  ];
}
