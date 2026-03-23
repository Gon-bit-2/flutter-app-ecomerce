import 'package:flutter_test/flutter_test.dart';
import 'package:app_fe_ecomerce/features/chat/data/models/conversation_model.dart';
import 'package:app_fe_ecomerce/features/chat/domain/entities/conversation_entity.dart';

void main() {
  group('ConversationModel', () {
    test('should be a subclass of ConversationEntity', () {
      const model = ConversationModel(
        id: 1,
        otherUser: ConversationUserModel(id: 10, name: 'Shop A'),
      );
      expect(model, isA<ConversationEntity>());
    });

    group('fromJson', () {
      test('should return a valid model with otherUser', () {
        // arrange
        final Map<String, dynamic> jsonMap = {
          'id': 1,
          'otherUser': {
            'id': 10,
            'name': 'Shop ABC',
            'avatar': 'https://example.com/avatar.jpg',
            'email': 'shop@example.com',
          },
          'createdAt': '2026-03-22T10:00:00Z',
        };
        // act
        final result = ConversationModel.fromJson(jsonMap);
        // assert
        expect(result.id, 1);
        expect(result.otherUser.id, 10);
        expect(result.otherUser.name, 'Shop ABC');
        expect(result.otherUser.avatar, 'https://example.com/avatar.jpg');
      });

      test('should handle "user" key instead of "otherUser"', () {
        // arrange
        final Map<String, dynamic> jsonMap = {
          'id': 2,
          'user': {
            'id': 20,
            'name': 'Buyer X',
          },
        };
        // act
        final result = ConversationModel.fromJson(jsonMap);
        // assert
        expect(result.otherUser.id, 20);
        expect(result.otherUser.name, 'Buyer X');
      });

      test('should handle lastMessage in conversation', () {
        // arrange
        final Map<String, dynamic> jsonMap = {
          'id': 3,
          'otherUser': {'id': 30, 'name': 'Shop XYZ'},
          'lastMessage': {
            'id': 100,
            'senderId': 30,
            'receiverId': 1,
            'content': 'Cám ơn bạn!',
            'type': 'TEXT',
          },
        };
        // act
        final result = ConversationModel.fromJson(jsonMap);
        // assert
        expect(result.lastMessage, isNotNull);
        expect(result.lastMessage!.content, 'Cám ơn bạn!');
        expect(result.lastMessage!.senderId, 30);
      });

      test('should handle missing otherUser gracefully', () {
        // arrange
        final Map<String, dynamic> jsonMap = {
          'id': 4,
        };
        // act
        final result = ConversationModel.fromJson(jsonMap);
        // assert
        expect(result.id, 4);
        expect(result.otherUser.id, 0);
        expect(result.otherUser.name, 'Người dùng');
      });
    });
  });

  group('ConversationUserModel', () {
    test('should be a subclass of ConversationUserEntity', () {
      const model = ConversationUserModel(id: 1, name: 'Test');
      expect(model, isA<ConversationUserEntity>());
    });

    test('fromJson should parse correctly', () {
      final json = {
        'id': 5,
        'name': 'User Test',
        'avatar': 'https://example.com/av.png',
        'email': 'test@test.com',
      };
      final result = ConversationUserModel.fromJson(json);
      expect(result.id, 5);
      expect(result.name, 'User Test');
      expect(result.avatar, 'https://example.com/av.png');
      expect(result.email, 'test@test.com');
    });
  });
}
