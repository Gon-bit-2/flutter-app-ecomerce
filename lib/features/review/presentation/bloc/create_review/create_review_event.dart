part of 'create_review_bloc.dart';

abstract class CreateReviewEvent extends Equatable {
  const CreateReviewEvent();

  @override
  List<Object?> get props => [];
}

class FormContentChanged extends CreateReviewEvent {
  final String content;
  const FormContentChanged(this.content);
  @override
  List<Object?> get props => [content];
}

class FormRatingChanged extends CreateReviewEvent {
  final int rating;
  const FormRatingChanged(this.rating);
  @override
  List<Object?> get props => [rating];
}

class FormMediasChanged extends CreateReviewEvent {
  final List<String> mediaPaths; // Local file paths
  const FormMediasChanged(this.mediaPaths);
  @override
  List<Object?> get props => [mediaPaths];
}

class SubmitReviewEvent extends CreateReviewEvent {
  final int productId;
  final int orderId;
  final int userId;
  final String content;
  final int rating;
  final List<String> mediaPaths;
  const SubmitReviewEvent({
    required this.productId,
    required this.orderId,
    required this.userId,
    required this.content,
    required this.rating,
    this.mediaPaths = const [],
  });

  @override
  List<Object?> get props => [productId, orderId, userId, content, rating, mediaPaths];
}
