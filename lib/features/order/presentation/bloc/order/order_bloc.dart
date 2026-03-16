import 'package:app_fe_ecomerce/features/order/domain/entities/order_entity.dart';
import 'package:app_fe_ecomerce/features/order/domain/usecases/cancel_order_usecase.dart';
import 'package:app_fe_ecomerce/features/order/domain/usecases/create_order_usecase.dart';
import 'package:app_fe_ecomerce/features/order/domain/usecases/get_order_detail_usecase.dart';
import 'package:app_fe_ecomerce/features/order/domain/usecases/get_orders_usecase.dart';
import 'package:app_fe_ecomerce/features/order/domain/usecases/update_order_status_usecase.dart';
import 'package:app_fe_ecomerce/features/order/domain/entities/order_creation_result_entity.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

part 'order_event.dart';
part 'order_state.dart';

@injectable
class OrderBloc extends Bloc<OrderEvent, OrderState> {
  final CreateOrderUseCase _createOrderUseCase;
  final GetOrdersUseCase _getOrdersUseCase;
  final GetOrderDetailUseCase _getOrderDetailUseCase;
  final CancelOrderUseCase _cancelOrderUseCase;
  final UpdateOrderStatusUseCase _updateOrderStatusUseCase;

  OrderBloc(
    this._createOrderUseCase,
    this._getOrdersUseCase,
    this._getOrderDetailUseCase,
    this._cancelOrderUseCase,
    this._updateOrderStatusUseCase,
  ) : super(OrderInitial()) {
    on<OrderCreateRequested>((event, emit) async {
      emit(OrderLoading());
      final result = await _createOrderUseCase(
        CreateOrderParams(orders: event.orders),
      );
      result.fold(
        (failure) => emit(OrderFailure(failure.message)),
        (orderResult) => emit(OrderCreated(result: orderResult)),
      );
    });

    on<OrdersLoadRequested>((event, emit) async {
      if (event.page == 1) {
        emit(OrderLoading());
      }
      final result = await _getOrdersUseCase(
        GetOrdersParams(
          page: event.page,
          limit: event.limit,
          status: event.status,
        ),
      );
      result.fold((failure) => emit(OrderFailure(failure.message)), (orders) {
        if (state is OrdersLoaded && event.page > 1) {
          final currentOrders = (state as OrdersLoaded).orders;
          emit(
            OrdersLoaded(
              orders: currentOrders + orders,
              hasReachedMax: orders.length < event.limit,
            ),
          );
        } else {
          emit(
            OrdersLoaded(
              orders: orders,
              hasReachedMax: orders.length < event.limit,
            ),
          );
        }
      });
    });

    on<OrderDetailRequested>((event, emit) async {
      emit(OrderLoading());
      final result = await _getOrderDetailUseCase(event.orderId);
      result.fold(
        (failure) => emit(OrderFailure(failure.message)),
        (order) => emit(OrderDetailLoaded(order: order)),
      );
    });

    on<OrderCancelRequested>((event, emit) async {
      emit(OrderLoading());
      final result = await _cancelOrderUseCase(event.orderId);
      result.fold(
        (failure) => emit(OrderFailure(failure.message)),
        (_) => emit(OrderCancelled()),
      );
    });

    on<OrderUpdateStatusRequested>((event, emit) async {
      emit(OrderLoading());
      final result = await _updateOrderStatusUseCase(
        UpdateOrderStatusParams(orderId: event.orderId, status: event.status),
      );
      result.fold(
        (failure) => emit(OrderFailure(failure.message)),
        (_) => emit(OrderStatusUpdated()),
      );
    });
  }
}
