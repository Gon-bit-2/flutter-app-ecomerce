part of 'seller_order_bloc.dart';

abstract class SellerOrderState extends Equatable {
  const SellerOrderState();

  @override
  List<Object?> get props => [];
}

class SellerOrderInitial extends SellerOrderState {}

class SellerOrderLoading extends SellerOrderState {}

class SellerOrdersLoaded extends SellerOrderState {
  final List<OrderEntity> orders;
  final bool hasReachedMax;

  const SellerOrdersLoaded({required this.orders, this.hasReachedMax = false});

  @override
  List<Object?> get props => [orders, hasReachedMax];
}

class SellerOrderStatusUpdated extends SellerOrderState {}

class SellerOrderFailure extends SellerOrderState {
  final String message;

  const SellerOrderFailure(this.message);

  @override
  List<Object?> get props => [message];
}
