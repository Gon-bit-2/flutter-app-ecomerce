// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OrderModel _$OrderModelFromJson(Map<String, dynamic> json) => OrderModel(
  id: (json['id'] as num).toInt(),
  shopId: (json['shopId'] as num?)?.toInt(),
  status: json['status'] as String?,
  totalAmount: json['totalAmount'] as num?,
  receiverName: json['receiverName'] as String?,
  receiverPhone: json['receiverPhone'] as String?,
  receiverAddress: json['receiverAddress'] as String?,
  items: (json['items'] as List<dynamic>?)
      ?.map((e) => OrderItemModel.fromJson(e as Map<String, dynamic>))
      .toList(),
  createdAt: json['createdAt'] == null
      ? null
      : DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$OrderModelToJson(OrderModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'shopId': instance.shopId,
      'status': instance.status,
      'totalAmount': instance.totalAmount,
      'receiverName': instance.receiverName,
      'receiverPhone': instance.receiverPhone,
      'receiverAddress': instance.receiverAddress,
      'createdAt': instance.createdAt?.toIso8601String(),
      'items': instance.items?.map((e) => e.toJson()).toList(),
    };

OrderItemModel _$OrderItemModelFromJson(Map<String, dynamic> json) =>
    OrderItemModel(
      id: (json['id'] as num).toInt(),
      skuId: (json['skuId'] as num).toInt(),
      productName: json['productName'] as String?,
      skuValue: json['skuValue'] as String?,
      image: json['image'] as String?,
      price: json['price'] as num,
      quantity: (json['quantity'] as num).toInt(),
    );

Map<String, dynamic> _$OrderItemModelToJson(OrderItemModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'skuId': instance.skuId,
      'productName': instance.productName,
      'skuValue': instance.skuValue,
      'image': instance.image,
      'price': instance.price,
      'quantity': instance.quantity,
    };
