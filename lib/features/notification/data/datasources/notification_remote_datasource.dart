import 'dart:async';
import 'package:app_fe_ecomerce/core/constants/app_constants.dart';
import 'package:app_fe_ecomerce/core/network/dio_client.dart';
import 'package:app_fe_ecomerce/features/notification/data/models/notification_model.dart';
import 'package:injectable/injectable.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

abstract class NotificationRemoteDataSource {
  Future<List<NotificationModel>> getNotifications({
    int? page,
    int? limit,
    bool? isRead,
  });

  Future<void> markAsRead(int notificationId);

  Future<void> markAllAsRead();

  Stream<NotificationModel> get realtimeNotifications;

  void connectSocket(String accessToken);

  void disconnectSocket();
}

@LazySingleton(as: NotificationRemoteDataSource)
class NotificationRemoteDataSourceImpl implements NotificationRemoteDataSource {
  final DioClient _dioClient;
  IO.Socket? _socket;
  final StreamController<NotificationModel> _notificationStreamController =
      StreamController<NotificationModel>.broadcast();

  NotificationRemoteDataSourceImpl(this._dioClient);

  @override
  Future<List<NotificationModel>> getNotifications({
    int? page,
    int? limit,
    bool? isRead,
  }) async {
    final queryParams = <String, dynamic>{
      if (page != null) 'page': page,
      if (limit != null) 'limit': limit,
      if (isRead != null) 'isRead': isRead,
    };
    final response = await _dioClient.get(
      AppConstants.notificationsEndpoint,
      queryParameters: queryParams,
    );
    final List<dynamic> data = response.data is List
        ? response.data
        : (response.data['data'] as List? ?? []);
    return data
        .map((item) =>
            NotificationModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> markAsRead(int notificationId) async {
    await _dioClient.patch(
      '${AppConstants.notificationsEndpoint}/$notificationId/read',
    );
  }

  @override
  Future<void> markAllAsRead() async {
    await _dioClient.patch(
      '${AppConstants.notificationsReadAllEndpoint}',
    );
  }

  @override
  Stream<NotificationModel> get realtimeNotifications =>
      _notificationStreamController.stream;

  @override
  void connectSocket(String accessToken) {
    _socket?.dispose();
    _socket = IO.io(
      AppConstants.baseUrl,
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .setExtraHeaders({'Authorization': 'Bearer $accessToken'})
          .disableAutoConnect()
          .build(),
    );

    _socket!.connect();

    _socket!.on('new-notification', (data) {
      if (data is Map<String, dynamic>) {
        final notification = NotificationModel.fromJson(data);
        _notificationStreamController.add(notification);
      } else if (data is Map) {
        final notification =
            NotificationModel.fromJson(Map<String, dynamic>.from(data));
        _notificationStreamController.add(notification);
      }
    });
  }

  @override
  void disconnectSocket() {
    _socket?.dispose();
    _socket = null;
  }

  void dispose() {
    disconnectSocket();
    _notificationStreamController.close();
  }
}
