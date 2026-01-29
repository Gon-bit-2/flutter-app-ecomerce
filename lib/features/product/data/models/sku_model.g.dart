// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sku_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SKUModel _$SKUModelFromJson(Map<String, dynamic> json) => SKUModel(
  id: (json['id'] as num).toInt(),
  value: json['value'] as String,
  price: (json['price'] as num).toDouble(),
  stock: (json['stock'] as num).toInt(),
  image: json['image'] as String,
  productId: (json['productId'] as num).toInt(),
);

Map<String, dynamic> _$SKUModelToJson(SKUModel instance) => <String, dynamic>{
  'id': instance.id,
  'value': instance.value,
  'price': instance.price,
  'stock': instance.stock,
  'image': instance.image,
  'productId': instance.productId,
};
