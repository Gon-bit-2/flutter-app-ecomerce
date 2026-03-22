import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../entities/shop_video.dart';
import '../repositories/shop_video_repository.dart';

@injectable
class GetShopVideoDetailUseCase {
  final ShopVideoRepository repository;

  GetShopVideoDetailUseCase(this.repository);

  Future<Either<Failure, ShopVideo>> call(int id) {
    return repository.getShopVideoDetail(id);
  }
}
