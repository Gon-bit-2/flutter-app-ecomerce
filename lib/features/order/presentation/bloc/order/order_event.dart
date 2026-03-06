part of 'order_bloc.dart';

abstract class OrderEvent extends Equatable {
  const OrderEvent();

  @override
  List<Object?> get props => [];
}

class OrderCreateRequested extends OrderEvent {
  final List<ShopOrderParams> orders;

  const OrderCreateRequested({required this.orders});

  @override
  List<Object?> get props => [orders];
}

class OrdersLoadRequested extends OrderEvent {
  final int page;
  final int limit;
  final String? status;

  const OrdersLoadRequested({this.page = 1, this.limit = 10, this.status});

  @override
  List<Object?> get props => [page, limit, status];
}

class OrderDetailRequested extends OrderEvent {
  final int orderId;

  const OrderDetailRequested({required this.orderId});

  @override
  List<Object?> get props => [orderId];
}

class OrderCancelRequested extends OrderEvent {
  final int orderId;

  const OrderCancelRequested({required this.orderId});

  @override
  List<Object?> get props => [orderId];
}
