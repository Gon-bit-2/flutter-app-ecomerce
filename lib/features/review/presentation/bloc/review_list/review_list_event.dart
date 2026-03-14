part of 'review_list_bloc.dart';

abstract class ReviewListEvent extends Equatable {
  const ReviewListEvent();

  @override
  List<Object?> get props => [];
}

class LoadProductReviewsEvent extends ReviewListEvent {
  final int productId;
  final bool isRefresh; // isRefresh to clear existing data before loading

  const LoadProductReviewsEvent({required this.productId, this.isRefresh = false});

  @override
  List<Object?> get props => [productId, isRefresh];
}

class LoadMoreReviewsEvent extends ReviewListEvent {
  // Triggers loading the next page of reviews
  const LoadMoreReviewsEvent();
}
