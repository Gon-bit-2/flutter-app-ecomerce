import 'package:app_fe_ecomerce/core/error/failures.dart';
import 'package:app_fe_ecomerce/features/chat/data/datasources/chat_remote_datasource.dart';
import 'package:app_fe_ecomerce/features/chat/domain/entities/conversation_entity.dart';
import 'package:app_fe_ecomerce/features/chat/domain/entities/message_entity.dart';
import 'package:app_fe_ecomerce/features/chat/domain/repositories/chat_repository.dart';
import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: ChatRepository)
class ChatRepositoryImpl implements ChatRepository {
  final ChatRemoteDataSource remoteDataSource;

  ChatRepositoryImpl(this.remoteDataSource);

  ServerFailure _handleError(DioException e) {
    try {
      if (e.response?.data != null) {
        final msg = e.response!.data['message'];
        if (msg is String) {
          return ServerFailure(msg);
        } else if (msg is List && msg.isNotEmpty) {
          final first = msg.first;
          if (first is Map && first.containsKey('message')) {
            return ServerFailure(first['message']);
          }
          return ServerFailure(msg.toString());
        }
      }
      return ServerFailure(e.message ?? "Lỗi không xác định");
    } catch (_) {
      return ServerFailure(e.message ?? "Lỗi không xác định");
    }
  }

  @override
  Future<Either<Failure, List<ConversationEntity>>> getConversations() async {
    try {
      final conversations = await remoteDataSource.getConversations();
      return Right(conversations);
    } on DioException catch (e) {
      return Left(_handleError(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<MessageEntity>>> getMessages(int conversationId) async {
    try {
      final messages = await remoteDataSource.getMessages(conversationId);
      return Right(messages);
    } on DioException catch (e) {
      return Left(_handleError(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, MessageEntity>> sendMessage({
    required int receiverId,
    required String content,
    String type = 'TEXT',
  }) async {
    try {
      final message = await remoteDataSource.sendMessage(
        receiverId: receiverId,
        content: content,
        type: type,
      );
      return Right(message);
    } on DioException catch (e) {
      return Left(_handleError(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
