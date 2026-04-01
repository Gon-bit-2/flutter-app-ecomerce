// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shop_video_comment_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ShopVideoCommentModel _$ShopVideoCommentModelFromJson(
  Map<String, dynamic> json,
) => ShopVideoCommentModel(
  id: (json['id'] as num).toInt(),
  content: json['content'] as String,
  createdAt: DateTime.parse(json['createdAt'] as String),
  user: json['user'] == null
      ? null
      : UserModel.fromJson(json['user'] as Map<String, dynamic>),
  parentId: (json['parentId'] as num?)?.toInt(),
  replies:
      (json['replies'] as List<dynamic>?)
          ?.map(
            (e) => ShopVideoCommentModel.fromJson(e as Map<String, dynamic>),
          )
          .toList() ??
      [],
);

Map<String, dynamic> _$ShopVideoCommentModelToJson(
  ShopVideoCommentModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'content': instance.content,
  'createdAt': instance.createdAt.toIso8601String(),
  'parentId': instance.parentId,
  'user': instance.user?.toJson(),
  'replies': instance.replies.map((e) => e.toJson()).toList(),
};
