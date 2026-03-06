import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/order_entity.dart';

part 'order_model.g.dart';

@JsonSerializable(explicitToJson: true)
class OrderModel extends OrderEntity {
  @override
  final List<OrderItemModel>? items;

  const OrderModel({
    required super.id,
    super.shopId,
    super.status,
    super.totalAmount,
    super.receiverName,
    super.receiverPhone,
    super.receiverAddress,
    this.items,
    super.createdAt,
  }) : super(items: items);

  factory OrderModel.fromJson(Map<String, dynamic> json) =>
      _$OrderModelFromJson(json);

  Map<String, dynamic> toJson() => _$OrderModelToJson(this);
}

@JsonSerializable()
class OrderItemModel extends OrderItemEntity {
  const OrderItemModel({
    required super.id,
    required super.skuId,
    super.productName,
    super.skuValue,
    super.image,
    required super.price,
    required super.quantity,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) =>
      _$OrderItemModelFromJson(json);

  Map<String, dynamic> toJson() => _$OrderItemModelToJson(this);
}
