import 'dart:async';
import 'package:app_fe_ecomerce/core/services/chat_socket_service.dart';
import 'package:app_fe_ecomerce/core/usecase/usecase.dart';
import 'package:app_fe_ecomerce/features/chat/data/models/message_model.dart';
import 'package:app_fe_ecomerce/features/chat/domain/entities/conversation_entity.dart';
import 'package:app_fe_ecomerce/features/chat/domain/entities/message_entity.dart';
import 'package:app_fe_ecomerce/features/chat/domain/usecases/get_conversations_usecase.dart';
import 'package:app_fe_ecomerce/features/chat/domain/usecases/get_messages_usecase.dart';
import 'package:app_fe_ecomerce/features/chat/domain/usecases/send_message_usecase.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

part 'chat_event.dart';
part 'chat_state.dart';

@injectable
class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final GetConversationsUseCase _getConversationsUseCase;
  final GetMessagesUseCase _getMessagesUseCase;
  final SendMessageUseCase _sendMessageUseCase;
  final ChatSocketService _chatSocketService;

  StreamSubscription<MessageModel>? _socketSubscription;

  ChatBloc(
    this._getConversationsUseCase,
    this._getMessagesUseCase,
    this._sendMessageUseCase,
    this._chatSocketService,
  ) : super(ChatInitial()) {
    on<ChatLoadConversations>(_onLoadConversations);
    on<ChatLoadMessages>(_onLoadMessages);
    on<ChatSendMessage>(_onSendMessage);
    on<ChatNewMessageReceived>(_onNewMessageReceived);
    on<ChatConnectSocket>(_onConnectSocket);
    on<ChatDisconnectSocket>(_onDisconnectSocket);
  }

  Future<void> _onLoadConversations(
    ChatLoadConversations event,
    Emitter<ChatState> emit,
  ) async {
    emit(ChatLoading());
    final result = await _getConversationsUseCase(NoParams());
    result.fold(
      (failure) => emit(ChatFailure(failure.message)),
      (conversations) => emit(ConversationsLoaded(conversations: conversations)),
    );
  }

  Future<void> _onLoadMessages(
    ChatLoadMessages event,
    Emitter<ChatState> emit,
  ) async {
    emit(ChatMessagesLoading());
    final result = await _getMessagesUseCase(event.conversationId);
    result.fold(
      (failure) => emit(ChatFailure(failure.message)),
      (messages) => emit(MessagesLoaded(
        messages: messages,
        conversationId: event.conversationId,
      )),
    );
  }

  Future<void> _onSendMessage(
    ChatSendMessage event,
    Emitter<ChatState> emit,
  ) async {
    // Optimistic update: thêm tin nhắn vào list trước khi API trả về
    if (state is MessagesLoaded) {
      final currentMessages = (state as MessagesLoaded).messages;
      final conversationId = (state as MessagesLoaded).conversationId;
      final optimisticMessage = MessageEntity(
        id: DateTime.now().millisecondsSinceEpoch, // temp id
        senderId: event.currentUserId,
        receiverId: event.receiverId,
        content: event.content,
        type: 'TEXT',
        createdAt: DateTime.now(),
      );
      emit(MessagesLoaded(
        messages: [...currentMessages, optimisticMessage],
        conversationId: conversationId,
      ));
    }

    final result = await _sendMessageUseCase(SendMessageParams(
      receiverId: event.receiverId,
      content: event.content,
    ));

    result.fold(
      (failure) => emit(ChatSendFailure(failure.message)),
      (message) {
        // Tin nhắn đã gửi thành công, có thể cập nhật lại list nếu cần
        if (state is MessagesLoaded) {
          final currentState = state as MessagesLoaded;
          // Thay thế optimistic message bằng message thật từ server
          final updatedMessages = currentState.messages.map((m) {
            if (m.id == DateTime.now().millisecondsSinceEpoch) {
              return message;
            }
            return m;
          }).toList();
          emit(MessagesLoaded(
            messages: updatedMessages,
            conversationId: currentState.conversationId,
          ));
        }
      },
    );
  }

  void _onNewMessageReceived(
    ChatNewMessageReceived event,
    Emitter<ChatState> emit,
  ) {
    if (state is MessagesLoaded) {
      final currentState = state as MessagesLoaded;
      // Kiểm tra tin nhắn trùng lặp
      final isDuplicate = currentState.messages.any((m) => m.id == event.message.id);
      if (!isDuplicate) {
        emit(MessagesLoaded(
          messages: [...currentState.messages, event.message],
          conversationId: currentState.conversationId,
        ));
      }
    }
  }

  Future<void> _onConnectSocket(
    ChatConnectSocket event,
    Emitter<ChatState> emit,
  ) async {
    await _chatSocketService.connect();
    _socketSubscription?.cancel();
    _socketSubscription = _chatSocketService.messageStream.listen((message) {
      add(ChatNewMessageReceived(message: message));
    });
  }

  Future<void> _onDisconnectSocket(
    ChatDisconnectSocket event,
    Emitter<ChatState> emit,
  ) async {
    _socketSubscription?.cancel();
    _socketSubscription = null;
    _chatSocketService.disconnect();
  }

  @override
  Future<void> close() {
    _socketSubscription?.cancel();
    return super.close();
  }
}
