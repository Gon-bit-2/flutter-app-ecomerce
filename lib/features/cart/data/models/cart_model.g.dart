// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cart_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CartModel _$CartModelFromJson(Map<String, dynamic> json) => CartModel(
  id: (json['id'] as num).toInt(),
  skuId: (json['skuId'] as num).toInt(),
  quantity: (json['quantity'] as num).toInt(),
  productId: (json['productId'] as num?)?.toInt(),
  productName: json['productName'] as String?,
  image: json['image'] as String?,
  skuValue: json['skuValue'] as String?,
  price: json['price'] as num?,
);

Map<String, dynamic> _$CartModelToJson(CartModel instance) => <String, dynamic>{
  'id': instance.id,
  'skuId': instance.skuId,
  'quantity': instance.quantity,
  'productId': instance.productId,
  'productName': instance.productName,
  'image': instance.image,
  'skuValue': instance.skuValue,
  'price': instance.price,
};
