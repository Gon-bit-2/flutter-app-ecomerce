import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

import '../../../domain/entities/review.dart';
import '../../../domain/usecases/get_product_reviews_use_case.dart';

part 'review_list_event.dart';
part 'review_list_state.dart';

@injectable
class ReviewListBloc extends Bloc<ReviewListEvent, ReviewListState> {
  final GetProductReviewsUseCase getProductReviewsUseCase;

  int _currentPage = 1;
  static const int _limit = 10;
  int _currentProductId = -1;

  ReviewListBloc(this.getProductReviewsUseCase) : super(ReviewListInitial()) {
    on<LoadProductReviewsEvent>(_onLoadProductReviews);
    on<LoadMoreReviewsEvent>(_onLoadMoreReviews);
  }

  Future<void> _onLoadProductReviews(
    LoadProductReviewsEvent event,
    Emitter<ReviewListState> emit,
  ) async {
    _currentProductId = event.productId;
    if (event.isRefresh) {
      _currentPage = 1;
    }

    emit(const ReviewListLoading([], isFirstFetch: true));

    final result = await getProductReviewsUseCase.call(
      productId: event.productId,
      page: _currentPage,
      limit: _limit,
    );

    result.fold(
      (failure) => emit(ReviewListError(failure.message)),
      (reviews) {
        bool hasReachedMax = reviews.length < _limit;
        emit(ReviewListLoaded(reviews, hasReachedMax: hasReachedMax));
      },
    );
  }

  Future<void> _onLoadMoreReviews(
    LoadMoreReviewsEvent event,
    Emitter<ReviewListState> emit,
  ) async {
    if (state is ReviewListLoaded) {
      final currentState = state as ReviewListLoaded;
      if (currentState.hasReachedMax) return;

      emit(ReviewListLoading(currentState.reviews));
      _currentPage++;

      final result = await getProductReviewsUseCase.call(
        productId: _currentProductId,
        page: _currentPage,
        limit: _limit,
      );

      result.fold(
        (failure) {
          emit(ReviewListError(failure.message, oldReviews: currentState.reviews));
        },
        (reviews) {
          bool hasReachedMax = reviews.length < _limit;
          emit(ReviewListLoaded(
            [...currentState.reviews, ...reviews],
            hasReachedMax: hasReachedMax,
          ));
        },
      );
    }
  }
}
