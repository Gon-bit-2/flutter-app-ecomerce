// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shop_video_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ShopVideoModel _$ShopVideoModelFromJson(Map<String, dynamic> json) =>
    ShopVideoModel(
      id: (json['id'] as num).toInt(),
      caption: json['caption'] as String?,
      videoUrl: json['videoUrl'] as String,
      thumbnailUrl: json['thumbnailUrl'] as String?,
      status: $enumDecode(_$ShopVideoStatusEnumMap, json['status']),
      shopId: (json['shopId'] as num).toInt(),
      likeCount: (json['likeCount'] as num?)?.toInt() ?? 0,
      commentCount: (json['commentCount'] as num?)?.toInt() ?? 0,
      isLiked: json['isLiked'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
      shop: json['shop'] == null
          ? null
          : ShopInfoModel.fromJson(json['shop'] as Map<String, dynamic>),
      products:
          (json['products'] as List<dynamic>?)
              ?.map((e) => ProductInfoModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$ShopVideoModelToJson(ShopVideoModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'caption': instance.caption,
      'videoUrl': instance.videoUrl,
      'thumbnailUrl': instance.thumbnailUrl,
      'status': _$ShopVideoStatusEnumMap[instance.status]!,
      'shopId': instance.shopId,
      'likeCount': instance.likeCount,
      'commentCount': instance.commentCount,
      'isLiked': instance.isLiked,
      'createdAt': instance.createdAt.toIso8601String(),
      'shop': instance.shop?.toJson(),
      'products': instance.products.map((e) => e.toJson()).toList(),
    };

const _$ShopVideoStatusEnumMap = {
  ShopVideoStatus.ACTIVE: 'ACTIVE',
  ShopVideoStatus.INACTIVE: 'INACTIVE',
};
