import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../entities/shop_video.dart';
import '../repositories/shop_video_repository.dart';

@injectable
class UpdateShopVideoUseCase {
  final ShopVideoRepository repository;

  UpdateShopVideoUseCase(this.repository);

  Future<Either<Failure, ShopVideo>> call(int id, Map<String, dynamic> data) {
    return repository.updateShopVideo(id, data);
  }
}
