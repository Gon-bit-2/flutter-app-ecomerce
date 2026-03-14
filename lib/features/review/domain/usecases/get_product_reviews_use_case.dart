import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../entities/review.dart';
import '../repositories/review_repository.dart';

@injectable
class GetProductReviewsUseCase {
  final ReviewRepository repository;

  GetProductReviewsUseCase(this.repository);

  Future<Either<Failure, List<Review>>> call({
    required int productId,
    int page = 1,
    int limit = 10,
  }) {
    return repository.getProductReviews(
      productId: productId,
      page: page,
      limit: limit,
    );
  }
}
