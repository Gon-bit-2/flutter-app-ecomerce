part of 'chat_bloc.dart';

abstract class ChatEvent extends Equatable {
  const ChatEvent();

  @override
  List<Object?> get props => [];
}

/// Tải danh sách hội thoại
class ChatLoadConversations extends ChatEvent {}

/// Tải tin nhắn trong 1 hội thoại
class ChatLoadMessages extends ChatEvent {
  final int conversationId;
  final int? receiverId;

  const ChatLoadMessages({
    required this.conversationId,
    this.receiverId,
  });

  @override
  List<Object?> get props => [conversationId, receiverId];
}

/// Gửi tin nhắn
class ChatSendMessage extends ChatEvent {
  final int receiverId;
  final String content;
  final int currentUserId;

  const ChatSendMessage({
    required this.receiverId,
    required this.content,
    required this.currentUserId,
  });

  @override
  List<Object?> get props => [receiverId, content, currentUserId];
}

/// Nhận tin nhắn mới từ WebSocket
class ChatNewMessageReceived extends ChatEvent {
  final MessageEntity message;

  const ChatNewMessageReceived({required this.message});

  @override
  List<Object?> get props => [message];
}

/// Kết nối WebSocket
class ChatConnectSocket extends ChatEvent {}

/// Ngắt kết nối WebSocket
class ChatDisconnectSocket extends ChatEvent {}
