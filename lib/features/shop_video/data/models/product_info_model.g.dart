// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_info_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProductInfoModel _$ProductInfoModelFromJson(Map<String, dynamic> json) =>
    ProductInfoModel(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      basePrice: json['base_price'] as num,
      virtualPrice: json['virtual_price'] as num?,
      images:
          (json['images'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      defaultSkuId: (json['default_sku_id'] as num?)?.toInt(),
      hasVariants: json['has_variants'] as bool? ?? false,
    );

Map<String, dynamic> _$ProductInfoModelToJson(ProductInfoModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'base_price': instance.basePrice,
      'virtual_price': instance.virtualPrice,
      'images': instance.images,
      'default_sku_id': instance.defaultSkuId,
      'has_variants': instance.hasVariants,
    };
