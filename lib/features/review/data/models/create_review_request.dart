import 'package:json_annotation/json_annotation.dart';

part 'create_review_request.g.dart';

@JsonSerializable()
class CreateReviewRequest {
  final String content;
  final int rating;
  final int orderId;
  final int productId;
  final List<Map<String, String>> medias;

  const CreateReviewRequest({
    required this.content,
    required this.rating,
    required this.orderId,
    required this.productId,
    this.medias = const [],
  });

  Map<String, dynamic> toJson() => _$CreateReviewRequestToJson(this);
}
