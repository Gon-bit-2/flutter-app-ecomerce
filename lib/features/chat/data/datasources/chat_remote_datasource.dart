import 'package:app_fe_ecomerce/core/constants/app_constants.dart';
import 'package:app_fe_ecomerce/core/network/dio_client.dart';
import 'package:app_fe_ecomerce/features/chat/data/models/conversation_model.dart';
import 'package:app_fe_ecomerce/features/chat/data/models/message_model.dart';
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

    return data
        .map((item) => ConversationModel.fromJson(item as Map<String, dynamic>))
        .toList();
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
