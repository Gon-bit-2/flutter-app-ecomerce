import 'package:app_fe_ecomerce/core/error/failures.dart';
import 'package:app_fe_ecomerce/core/usecase/usecase.dart';
import 'package:app_fe_ecomerce/features/chat/domain/entities/message_entity.dart';
import 'package:app_fe_ecomerce/features/chat/domain/repositories/chat_repository.dart';
import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';

@injectable
class SendMessageUseCase implements UseCase<MessageEntity, SendMessageParams> {
  final ChatRepository repository;

  SendMessageUseCase(this.repository);

  @override
  Future<Either<Failure, MessageEntity>> call(SendMessageParams params) {
    return repository.sendMessage(
      receiverId: params.receiverId,
      content: params.content,
      type: params.type,
    );
  }
}

class SendMessageParams {
  final int receiverId;
  final String content;
  final String type;

  const SendMessageParams({
    required this.receiverId,
    required this.content,
    this.type = 'TEXT',
  });
}
