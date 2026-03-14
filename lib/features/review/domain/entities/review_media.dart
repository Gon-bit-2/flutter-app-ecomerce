import 'package:equatable/equatable.dart';

enum ReviewMediaType { image, video }

class ReviewMedia extends Equatable {
  final String url;
  final ReviewMediaType type;

  const ReviewMedia({
    required this.url,
    required this.type,
  });

  @override
  List<Object?> get props => [url, type];
}
