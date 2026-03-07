import 'package:app_fe_ecomerce/features/order/domain/entities/order_entity.dart';
import 'package:equatable/equatable.dart';

class OrderCreationResultEntity extends Equatable {
  final List<OrderEntity> orders;
  final int? paymentId;

  const OrderCreationResultEntity({required this.orders, this.paymentId});

  @override
  List<Object?> get props => [orders, paymentId];
}
