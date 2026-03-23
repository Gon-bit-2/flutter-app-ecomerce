import 'package:app_fe_ecomerce/core/error/failures.dart';
import 'package:app_fe_ecomerce/core/services/chat_socket_service.dart';
import 'package:app_fe_ecomerce/features/chat/data/models/conversation_model.dart';
import 'package:app_fe_ecomerce/features/chat/data/models/message_model.dart';
import 'package:app_fe_ecomerce/features/chat/domain/entities/conversation_entity.dart';
import 'package:app_fe_ecomerce/features/chat/domain/entities/message_entity.dart';
import 'package:app_fe_ecomerce/features/chat/domain/usecases/get_conversations_usecase.dart';
import 'package:app_fe_ecomerce/features/chat/domain/usecases/get_messages_usecase.dart';
import 'package:app_fe_ecomerce/features/chat/domain/usecases/send_message_usecase.dart';
import 'package:app_fe_ecomerce/features/chat/presentation/bloc/chat/chat_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'chat_bloc_test.mocks.dart';

@GenerateMocks([
  GetConversationsUseCase,
  GetMessagesUseCase,
  SendMessageUseCase,
  ChatSocketService,
])
void main() {
  late ChatBloc chatBloc;
  late MockGetConversationsUseCase mockGetConversations;
  late MockGetMessagesUseCase mockGetMessages;
  late MockSendMessageUseCase mockSendMessage;
  late MockChatSocketService mockChatSocketService;

  setUp(() {
    mockGetConversations = MockGetConversationsUseCase();
    mockGetMessages = MockGetMessagesUseCase();
    mockSendMessage = MockSendMessageUseCase();
    mockChatSocketService = MockChatSocketService();
    
    // Provide dummies for Either type from fpdart
    provideDummy<Either<Failure, List<ConversationEntity>>>(const Right([]));
    provideDummy<Either<Failure, List<MessageEntity>>>(const Right([]));
    provideDummy<Either<Failure, MessageEntity>>(const Right(MessageModel(id: 0, senderId: 0, receiverId: 0, content: '')));

    chatBloc = ChatBloc(
      mockGetConversations,
      mockGetMessages,
      mockSendMessage,
      mockChatSocketService,
    );
  });

  tearDown(() {
    chatBloc.close();
  });

  // Test data
  final tConversations = [
    const ConversationModel(
      id: 1,
      otherUser: ConversationUserModel(id: 10, name: 'Shop A'),
    ),
  ];

  final tMessages = [
    const MessageModel(id: 1, senderId: 10, receiverId: 1, content: 'Xin chào!'),
  ];

  test('initial state should be ChatInitial', () {
    expect(chatBloc.state, isA<ChatInitial>());
  });

  group('ChatLoadConversations', () {
    test('emits [ChatLoading, ConversationsLoaded] khi tải thành công', () async {
      // arrange
      when(mockGetConversations(any)).thenAnswer((_) async => Right(tConversations));
      // assert
      final expectedContent = [
        isA<ChatLoading>(),
        isA<ConversationsLoaded>(),
      ];
      expectLater(chatBloc.stream, emitsInOrder(expectedContent));
      // act
      chatBloc.add(ChatLoadConversations());
    });

    test('emits [ChatLoading, ChatFailure] khi tải thất bại', () async {
      // arrange
      when(mockGetConversations(any)).thenAnswer((_) async => const Left(ServerFailure('Lỗi')));
      // assert
      final expectedContent = [
        isA<ChatLoading>(),
        isA<ChatFailure>(),
      ];
      expectLater(chatBloc.stream, emitsInOrder(expectedContent));
      // act
      chatBloc.add(ChatLoadConversations());
    });
  });

  group('ChatLoadMessages', () {
    test('emits [ChatMessagesLoading, MessagesLoaded] khi tải thành công', () async {
      // arrange
      when(mockGetMessages(any)).thenAnswer((_) async => Right(tMessages));
      // assert
      final expectedContent = [
        isA<ChatMessagesLoading>(),
        isA<MessagesLoaded>(),
      ];
      expectLater(chatBloc.stream, emitsInOrder(expectedContent));
      // act
      chatBloc.add(const ChatLoadMessages(conversationId: 5));
    });

    test('emits [ChatMessagesLoading, ChatFailure] khi tải thất bại', () async {
      // arrange
      when(mockGetMessages(any)).thenAnswer((_) async => const Left(ServerFailure('Lỗi')));
      // assert
      final expectedContent = [
        isA<ChatMessagesLoading>(),
        isA<ChatFailure>(),
      ];
      expectLater(chatBloc.stream, emitsInOrder(expectedContent));
      // act
      chatBloc.add(const ChatLoadMessages(conversationId: 5));
    });
  });

  group('ChatSendMessage', () {
    const tSentMessage = MessageModel(id: 2, senderId: 1, receiverId: 10, content: 'Hi!');
    
    test('nên thêm tin nhắn gốc vào MessagesLoaded nếu thành công', () async {
      // setup trạng thái ban đầu để send message
      when(mockGetMessages(any)).thenAnswer((_) async => Right(tMessages));
      
      // Load mảng trạng thái 1
      chatBloc.add(const ChatLoadMessages(conversationId: 1));
      await Future.delayed(const Duration(milliseconds: 50));
      assert(chatBloc.state is MessagesLoaded); // verify it loaded
      
      // arrange action send
      when(mockSendMessage(any)).thenAnswer((_) async => const Right(tSentMessage));
      
      // assert that after send, list changes
      expectLater(
        chatBloc.stream,
        emitsThrough(
          isA<MessagesLoaded>().having((state) => state.messages.length, 'length', equals(2)),
        ),
      );
      
      // act
      chatBloc.add(const ChatSendMessage(currentUserId: 1, receiverId: 10, content: 'Hi!'));
    });
  });
}
