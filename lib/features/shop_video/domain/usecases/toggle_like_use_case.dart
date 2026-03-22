import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../repositories/shop_video_repository.dart';

@injectable
class ToggleLikeUseCase {
  final ShopVideoRepository repository;

  ToggleLikeUseCase(this.repository);

  Future<Either<Failure, void>> call(int videoId) {
    return repository.toggleLike(videoId);
  }
}
