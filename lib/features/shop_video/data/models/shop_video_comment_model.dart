import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/shop_video_comment.dart';
import '../../../auth/data/models/user_model.dart';

part 'shop_video_comment_model.g.dart';

@JsonSerializable(explicitToJson: true)
class ShopVideoCommentModel extends ShopVideoComment {
  @override
  final UserModel? user;
  
  @override
  @JsonKey(defaultValue: [])
  final List<ShopVideoCommentModel> replies;

  const ShopVideoCommentModel({
    required super.id,
    required super.content,
    required super.createdAt,
    this.user,
    super.parentId,
    this.replies = const [],
  }) : super(user: user, replies: replies);

  factory ShopVideoCommentModel.fromJson(Map<String, dynamic> json) {
    // Xử lý an toàn cho các trường có thể bị null từ API
    // API comment trả về user thiếu trường email → thêm fallback
    final safeJson = <String, dynamic>{
      ...json,
      'replies': json['replies'] ?? [],
    };
    
    // Đảm bảo user object có đủ các trường bắt buộc cho UserModel
    if (safeJson['user'] != null && safeJson['user'] is Map<String, dynamic>) {
      final userMap = Map<String, dynamic>.from(safeJson['user'] as Map<String, dynamic>);
      userMap['email'] = userMap['email'] ?? '';
      userMap['name'] = userMap['name'] ?? 'Người dùng';
      safeJson['user'] = userMap;
    }
    
    return _$ShopVideoCommentModelFromJson(safeJson);
  }

  Map<String, dynamic> toJson() => _$ShopVideoCommentModelToJson(this);
}
