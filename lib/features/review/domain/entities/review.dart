import 'package:equatable/equatable.dart';
import '../../../auth/domain/entities/user_entity.dart';
import 'review_media.dart';

class Review extends Equatable {
  final int id;
  final String? content;
  final int rating;
  final int? orderId;
  final int productId;
  final DateTime createdAt;
  final UserEntity? user;
  final List<ReviewMedia> medias;

  const Review({
    required this.id,
    this.content,
    required this.rating,
    this.orderId,
    required this.productId,
    required this.createdAt,
    this.user,
    this.medias = const [],
  });

  @override
  List<Object?> get props => [
        id,
        content,
        rating,
        orderId,
        productId,
        createdAt,
        user,
        medias,
      ];
}
