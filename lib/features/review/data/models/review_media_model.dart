import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/review_media.dart';

part 'review_media_model.g.dart';

@JsonSerializable()
class ReviewMediaModel extends ReviewMedia {
  @JsonKey(
      fromJson: _mediaTypeFromString,
      toJson: _mediaTypeToString)
  @override
  final ReviewMediaType type;

  const ReviewMediaModel({
    required super.url,
    required this.type,
  }) : super(type: type);

  factory ReviewMediaModel.fromJson(Map<String, dynamic> json) =>
      _$ReviewMediaModelFromJson(json);

  Map<String, dynamic> toJson() => _$ReviewMediaModelToJson(this);

  static ReviewMediaType _mediaTypeFromString(String? value) {
    if (value?.toUpperCase() == 'VIDEO') return ReviewMediaType.video;
    return ReviewMediaType.image;
  }

  static String _mediaTypeToString(ReviewMediaType type) {
    return type == ReviewMediaType.video ? 'VIDEO' : 'IMAGE';
  }
}
