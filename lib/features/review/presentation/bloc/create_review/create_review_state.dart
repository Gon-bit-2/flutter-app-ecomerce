part of 'create_review_bloc.dart';

enum CreateReviewStatus { initial, loading, success, failure }

class CreateReviewState extends Equatable {
  final String content;
  final int rating;
  final List<String> mediaPaths;
  final CreateReviewStatus status;
  final String? errorMessage;
  final Review? createdReview;

  const CreateReviewState({
    this.content = '',
    this.rating = 5,
    this.mediaPaths = const [],
    this.status = CreateReviewStatus.initial,
    this.errorMessage,
    this.createdReview,
  });

  CreateReviewState copyWith({
    String? content,
    int? rating,
    List<String>? mediaPaths,
    CreateReviewStatus? status,
    String? errorMessage,
    Review? createdReview,
  }) {
    return CreateReviewState(
      content: content ?? this.content,
      rating: rating ?? this.rating,
      mediaPaths: mediaPaths ?? this.mediaPaths,
      status: status ?? this.status,
      errorMessage: errorMessage,
      createdReview: createdReview ?? this.createdReview,
    );
  }

  @override
  List<Object?> get props => [content, rating, mediaPaths, status, errorMessage, createdReview];
}
