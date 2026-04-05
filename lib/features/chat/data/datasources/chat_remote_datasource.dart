import 'dart:convert';
import 'package:app_fe_ecomerce/core/constants/app_constants.dart';
import 'package:app_fe_ecomerce/core/network/dio_client.dart';
import 'package:app_fe_ecomerce/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:app_fe_ecomerce/features/chat/data/models/conversation_model.dart';
import 'package:app_fe_ecomerce/features/chat/data/models/message_model.dart';
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';

abstract class ChatRemoteDataSource {
  /// GET /messages/conversations
  Future<List<ConversationModel>> getConversations();

  /// GET /messages/conversations/:conversationId
  Future<List<MessageModel>> getMessages(int conversationId);

  /// POST /messages
  Future<MessageModel> sendMessage({
    required int receiverId,
    required String content,
    String type = 'TEXT',
  });
}

@LazySingleton(as: ChatRemoteDataSource)
class ChatRemoteDataSourceImpl implements ChatRemoteDataSource {
  final DioClient _dioClient;

  ChatRemoteDataSourceImpl(this._dioClient);

  @override
  Future<List<ConversationModel>> getConversations() async {
    final response = await _dioClient.get(
      AppConstants.conversationsEndpoint,
    );

    final List<dynamic> data = response.data is List
        ? response.data
        : (response.data['data'] as List? ?? []);

    int currentUserId = 0;
    try {
      final authLocal = GetIt.I<AuthLocalDataSource>();
      final token = await authLocal.getAccessToken();
      if (token != null && token.isNotEmpty) {
        final parts = token.split('.');
        if (parts.length == 3) {
          String payloadStr = parts[1];
          while (payloadStr.length % 4 != 0) {
            payloadStr += '=';
          }
          final payloadMap = jsonDecode(utf8.decode(base64Url.decode(payloadStr)));
          final tempId = payloadMap['userId'] ?? payloadMap['id'] ?? payloadMap['sub'] ?? 0;
          currentUserId = tempId is num ? tempId.toInt() : (int.tryParse(tempId.toString()) ?? 0);
        }
      }
    } catch (_) {}

    return data.map((item) {
      final map = Map<String, dynamic>.from(item as Map<String, dynamic>);
      if (map['userA'] != null && map['userB'] != null) {
        final rawUserAId = map['userAId'] ?? map['userA']['id'] ?? map['userA']['userId'];
        final userAId = rawUserAId is num ? rawUserAId.toInt() : (int.tryParse(rawUserAId?.toString() ?? '0') ?? 0);
        if (userAId == currentUserId && currentUserId != 0) {
          map['otherUser'] = map['userB'];
        } else {
          map['otherUser'] = map['userA'];
        }
      }
      return ConversationModel.fromJson(map);
    }).toList();
  }

  @override
  Future<List<MessageModel>> getMessages(int conversationId) async {
    final response = await _dioClient.get(
      '${AppConstants.conversationsEndpoint}/$conversationId',
    );

    final List<dynamic> data = response.data is List
        ? response.data
        : (response.data['data'] as List? ?? []);

    return data
        .map((item) => MessageModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<MessageModel> sendMessage({
    required int receiverId,
    required String content,
    String type = 'TEXT',
  }) async {
    final response = await _dioClient.post(
      AppConstants.messagesEndpoint,
      data: {
        'receiverId': receiverId,
        'content': content,
        'type': type,
      },
    );

    final data = response.data is Map<String, dynamic>
        ? response.data as Map<String, dynamic>
        : <String, dynamic>{};

    return MessageModel.fromJson(data);
  }
}
