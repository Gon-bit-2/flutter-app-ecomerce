import 'package:equatable/equatable.dart';

class OrderEntity extends Equatable {
  final int id;
  // TODO: Add other fields based on API list response if available. We don't have order GET response structure entirely.
  // Using basic standard e-commerce fields
  final int? shopId;
  final String? status;
  final num? totalAmount;
  final String? receiverName;
  final String? receiverPhone;
  final String? receiverAddress;
  final String? paymentMethod;
  final List<OrderItemEntity>? items;
  final DateTime? createdAt;

  const OrderEntity({
    required this.id,
    this.shopId,
    this.status,
    this.totalAmount,
    this.receiverName,
    this.receiverPhone,
    this.receiverAddress,
    this.paymentMethod,
    this.items,
    this.createdAt,
  });

  @override
  List<Object?> get props => [
    id,
    shopId,
    status,
    totalAmount,
    receiverName,
    receiverPhone,
    receiverAddress,
    paymentMethod,
    items,
    createdAt,
  ];
}

class OrderItemEntity extends Equatable {
  final int id;
  final int skuId;
  final String? productName;
  final String? skuValue;
  final String? image;
  final num price;
  final int quantity;

  const OrderItemEntity({
    required this.id,
    required this.skuId,
    this.productName,
    this.skuValue,
    this.image,
    required this.price,
    required this.quantity,
  });

  @override
  List<Object?> get props => [
    id,
    skuId,
    productName,
    skuValue,
    image,
    price,
    quantity,
  ];
}
