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

  factory ReviewModel.fromJson(Map<String, dynamic> json) =>
      _$ReviewModelFromJson(json);

  Map<String, dynamic> toJson() => _$ReviewModelToJson(this);
}
