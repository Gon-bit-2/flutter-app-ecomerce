import 'dart:io';

import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../entities/shop_video.dart';
import '../repositories/shop_video_repository.dart';

@injectable
class CreateShopVideoUseCase {
  final ShopVideoRepository repository;

  CreateShopVideoUseCase(this.repository);

  Future<Either<Failure, ShopVideo>> call({
    required File video,
    String? caption,
    String? thumbnailUrl,
    List<int>? productIds,
  }) {
    return repository.createShopVideo(
      video: video,
      caption: caption,
      thumbnailUrl: thumbnailUrl,
      productIds: productIds,
    );
  }
}
