import 'package:app_fe_ecomerce/core/error/failures.dart';
import 'package:app_fe_ecomerce/features/chat/domain/entities/conversation_entity.dart';
import 'package:app_fe_ecomerce/features/chat/domain/entities/message_entity.dart';
import 'package:fpdart/fpdart.dart';

abstract class ChatRepository {
  /// Lấy danh sách hội thoại của user hiện tại
  Future<Either<Failure, List<ConversationEntity>>> getConversations();

  /// Lấy danh sách tin nhắn trong 1 hội thoại
  Future<Either<Failure, List<MessageEntity>>> getMessages(int conversationId);

  /// Gửi tin nhắn đến người nhận
  Future<Either<Failure, MessageEntity>> sendMessage({
    required int receiverId,
    required String content,
    String type = 'TEXT',
  });
}
