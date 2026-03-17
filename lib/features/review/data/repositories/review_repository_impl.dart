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
      final statusCode = e.response?.statusCode;
      // Nếu server lỗi (500) hoặc không tìm thấy (404) → trả về list rỗng thay vì báo lỗi
      if (statusCode == 500 || statusCode == 404) {
        return const Right([]);
      }
      final message = e.response?.data?['message'] ?? 'Không thể tải đánh giá';
      return Left(ServerFailure(message));
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
      final statusCode = e.response?.statusCode;
      // 409 Conflict - đã đánh giá sản phẩm này rồi
      if (statusCode == 409) {
        return const Left(ServerFailure('Bạn đã đánh giá sản phẩm này rồi!'));
      }
      // 403 Forbidden - chưa mua sản phẩm
      if (statusCode == 403) {
        return const Left(ServerFailure('Bạn cần mua sản phẩm này trước khi đánh giá.'));
      }
      final message = e.response?.data?['message'] ?? 'Không thể gửi đánh giá';
      return Left(ServerFailure(message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
