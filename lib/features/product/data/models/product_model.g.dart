// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProductModel _$ProductModelFromJson(Map<String, dynamic> json) => ProductModel(
  id: (json['id'] as num).toInt(),
  name: json['name'] as String,
  basePrice: (json['basePrice'] as num).toDouble(),
  virtualPrice: (json['virtualPrice'] as num?)?.toDouble(),
  images: (json['images'] as List<dynamic>).map((e) => e as String).toList(),
  brandId: (json['brandId'] as num).toInt(),
  brandName: json['brandName'] as String?,
  categoryIds: (json['categoryIds'] as List<dynamic>?)
      ?.map((e) => (e as num).toInt())
      .toList(),
  publishedAt: json['publishedAt'] == null
      ? null
      : DateTime.parse(json['publishedAt'] as String),
  skus:
      (json['skus'] as List<dynamic>?)
          ?.map((e) => SKUModel.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  variants: json['variants'] as List<dynamic>?,
  description: json['description'] as String?,
  createdById: (json['createdById'] as num?)?.toInt(),
  shopName: json['shopName'] as String?,
  shopAvatar: json['shopAvatar'] as String?,
  rating: (json['rating'] as num?)?.toDouble(),
  sold: (json['sold'] as num?)?.toInt(),
  isMall: json['isMall'] as bool? ?? false,
  isPreferred: json['isPreferred'] as bool? ?? false,
);

Map<String, dynamic> _$ProductModelToJson(ProductModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'basePrice': instance.basePrice,
      'virtualPrice': instance.virtualPrice,
      'images': instance.images,
      'brandId': instance.brandId,
      'brandName': instance.brandName,
      'categoryIds': instance.categoryIds,
      'publishedAt': instance.publishedAt?.toIso8601String(),
      'variants': instance.variants,
      'description': instance.description,
      'createdById': instance.createdById,
      'shopName': instance.shopName,
      'shopAvatar': instance.shopAvatar,
      'rating': instance.rating,
      'sold': instance.sold,
      'isMall': instance.isMall,
      'isPreferred': instance.isPreferred,
      'skus': instance.skus.map((e) => e.toJson()).toList(),
    };
