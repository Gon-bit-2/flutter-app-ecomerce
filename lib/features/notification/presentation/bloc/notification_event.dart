part of 'notification_bloc.dart';

abstract class NotificationEvent extends Equatable {
  const NotificationEvent();

  @override
  List<Object?> get props => [];
}

/// Khởi tạo – load danh sách notification lần đầu
class NotificationStarted extends NotificationEvent {}

/// Load thêm trang tiếp theo (infinite scroll)
class NotificationLoadMore extends NotificationEvent {}

/// Kéo refresh lại từ đầu
class NotificationRefreshed extends NotificationEvent {}

/// Đánh dấu 1 notification là đã đọc
class NotificationMarkAsRead extends NotificationEvent {
  final int notificationId;

  const NotificationMarkAsRead({required this.notificationId});

  @override
  List<Object?> get props => [notificationId];
}

/// Đánh dấu tất cả notification đã đọc
class NotificationMarkAllAsRead extends NotificationEvent {}

/// Nhận notification mới từ WebSocket
class NotificationReceived extends NotificationEvent {
  final NotificationEntity notification;

  const NotificationReceived({required this.notification});

  @override
  List<Object?> get props => [notification];
}

/// Kết nối WebSocket
class NotificationSocketConnected extends NotificationEvent {
  final String accessToken;

  const NotificationSocketConnected({required this.accessToken});

  @override
  List<Object?> get props => [accessToken];
}

/// Ngắt kết nối WebSocket
class NotificationSocketDisconnected extends NotificationEvent {}
