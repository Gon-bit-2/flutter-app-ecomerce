import 'dart:io';

import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../entities/shop_video.dart';
import '../entities/shop_video_comment.dart';

abstract class ShopVideoRepository {
  Future<Either<Failure, List<ShopVideo>>> getShopVideos({
    int page = 1,
    int limit = 10,
    int? shopId,
  });

  Future<Either<Failure, ShopVideo>> getShopVideoDetail(int id);

  Future<Either<Failure, ShopVideo>> createShopVideo({
    required File video,
    String? caption,
    String? thumbnailUrl,
    List<int>? productIds,
  });

  Future<Either<Failure, ShopVideo>> updateShopVideo(
    int id,
    Map<String, dynamic> data,
  );

  Future<Either<Failure, void>> deleteShopVideo(int id);

  Future<Either<Failure, void>> toggleLike(int videoId);

  Future<Either<Failure, List<ShopVideoComment>>> getComments(
    int videoId, {
    int page = 1,
    int limit = 20,
  });

  Future<Either<Failure, ShopVideoComment>> addComment(
    int videoId, {
    required String content,
    int? parentId,
  });
}
