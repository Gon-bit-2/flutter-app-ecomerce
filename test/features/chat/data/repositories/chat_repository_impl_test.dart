import 'package:app_fe_ecomerce/core/error/failures.dart';
import 'package:app_fe_ecomerce/features/chat/data/datasources/chat_remote_datasource.dart';
import 'package:app_fe_ecomerce/features/chat/data/models/conversation_model.dart';
import 'package:app_fe_ecomerce/features/chat/data/models/message_model.dart';
import 'package:app_fe_ecomerce/features/chat/data/repositories/chat_repository_impl.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'chat_repository_impl_test.mocks.dart';

@GenerateMocks([ChatRemoteDataSource])
void main() {
  late ChatRepositoryImpl repository;
  late MockChatRemoteDataSource mockDataSource;

  setUp(() {
    mockDataSource = MockChatRemoteDataSource();
    repository = ChatRepositoryImpl(mockDataSource);
  });

  group('getConversations', () {
    final tConversations = [
      const ConversationModel(
        id: 1,
        otherUser: ConversationUserModel(id: 10, name: 'Shop A'),
      ),
    ];

    test('should return Right(conversations) when datasource succeeds', () async {
      // arrange
      when(mockDataSource.getConversations())
          .thenAnswer((_) async => tConversations);
      // act
      final result = await repository.getConversations();
      // assert
      expect(result.isRight(), true);
      result.fold(
        (l) => fail('Should be Right'),
        (r) => expect(r, tConversations),
      );
    });

    test('should return Left(ServerFailure) when DioException occurs', () async {
      // arrange
      when(mockDataSource.getConversations()).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: ''),
          response: Response(
            data: {'message': 'Lỗi server'},
            statusCode: 500,
            requestOptions: RequestOptions(path: ''),
          ),
        ),
      );
      // act
      final result = await repository.getConversations();
      // assert
      expect(result.isLeft(), true);
      result.fold(
        (l) => expect(l, isA<ServerFailure>()),
        (r) => fail('Should be Left'),
      );
    });

    test('should return Left(ServerFailure) when unknown error occurs', () async {
      // arrange
      when(mockDataSource.getConversations())
          .thenThrow(Exception('Unknown error'));
      // act
      final result = await repository.getConversations();
      // assert
      expect(result.isLeft(), true);
    });
  });

  group('getMessages', () {
    final tMessages = [
      const MessageModel(
        id: 1,
        senderId: 10,
        receiverId: 1,
        content: 'Hello',
      ),
    ];

    test('should return Right(messages) when datasource succeeds', () async {
      // arrange
      when(mockDataSource.getMessages(any))
          .thenAnswer((_) async => tMessages);
      // act
      final result = await repository.getMessages(5);
      // assert
      expect(result.isRight(), true);
      verify(mockDataSource.getMessages(5));
    });

    test('should return Left(ServerFailure) when DioException occurs', () async {
      // arrange
      when(mockDataSource.getMessages(any)).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: ''),
          response: Response(
            data: {'message': 'Not found'},
            statusCode: 404,
            requestOptions: RequestOptions(path: ''),
          ),
        ),
      );
      // act
      final result = await repository.getMessages(999);
      // assert
      expect(result.isLeft(), true);
    });
  });

  group('sendMessage', () {
    const tMessage = MessageModel(
      id: 10,
      senderId: 1,
      receiverId: 20,
      content: 'Test message',
    );

    test('should return Right(message) when datasource succeeds', () async {
      // arrange
      when(mockDataSource.sendMessage(
        receiverId: anyNamed('receiverId'),
        content: anyNamed('content'),
        type: anyNamed('type'),
      )).thenAnswer((_) async => tMessage);
      // act
      final result = await repository.sendMessage(
        receiverId: 20,
        content: 'Test message',
      );
      // assert
      expect(result.isRight(), true);
      result.fold(
        (l) => fail('Should be Right'),
        (r) {
          expect(r.content, 'Test message');
          expect(r.receiverId, 20);
        },
      );
    });

    test('should return Left(ServerFailure) when send fails', () async {
      // arrange
      when(mockDataSource.sendMessage(
        receiverId: anyNamed('receiverId'),
        content: anyNamed('content'),
        type: anyNamed('type'),
      )).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: ''),
          response: Response(
            data: {'message': 'Unauthorized'},
            statusCode: 401,
            requestOptions: RequestOptions(path: ''),
          ),
        ),
      );
      // act
      final result = await repository.sendMessage(
        receiverId: 20,
        content: 'Test',
      );
      // assert
      expect(result.isLeft(), true);
    });
  });
}
