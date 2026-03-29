// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Map<String, dynamic> _$OrderModelToJson(OrderModel instance) =>
    <String, dynamic>{
      'stringify': instance.stringify,
      'hashCode': instance.hashCode,
      'id': instance.id,
      'shopId': instance.shopId,
      'status': instance.status,
      'totalAmount': instance.totalAmount,
      'receiverName': instance.receiverName,
      'receiverPhone': instance.receiverPhone,
      'receiverAddress': instance.receiverAddress,
      'paymentMethod': instance.paymentMethod,
      'paymentId': instance.paymentId,
      'createdAt': instance.createdAt?.toIso8601String(),
      'props': instance.props,
      'items': instance.items?.map((e) => e.toJson()).toList(),
    };
