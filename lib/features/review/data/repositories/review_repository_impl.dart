import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/review.dart';
import '../../domain/repositories/review_repository.dart';
import '../datasources/review_remote_data_source.dart';

@LazySingleton(as: ReviewRepository)
class ReviewRepositoryImpl implements ReviewRepository {
  final ReviewRemoteDataSource remoteDataSource;

  ReviewRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, List<Review>>> getProductReviews({
    required int productId,
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final reviews = await remoteDataSource.getProductReviews(productId, page, limit);
      return Right(reviews);
    } on DioException catch (e) {
      if (e.response != null) {
        return Left(ServerFailure(
            e.response?.data['message'] ?? 'Failed to load reviews'));
      }
      return const Left(ServerFailure('Connection failed'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Review>> createReview(Map<String, dynamic> reviewData) async {
    try {
      final review = await remoteDataSource.createReview(reviewData);
      return Right(review);
    } on DioException catch (e) {
      if (e.response != null) {
        return Left(ServerFailure(
            e.response?.data['message'] ?? 'Failed to create review'));
      }
      return const Left(ServerFailure('Connection failed'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
