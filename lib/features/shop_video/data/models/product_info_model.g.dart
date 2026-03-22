// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_info_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProductInfoModel _$ProductInfoModelFromJson(Map<String, dynamic> json) =>
    ProductInfoModel(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      basePrice: json['basePrice'] as num,
      virtualPrice: json['virtualPrice'] as num?,
      images:
          (json['images'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
    );

Map<String, dynamic> _$ProductInfoModelToJson(ProductInfoModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'basePrice': instance.basePrice,
      'virtualPrice': instance.virtualPrice,
      'images': instance.images,
    };
