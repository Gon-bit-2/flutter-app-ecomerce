import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../entities/shop_video.dart';
import '../repositories/shop_video_repository.dart';

@injectable
class GetShopVideosUseCase {
  final ShopVideoRepository repository;

  GetShopVideosUseCase(this.repository);

  Future<Either<Failure, List<ShopVideo>>> call({
    int page = 1,
    int limit = 10,
    int? shopId,
  }) {
    return repository.getShopVideos(page: page, limit: limit, shopId: shopId);
  }
}
