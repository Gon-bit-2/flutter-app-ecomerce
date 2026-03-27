import 'package:app_fe_ecomerce/core/error/failures.dart';
import 'package:app_fe_ecomerce/features/notification/data/datasources/notification_remote_datasource.dart';
import 'package:app_fe_ecomerce/features/notification/domain/entities/notification_entity.dart';
import 'package:app_fe_ecomerce/features/notification/domain/repositories/notification_repository.dart';
import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: NotificationRepository)
class NotificationRepositoryImpl implements NotificationRepository {
  final NotificationRemoteDataSource remoteDataSource;

  NotificationRepositoryImpl(this.remoteDataSource);

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
      return ServerFailure(e.message ?? "Unknown Error");
    } catch (_) {
      return ServerFailure(e.message ?? "Unknown Error");
    }
  }

  @override
  Future<Either<Failure, List<NotificationEntity>>> getNotifications({
    int page = 1,
    int limit = 10,
    bool? isRead,
  }) async {
    try {
      final notifications = await remoteDataSource.getNotifications(
        page: page,
        limit: limit,
        isRead: isRead,
      );
      return Right(notifications);
    } on DioException catch (e) {
      return Left(_handleError(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> markAsRead(int notificationId) async {
    try {
      await remoteDataSource.markAsRead(notificationId);
      return const Right(null);
    } on DioException catch (e) {
      return Left(_handleError(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> markAllAsRead() async {
    try {
      await remoteDataSource.markAllAsRead();
      return const Right(null);
    } on DioException catch (e) {
      return Left(_handleError(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Stream<NotificationEntity> get realtimeNotifications =>
      remoteDataSource.realtimeNotifications;

  @override
  void connectSocket(String accessToken) {
    remoteDataSource.connectSocket(accessToken);
  }

  @override
  void disconnectSocket() {
    remoteDataSource.disconnectSocket();
  }
}
