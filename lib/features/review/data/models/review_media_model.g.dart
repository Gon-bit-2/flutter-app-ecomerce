// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'review_media_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ReviewMediaModel _$ReviewMediaModelFromJson(Map<String, dynamic> json) =>
    ReviewMediaModel(
      url: json['url'] as String,
      type: ReviewMediaModel._mediaTypeFromString(json['type'] as String?),
    );

Map<String, dynamic> _$ReviewMediaModelToJson(ReviewMediaModel instance) =>
    <String, dynamic>{
      'url': instance.url,
      'type': ReviewMediaModel._mediaTypeToString(instance.type),
    };
