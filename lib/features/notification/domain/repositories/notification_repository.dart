import 'package:app_fe_ecomerce/core/error/failures.dart';
import 'package:app_fe_ecomerce/features/notification/domain/entities/notification_entity.dart';
import 'package:fpdart/fpdart.dart';

abstract class NotificationRepository {
  Future<Either<Failure, List<NotificationEntity>>> getNotifications({
    int page = 1,
    int limit = 10,
    bool? isRead,
  });

  Future<Either<Failure, void>> markAsRead(int notificationId);

  Future<Either<Failure, void>> markAllAsRead();

  Stream<NotificationEntity> get realtimeNotifications;

  void connectSocket(String accessToken);

  void disconnectSocket();
}
