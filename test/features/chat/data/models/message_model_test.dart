import 'package:flutter_test/flutter_test.dart';
import 'package:app_fe_ecomerce/features/chat/data/models/message_model.dart';
import 'package:app_fe_ecomerce/features/chat/domain/entities/message_entity.dart';

void main() {
  group('MessageModel', () {
    const tMessageModel = MessageModel(
      id: 1,
      senderId: 10,
      receiverId: 20,
      content: 'Xin chào!',
      type: 'TEXT',
      conversationId: 5,
    );

    test('should be a subclass of MessageEntity', () {
      expect(tMessageModel, isA<MessageEntity>());
    });

    group('fromJson', () {
      test('should return a valid model from standard JSON', () {
        // arrange
        final Map<String, dynamic> jsonMap = {
          'id': 1,
          'senderId': 10,
          'receiverId': 20,
          'content': 'Xin chào!',
          'type': 'TEXT',
          'conversationId': 5,
        };
        // act
        final result = MessageModel.fromJson(jsonMap);
        // assert
        expect(result.id, 1);
        expect(result.senderId, 10);
        expect(result.receiverId, 20);
        expect(result.content, 'Xin chào!');
        expect(result.type, 'TEXT');
        expect(result.conversationId, 5);
      });

      test('should handle nested sender/receiver objects', () {
        // arrange
        final Map<String, dynamic> jsonMap = {
          'id': 2,
          'sender': {'id': 15},
          'receiver': {'id': 25},
          'content': 'Tin nhắn test',
          'type': 'TEXT',
        };
        // act
        final result = MessageModel.fromJson(jsonMap);
        // assert
        expect(result.senderId, 15);
        expect(result.receiverId, 25);
      });

      test('should handle null/missing fields with defaults', () {
        // arrange
        final Map<String, dynamic> jsonMap = {
          'id': 3,
        };
        // act
        final result = MessageModel.fromJson(jsonMap);
        // assert
        expect(result.id, 3);
        expect(result.senderId, 0);
        expect(result.receiverId, 0);
        expect(result.content, '');
        expect(result.type, 'TEXT');
      });

      test('should parse createdAt timestamp correctly', () {
        // arrange
        final Map<String, dynamic> jsonMap = {
          'id': 4,
          'senderId': 10,
          'receiverId': 20,
          'content': 'Test',
          'createdAt': '2026-03-22T10:00:00Z',
        };
        // act
        final result = MessageModel.fromJson(jsonMap);
        // assert
        expect(result.createdAt, isNotNull);
        expect(result.createdAt!.year, 2026);
        expect(result.createdAt!.month, 3);
      });
    });

    group('toJson', () {
      test('should return a JSON map for sending message', () {
        // act
        final result = tMessageModel.toJson();
        // assert
        expect(result, {
          'receiverId': 20,
          'content': 'Xin chào!',
          'type': 'TEXT',
        });
      });
    });
  });
}
