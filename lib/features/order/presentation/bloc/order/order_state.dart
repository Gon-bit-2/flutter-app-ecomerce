part of 'order_bloc.dart';

abstract class OrderState extends Equatable {
  const OrderState();

  @override
  List<Object?> get props => [];
}

class OrderInitial extends OrderState {}

class OrderLoading extends OrderState {}

class OrderCreated extends OrderState {}

class OrdersLoaded extends OrderState {
  final List<OrderEntity> orders;
  final bool hasReachedMax;

  const OrdersLoaded({required this.orders, this.hasReachedMax = false});

  @override
  List<Object?> get props => [orders, hasReachedMax];
}

class OrderDetailLoaded extends OrderState {
  final OrderEntity order;

  const OrderDetailLoaded({required this.order});

  @override
  List<Object?> get props => [order];
}

class OrderCancelled extends OrderState {}

class OrderFailure extends OrderState {
  final String message;

  const OrderFailure(this.message);

  @override
  List<Object?> get props => [message];
}
