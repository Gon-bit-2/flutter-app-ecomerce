part of 'chat_bloc.dart';

abstract class ChatState extends Equatable {
  const ChatState();

  @override
  List<Object?> get props => [];
}

class ChatInitial extends ChatState {}

class ChatLoading extends ChatState {}

class ChatMessagesLoading extends ChatState {}

class ConversationsLoaded extends ChatState {
  final List<ConversationEntity> conversations;

  const ConversationsLoaded({required this.conversations});

  @override
  List<Object?> get props => [conversations];
}

class MessagesLoaded extends ChatState {
  final List<MessageEntity> messages;
  final int conversationId;

  const MessagesLoaded({
    required this.messages,
    required this.conversationId,
  });

  @override
  List<Object?> get props => [messages, conversationId];
}

class ChatFailure extends ChatState {
  final String message;

  const ChatFailure(this.message);

  @override
  List<Object?> get props => [message];
}

class ChatSendFailure extends ChatState {
  final String message;

  const ChatSendFailure(this.message);

  @override
  List<Object?> get props => [message];
}
