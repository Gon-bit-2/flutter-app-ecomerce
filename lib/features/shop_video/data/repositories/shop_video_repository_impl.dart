import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/shop_video.dart';
import '../../domain/entities/shop_video_comment.dart';
import '../../domain/repositories/shop_video_repository.dart';
import '../datasources/shop_video_remote_datasource.dart';

@LazySingleton(as: ShopVideoRepository)
class ShopVideoRepositoryImpl implements ShopVideoRepository {
  final ShopVideoRemoteDataSource remoteDataSource;

  ShopVideoRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, List<ShopVideo>>> getShopVideos({int page = 1, int limit = 10, int? shopId}) async {
    try {
      final videos = await remoteDataSource.getShopVideos(page: page, limit: limit, shopId: shopId);
      return Right(videos);
    } on DioException catch (e) {
      final message = e.response?.data?['message'] ?? 'Không thể tải video';
      return Left(ServerFailure(message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, ShopVideo>> getShopVideoDetail(int id) async {
    try {
      final video = await remoteDataSource.getShopVideoDetail(id);
      return Right(video);
    } on DioException catch (e) {
      final message = e.response?.data?['message'] ?? 'Lỗi tải chi tiết video';
      return Left(ServerFailure(message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, ShopVideo>> createShopVideo({
    required Uint8List videoBytes,
    required String fileName,
    String? caption,
    String? thumbnailUrl,
    List<int>? productIds,
  }) async {
    try {
      final result = await remoteDataSource.createShopVideo(
        videoBytes: videoBytes,
        fileName: fileName,
        caption: caption,
        thumbnailUrl: thumbnailUrl,
        productIds: productIds,
      );
      return Right(result);
    } on DioException catch (e) {
      final message = e.response?.data?['message'] ?? 'Lỗi tải video sản phẩm lên server';
      return Left(ServerFailure(message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, ShopVideo>> updateShopVideo(int id, Map<String, dynamic> data) async {
    try {
      final result = await remoteDataSource.updateShopVideo(id, data);
      return Right(result);
    } on DioException catch (e) {
      final message = e.response?.data?['message'] ?? 'Lỗi cập nhật video';
      return Left(ServerFailure(message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteShopVideo(int id) async {
    try {
      await remoteDataSource.deleteShopVideo(id);
      return const Right(null);
    } on DioException catch (e) {
      final message = e.response?.data?['message'] ?? 'Lỗi xóa video';
      return Left(ServerFailure(message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> toggleLike(int videoId) async {
    try {
      await remoteDataSource.toggleLike(videoId);
      return const Right(null);
    } on DioException catch (e) {
      final statusCode = e.response?.statusCode;
      if (statusCode == 401) {
        return const Left(ServerFailure('Bạn cần đăng nhập để thao tác'));
      }
      final message = e.response?.data?['message'] ?? 'Có lỗi xảy ra khi thả tim';
      return Left(ServerFailure(message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ShopVideoComment>>> getComments(int videoId, {int page = 1, int limit = 20}) async {
    try {
      final comments = await remoteDataSource.getComments(videoId, page: page, limit: limit);
      return Right(comments);
    } on DioException catch (e) {
      final message = e.response?.data?['message'] ?? 'Không thể tải bình luận';
      return Left(ServerFailure(message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, ShopVideoComment>> addComment(int videoId, {required String content, int? parentId}) async {
    try {
      final comment = await remoteDataSource.addComment(videoId, content: content, parentId: parentId);
      return Right(comment);
    } on DioException catch (e) {
      final statusCode = e.response?.statusCode;
      if (statusCode == 401) {
        return const Left(ServerFailure('Bạn cần đăng nhập để bình luận'));
      }
      final message = e.response?.data?['message'] ?? 'Lỗi khi gửi bình luận';
      return Left(ServerFailure(message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
