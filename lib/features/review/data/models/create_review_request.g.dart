// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_review_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CreateReviewRequest _$CreateReviewRequestFromJson(Map<String, dynamic> json) =>
    CreateReviewRequest(
      content: json['content'] as String,
      rating: (json['rating'] as num).toInt(),
      orderId: (json['orderId'] as num).toInt(),
      productId: (json['productId'] as num).toInt(),
      medias:
          (json['medias'] as List<dynamic>?)
              ?.map((e) => Map<String, String>.from(e as Map))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$CreateReviewRequestToJson(
  CreateReviewRequest instance,
) => <String, dynamic>{
  'content': instance.content,
  'rating': instance.rating,
  'orderId': instance.orderId,
  'productId': instance.productId,
  'medias': instance.medias,
};
