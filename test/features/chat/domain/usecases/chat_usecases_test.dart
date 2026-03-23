import 'package:app_fe_ecomerce/core/error/failures.dart';
import 'package:app_fe_ecomerce/core/usecase/usecase.dart';
import 'package:app_fe_ecomerce/features/chat/data/models/conversation_model.dart';
import 'package:app_fe_ecomerce/features/chat/data/models/message_model.dart';
import 'package:app_fe_ecomerce/features/chat/domain/entities/conversation_entity.dart';
import 'package:app_fe_ecomerce/features/chat/domain/entities/message_entity.dart';
import 'package:app_fe_ecomerce/features/chat/domain/repositories/chat_repository.dart';
import 'package:app_fe_ecomerce/features/chat/domain/usecases/get_conversations_usecase.dart';
import 'package:app_fe_ecomerce/features/chat/domain/usecases/get_messages_usecase.dart';
import 'package:app_fe_ecomerce/features/chat/domain/usecases/send_message_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'chat_usecases_test.mocks.dart';

@GenerateMocks([ChatRepository])
void main() {
  late MockChatRepository mockRepository;

  setUp(() {
    mockRepository = MockChatRepository();
    // Provide dummies for Either type
    provideDummy<Either<Failure, List<ConversationEntity>>>(const Right([]));
    provideDummy<Either<Failure, List<MessageEntity>>>(const Right([]));
    provideDummy<Either<Failure, MessageEntity>>(const Right(MessageModel(id: 0, senderId: 0, receiverId: 0, content: 'temp')));
  });

  group('GetConversationsUseCase', () {
    late GetConversationsUseCase useCase;

    setUp(() {
      useCase = GetConversationsUseCase(mockRepository);
    });

    final tConversations = [
      const ConversationModel(
        id: 1,
        otherUser: ConversationUserModel(id: 10, name: 'Shop A'),
      ),
    ];

    test('should get conversations from repository', () async {
      // arrange
      when(mockRepository.getConversations())
          .thenAnswer((_) async => Right(tConversations));
      // act
      final result = await useCase(NoParams());
      // assert
      expect(result.isRight(), true);
      verify(mockRepository.getConversations());
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return failure when repository fails', () async {
      // arrange
      when(mockRepository.getConversations())
          .thenAnswer((_) async => const Left(ServerFailure('Error')));
      // act
      final result = await useCase(NoParams());
      // assert
      expect(result.isLeft(), true);
    });
  });

  group('GetMessagesUseCase', () {
    late GetMessagesUseCase useCase;

    setUp(() {
      useCase = GetMessagesUseCase(mockRepository);
    });

    final tMessages = [
      const MessageModel(id: 1, senderId: 10, receiverId: 1, content: 'Hi'),
    ];

    test('should get messages from repository with conversationId', () async {
      // arrange
      when(mockRepository.getMessages(any))
          .thenAnswer((_) async => Right(tMessages));
      // act
      final result = await useCase(5);
      // assert
      expect(result.isRight(), true);
      verify(mockRepository.getMessages(5));
    });
  });

  group('SendMessageUseCase', () {
    late SendMessageUseCase useCase;

    setUp(() {
      useCase = SendMessageUseCase(mockRepository);
    });

    const tMessage = MessageModel(
      id: 10,
      senderId: 1,
      receiverId: 20,
      content: 'Hello!',
    );

    test('should send message through repository', () async {
      // arrange
      when(mockRepository.sendMessage(
        receiverId: anyNamed('receiverId'),
        content: anyNamed('content'),
        type: anyNamed('type'),
      )).thenAnswer((_) async => const Right(tMessage));
      // act
      final result = await useCase(const SendMessageParams(
        receiverId: 20,
        content: 'Hello!',
      ));
      // assert
      expect(result.isRight(), true);
      verify(mockRepository.sendMessage(
        receiverId: 20,
        content: 'Hello!',
        type: 'TEXT',
      ));
    });

    test('should return failure when repository fails', () async {
      // arrange
      when(mockRepository.sendMessage(
        receiverId: anyNamed('receiverId'),
        content: anyNamed('content'),
        type: anyNamed('type'),
      )).thenAnswer((_) async => const Left(ServerFailure('Send failed')));
      // act
      final result = await useCase(const SendMessageParams(
        receiverId: 20,
        content: 'Hello!',
      ));
      // assert
      expect(result.isLeft(), true);
    });
  });
}
