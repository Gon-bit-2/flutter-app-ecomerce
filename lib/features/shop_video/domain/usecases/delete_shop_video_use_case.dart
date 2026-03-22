import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../repositories/shop_video_repository.dart';

@injectable
class DeleteShopVideoUseCase {
  final ShopVideoRepository repository;

  DeleteShopVideoUseCase(this.repository);

  Future<Either<Failure, void>> call(int id) {
    return repository.deleteShopVideo(id);
  }
}
