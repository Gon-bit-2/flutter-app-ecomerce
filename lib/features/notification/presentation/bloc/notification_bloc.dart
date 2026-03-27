import 'dart:async';
import 'package:app_fe_ecomerce/core/usecase/usecase.dart';
import 'package:app_fe_ecomerce/features/notification/domain/entities/notification_entity.dart';
import 'package:app_fe_ecomerce/features/notification/domain/repositories/notification_repository.dart';
import 'package:app_fe_ecomerce/features/notification/domain/usecases/get_notifications_usecase.dart';
import 'package:app_fe_ecomerce/features/notification/domain/usecases/mark_all_notifications_as_read_usecase.dart';
import 'package:app_fe_ecomerce/features/notification/domain/usecases/mark_notification_as_read_usecase.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

part 'notification_event.dart';
part 'notification_state.dart';

@injectable
class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  final GetNotificationsUseCase _getNotificationsUseCase;
  final MarkNotificationAsReadUseCase _markAsReadUseCase;
  final MarkAllNotificationsAsReadUseCase _markAllAsReadUseCase;
  final NotificationRepository _repository;
  StreamSubscription<NotificationEntity>? _realtimeSubscription;

  NotificationBloc(
    this._getNotificationsUseCase,
    this._markAsReadUseCase,
    this._markAllAsReadUseCase,
    this._repository,
  ) : super(const NotificationState()) {
    on<NotificationStarted>(_onStarted);
    on<NotificationLoadMore>(_onLoadMore);
    on<NotificationRefreshed>(_onRefreshed);
    on<NotificationMarkAsRead>(_onMarkAsRead);
    on<NotificationMarkAllAsRead>(_onMarkAllAsRead);
    on<NotificationReceived>(_onReceived);
    on<NotificationSocketConnected>(_onSocketConnected);
    on<NotificationSocketDisconnected>(_onSocketDisconnected);
  }

  Future<void> _onStarted(
    NotificationStarted event,
    Emitter<NotificationState> emit,
  ) async {
    emit(state.copyWith(status: NotificationStatus.loading));
    final result = await _getNotificationsUseCase(
      const GetNotificationsParams(page: 1, limit: 15),
    );
    result.fold(
      (failure) => emit(state.copyWith(
        status: NotificationStatus.failure,
        errorMessage: failure.message,
      )),
      (notifications) {
        final unreadCount =
            notifications.where((n) => !n.isRead).length;
        emit(state.copyWith(
          status: NotificationStatus.success,
          notifications: notifications,
          unreadCount: unreadCount,
          hasReachedMax: notifications.length < 15,
          currentPage: 1,
        ));
      },
    );
  }

  Future<void> _onLoadMore(
    NotificationLoadMore event,
    Emitter<NotificationState> emit,
  ) async {
    if (state.hasReachedMax) return;
    final nextPage = state.currentPage + 1;
    final result = await _getNotificationsUseCase(
      GetNotificationsParams(page: nextPage, limit: 15),
    );
    result.fold(
      (failure) => emit(state.copyWith(
        errorMessage: failure.message,
      )),
      (notifications) {
        emit(state.copyWith(
          notifications: [...state.notifications, ...notifications],
          hasReachedMax: notifications.length < 15,
          currentPage: nextPage,
        ));
      },
    );
  }

  Future<void> _onRefreshed(
    NotificationRefreshed event,
    Emitter<NotificationState> emit,
  ) async {
    final result = await _getNotificationsUseCase(
      const GetNotificationsParams(page: 1, limit: 15),
    );
    result.fold(
      (failure) => emit(state.copyWith(
        errorMessage: failure.message,
      )),
      (notifications) {
        final unreadCount =
            notifications.where((n) => !n.isRead).length;
        emit(state.copyWith(
          status: NotificationStatus.success,
          notifications: notifications,
          unreadCount: unreadCount,
          hasReachedMax: notifications.length < 15,
          currentPage: 1,
        ));
      },
    );
  }

  Future<void> _onMarkAsRead(
    NotificationMarkAsRead event,
    Emitter<NotificationState> emit,
  ) async {
    // Optimistic update
    final updatedList = state.notifications.map((n) {
      if (n.id == event.notificationId) {
        return NotificationEntity(
          id: n.id,
          title: n.title,
          body: n.body,
          type: n.type,
          data: n.data,
          isRead: true,
          createdAt: n.createdAt,
        );
      }
      return n;
    }).toList();
    final newUnread = updatedList.where((n) => !n.isRead).length;
    emit(state.copyWith(notifications: updatedList, unreadCount: newUnread));
    await _markAsReadUseCase(event.notificationId);
  }

  Future<void> _onMarkAllAsRead(
    NotificationMarkAllAsRead event,
    Emitter<NotificationState> emit,
  ) async {
    // Optimistic update
    final updatedList = state.notifications.map((n) {
      return NotificationEntity(
        id: n.id,
        title: n.title,
        body: n.body,
        type: n.type,
        data: n.data,
        isRead: true,
        createdAt: n.createdAt,
      );
    }).toList();
    emit(state.copyWith(notifications: updatedList, unreadCount: 0));
    await _markAllAsReadUseCase(NoParams());
  }

  void _onReceived(
    NotificationReceived event,
    Emitter<NotificationState> emit,
  ) {
    final updated = [event.notification, ...state.notifications];
    emit(state.copyWith(
      notifications: updated,
      unreadCount: state.unreadCount + 1,
    ));
  }

  void _onSocketConnected(
    NotificationSocketConnected event,
    Emitter<NotificationState> emit,
  ) {
    _repository.connectSocket(event.accessToken);
    _realtimeSubscription?.cancel();
    _realtimeSubscription = _repository.realtimeNotifications.listen(
      (notification) {
        add(NotificationReceived(notification: notification));
      },
    );
  }

  void _onSocketDisconnected(
    NotificationSocketDisconnected event,
    Emitter<NotificationState> emit,
  ) {
    _realtimeSubscription?.cancel();
    _realtimeSubscription = null;
    _repository.disconnectSocket();
  }

  @override
  Future<void> close() {
    _realtimeSubscription?.cancel();
    _repository.disconnectSocket();
    return super.close();
  }
}
