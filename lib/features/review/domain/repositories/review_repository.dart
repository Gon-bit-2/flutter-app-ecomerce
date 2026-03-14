import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../entities/review.dart';

abstract class ReviewRepository {
  Future<Either<Failure, List<Review>>> getProductReviews({
    required int productId,
    int page = 1,
    int limit = 10,
  });

  Future<Either<Failure, Review>> createReview(Map<String, dynamic> reviewData);
}
