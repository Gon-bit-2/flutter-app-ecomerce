import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/review.dart';
import 'review_media_model.dart';
import '../../../auth/data/models/user_model.dart';

part 'review_model.g.dart';

@JsonSerializable(explicitToJson: true)
class ReviewModel extends Review {
  @override
  final UserModel? user;

  @override
  final List<ReviewMediaModel> medias;

  const ReviewModel({
    required super.id,
    super.content,
    required super.rating,
    super.orderId,
    required super.productId,
    required super.createdAt,
    this.user,
    this.medias = const [],
  }) : super(user: user, medias: medias);

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    // Parse user an toàn - API review chỉ trả id, name, avatar (không có email)
    UserModel? parsedUser;
    if (json['user'] != null && json['user'] is Map<String, dynamic>) {
      final userMap = json['user'] as Map<String, dynamic>;
      parsedUser = UserModel(
        id: (userMap['id'] as num).toInt(),
        email: userMap['email'] as String? ?? '',
        name: userMap['name'] as String? ?? 'Người dùng',
        avatar: userMap['avatar'] as String?,
        phoneNumber: userMap['phoneNumber'] as String?,
      );
    }

    return ReviewModel(
      id: (json['id'] as num).toInt(),
      content: json['content'] as String?,
      rating: (json['rating'] as num).toInt(),
      orderId: (json['orderId'] as num?)?.toInt(),
      productId: (json['productId'] as num).toInt(),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      user: parsedUser,
      medias: (json['medias'] as List<dynamic>?)
              ?.map((e) => ReviewMediaModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );
  }

  Map<String, dynamic> toJson() => _$ReviewModelToJson(this);
}
