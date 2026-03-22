import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../entities/shop_video_comment.dart';
import '../repositories/shop_video_repository.dart';

@injectable
class GetVideoCommentsUseCase {
  final ShopVideoRepository repository;

  GetVideoCommentsUseCase(this.repository);

  Future<Either<Failure, List<ShopVideoComment>>> call(
    int videoId, {
    int page = 1,
    int limit = 20,
  }) {
    return repository.getComments(videoId, page: page, limit: limit);
  }
}
