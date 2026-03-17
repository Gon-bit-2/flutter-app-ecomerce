// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'review_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ReviewModel _$ReviewModelFromJson(Map<String, dynamic> json) => ReviewModel(
  id: (json['id'] as num).toInt(),
  content: json['content'] as String?,
  rating: (json['rating'] as num).toInt(),
  orderId: (json['orderId'] as num?)?.toInt(),
  productId: (json['productId'] as num).toInt(),
  createdAt: DateTime.parse(json['createdAt'] as String),
  user: json['user'] == null
      ? null
      : UserModel.fromJson(json['user'] as Map<String, dynamic>),
  medias:
      (json['medias'] as List<dynamic>?)
          ?.map((e) => ReviewMediaModel.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
);

Map<String, dynamic> _$ReviewModelToJson(ReviewModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'content': instance.content,
      'rating': instance.rating,
      'orderId': instance.orderId,
      'productId': instance.productId,
      'createdAt': instance.createdAt.toIso8601String(),
      'user': instance.user?.toJson(),
      'medias': instance.medias.map((e) => e.toJson()).toList(),
    };
