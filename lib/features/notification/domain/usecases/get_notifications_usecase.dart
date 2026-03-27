import 'package:app_fe_ecomerce/core/error/failures.dart';
import 'package:app_fe_ecomerce/core/usecase/usecase.dart';
import 'package:app_fe_ecomerce/features/notification/domain/entities/notification_entity.dart';
import 'package:app_fe_ecomerce/features/notification/domain/repositories/notification_repository.dart';
import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';

@injectable
class GetNotificationsUseCase
    implements UseCase<List<NotificationEntity>, GetNotificationsParams> {
  final NotificationRepository repository;

  GetNotificationsUseCase(this.repository);

  @override
  Future<Either<Failure, List<NotificationEntity>>> call(
    GetNotificationsParams params,
  ) {
    return repository.getNotifications(
      page: params.page,
      limit: params.limit,
      isRead: params.isRead,
    );
  }
}

class GetNotificationsParams {
  final int page;
  final int limit;
  final bool? isRead;

  const GetNotificationsParams({
    this.page = 1,
    this.limit = 10,
    this.isRead,
  });
}
