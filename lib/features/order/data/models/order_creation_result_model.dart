import 'package:app_fe_ecomerce/features/order/domain/entities/order_creation_result_entity.dart';
import 'package:app_fe_ecomerce/features/order/data/models/order_model.dart';

class OrderCreationResultModel extends OrderCreationResultEntity {
  const OrderCreationResultModel({
    required List<OrderModel> orders,
    int? paymentId,
  }) : super(orders: orders, paymentId: paymentId);

  factory OrderCreationResultModel.fromJson(Map<String, dynamic> json) {
    return OrderCreationResultModel(
      orders:
          (json['orders'] as List<dynamic>?)
              ?.map((e) => OrderModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      paymentId: json['paymentId'] as int?,
    );
  }
}
