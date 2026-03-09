import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../domain/entities/order_entity.dart';
import '../../../domain/repositories/order_repository.dart';

part 'seller_order_event.dart';
part 'seller_order_state.dart';

@injectable
class SellerOrderBloc extends Bloc<SellerOrderEvent, SellerOrderState> {
  final OrderRepository _orderRepository;

  SellerOrderBloc(this._orderRepository) : super(SellerOrderInitial()) {
    on<SellerOrdersLoadRequested>(_onLoadRequested);
    on<SellerOrderStatusUpdateRequested>(_onStatusUpdateRequested);
  }

  Future<void> _onLoadRequested(
    SellerOrdersLoadRequested event,
    Emitter<SellerOrderState> emit,
  ) async {
    if (event.page == 1) {
      emit(SellerOrderLoading());
    }

    final result = await _orderRepository.getOrders(
      page: event.page,
      limit: event.limit,
      status: event.status,
    );

    result.fold((failure) => emit(SellerOrderFailure(failure.message)), (
      orders,
    ) {
      if (state is SellerOrdersLoaded && event.page > 1) {
        final currentOrders = (state as SellerOrdersLoaded).orders;
        emit(
          SellerOrdersLoaded(
            orders: currentOrders + orders,
            hasReachedMax: orders.length < event.limit,
          ),
        );
      } else {
        emit(
          SellerOrdersLoaded(
            orders: orders,
            hasReachedMax: orders.length < event.limit,
          ),
        );
      }
    });
  }

  Future<void> _onStatusUpdateRequested(
    SellerOrderStatusUpdateRequested event,
    Emitter<SellerOrderState> emit,
  ) async {
    emit(SellerOrderLoading());

    final result = await _orderRepository.updateOrderStatus(
      event.orderId,
      event.status,
    );

    result.fold((failure) => emit(SellerOrderFailure(failure.message)), (_) {
      emit(SellerOrderStatusUpdated());
      // Reload orders
      add(const SellerOrdersLoadRequested());
    });
  }
}
