import 'dart:typed_data';

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
    required Uint8List videoBytes,
    required String fileName,
    String? caption,
    String? thumbnailUrl,
    List<int>? productIds,
  }) {
    return repository.createShopVideo(
      videoBytes: videoBytes,
      fileName: fileName,
      caption: caption,
      thumbnailUrl: thumbnailUrl,
      productIds: productIds,
    );
  }
}
