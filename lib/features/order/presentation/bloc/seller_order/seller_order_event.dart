part of 'seller_order_bloc.dart';

abstract class SellerOrderEvent extends Equatable {
  const SellerOrderEvent();

  @override
  List<Object?> get props => [];
}

class SellerOrdersLoadRequested extends SellerOrderEvent {
  final int page;
  final int limit;
  final String? status;

  const SellerOrdersLoadRequested({
    this.page = 1,
    this.limit = 10,
    this.status,
  });

  @override
  List<Object?> get props => [page, limit, status];
}

class SellerOrderStatusUpdateRequested extends SellerOrderEvent {
  final int orderId;
  final String status;

  const SellerOrderStatusUpdateRequested({
    required this.orderId,
    required this.status,
  });

  @override
  List<Object?> get props => [orderId, status];
}
