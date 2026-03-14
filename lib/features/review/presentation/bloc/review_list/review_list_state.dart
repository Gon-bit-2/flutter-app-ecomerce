part of 'review_list_bloc.dart';

abstract class ReviewListState extends Equatable {
  const ReviewListState();
  
  @override
  List<Object?> get props => [];
}

class ReviewListInitial extends ReviewListState {}

class ReviewListLoading extends ReviewListState {
  final List<Review> oldReviews; // keep data while loading more
  final bool isFirstFetch;

  const ReviewListLoading(this.oldReviews, {this.isFirstFetch = false});

  @override
  List<Object?> get props => [oldReviews, isFirstFetch];
}

class ReviewListLoaded extends ReviewListState {
  final List<Review> reviews;
  final bool hasReachedMax;

  const ReviewListLoaded(this.reviews, {this.hasReachedMax = false});

  @override
  List<Object?> get props => [reviews, hasReachedMax];
}

class ReviewListError extends ReviewListState {
  final String message;
  final List<Review> oldReviews;

  const ReviewListError(this.message, {this.oldReviews = const []});

  @override
  List<Object?> get props => [message, oldReviews];
}
