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
  final int? paymentId;
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
    this.paymentId,
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
    paymentId,
    items,
    createdAt,
  ];
}

class OrderItemEntity extends Equatable {
  final int id;
  final int skuId;
  final int? productId;
  final String? productName;
  final String? skuValue;
  final String? image;
  final num price;
  final int quantity;
  final bool isReviewed;

  const OrderItemEntity({
    required this.id,
    required this.skuId,
    this.productId,
    this.productName,
    this.skuValue,
    this.image,
    required this.price,
    required this.quantity,
    this.isReviewed = false,
  });

  @override
  List<Object?> get props => [
    id,
    skuId,
    productId,
    productName,
    skuValue,
    image,
    price,
    quantity,
    isReviewed,
  ];
}
