import 'package:app_fe_ecomerce/core/constants/app_constants.dart';
import 'package:app_fe_ecomerce/core/network/dio_client.dart';
import 'package:app_fe_ecomerce/features/chat/data/datasources/chat_remote_datasource.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'chat_remote_datasource_test.mocks.dart';

@GenerateMocks([DioClient])
void main() {
  late ChatRemoteDataSourceImpl dataSource;
  late MockDioClient mockDioClient;

  setUp(() {
    mockDioClient = MockDioClient();
    dataSource = ChatRemoteDataSourceImpl(mockDioClient);
  });

  group('getConversations', () {
    final tConversationsJson = [
      {
        'id': 1,
        'otherUser': {'id': 10, 'name': 'Shop A', 'avatar': null},
        'lastMessage': {
          'id': 100,
          'senderId': 10,
          'receiverId': 1,
          'content': 'Xin chào!',
          'type': 'TEXT',
        },
        'createdAt': '2026-03-22T10:00:00Z',
      },
      {
        'id': 2,
        'otherUser': {'id': 20, 'name': 'Shop B'},
        'lastMessage': null,
      },
    ];

    test('should perform GET on conversations endpoint', () async {
      // arrange
      when(mockDioClient.get(any)).thenAnswer(
        (_) async => Response(
          data: tConversationsJson,
          statusCode: 200,
          requestOptions: RequestOptions(path: ''),
        ),
      );
      // act
      await dataSource.getConversations();
      // assert
      verify(mockDioClient.get(AppConstants.conversationsEndpoint));
    });

    test('should return list of ConversationModel when successful', () async {
      // arrange
      when(mockDioClient.get(any)).thenAnswer(
        (_) async => Response(
          data: tConversationsJson,
          statusCode: 200,
          requestOptions: RequestOptions(path: ''),
        ),
      );
      // act
      final result = await dataSource.getConversations();
      // assert
      expect(result.length, 2);
      expect(result[0].id, 1);
      expect(result[0].otherUser.name, 'Shop A');
      expect(result[1].id, 2);
    });

    test('should handle wrapped response with data key', () async {
      // arrange
      when(mockDioClient.get(any)).thenAnswer(
        (_) async => Response(
          data: {'data': tConversationsJson},
          statusCode: 200,
          requestOptions: RequestOptions(path: ''),
        ),
      );
      // act
      final result = await dataSource.getConversations();
      // assert
      expect(result.length, 2);
    });

    test('should throw DioException when request fails', () async {
      // arrange
      when(mockDioClient.get(any)).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: ''),
          error: 'Server Error',
        ),
      );
      // act & assert
      expect(() => dataSource.getConversations(), throwsA(isA<DioException>()));
    });
  });

  group('getMessages', () {
    final tMessagesJson = [
      {
        'id': 1,
        'senderId': 10,
        'receiverId': 1,
        'content': 'Xin chào!',
        'type': 'TEXT',
        'createdAt': '2026-03-22T10:00:00Z',
      },
      {
        'id': 2,
        'senderId': 1,
        'receiverId': 10,
        'content': 'Chào bạn!',
        'type': 'TEXT',
        'createdAt': '2026-03-22T10:01:00Z',
      },
    ];

    test('should perform GET on conversation detail endpoint', () async {
      // arrange
      when(mockDioClient.get(any)).thenAnswer(
        (_) async => Response(
          data: tMessagesJson,
          statusCode: 200,
          requestOptions: RequestOptions(path: ''),
        ),
      );
      // act
      await dataSource.getMessages(5);
      // assert
      verify(mockDioClient.get('${AppConstants.conversationsEndpoint}/5'));
    });

    test('should return list of MessageModel when successful', () async {
      // arrange
      when(mockDioClient.get(any)).thenAnswer(
        (_) async => Response(
          data: tMessagesJson,
          statusCode: 200,
          requestOptions: RequestOptions(path: ''),
        ),
      );
      // act
      final result = await dataSource.getMessages(5);
      // assert
      expect(result.length, 2);
      expect(result[0].content, 'Xin chào!');
      expect(result[1].content, 'Chào bạn!');
    });
  });

  group('sendMessage', () {
    final tMessageResponseJson = {
      'id': 10,
      'senderId': 1,
      'receiverId': 20,
      'content': 'Hello Shop!',
      'type': 'TEXT',
      'createdAt': '2026-03-22T11:00:00Z',
    };

    test('should perform POST on messages endpoint', () async {
      // arrange
      when(mockDioClient.post(any, data: anyNamed('data'))).thenAnswer(
        (_) async => Response(
          data: tMessageResponseJson,
          statusCode: 201,
          requestOptions: RequestOptions(path: ''),
        ),
      );
      // act
      await dataSource.sendMessage(receiverId: 20, content: 'Hello Shop!');
      // assert
      verify(
        mockDioClient.post(
          AppConstants.messagesEndpoint,
          data: {'receiverId': 20, 'content': 'Hello Shop!', 'type': 'TEXT'},
        ),
      );
    });

    test('should return MessageModel when successful', () async {
      // arrange
      when(mockDioClient.post(any, data: anyNamed('data'))).thenAnswer(
        (_) async => Response(
          data: tMessageResponseJson,
          statusCode: 201,
          requestOptions: RequestOptions(path: ''),
        ),
      );
      // act
      final result = await dataSource.sendMessage(
        receiverId: 20,
        content: 'Hello Shop!',
      );
      // assert
      expect(result.id, 10);
      expect(result.receiverId, 20);
      expect(result.content, 'Hello Shop!');
    });

    test('should throw DioException when send fails', () async {
      // arrange
      when(mockDioClient.post(any, data: anyNamed('data'))).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: ''),
          error: 'Failed',
        ),
      );
      // act & assert
      expect(
        () => dataSource.sendMessage(receiverId: 20, content: 'Test'),
        throwsA(isA<DioException>()),
      );
    });
  });
}
