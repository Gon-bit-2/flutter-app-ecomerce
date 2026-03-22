import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../entities/shop_video_comment.dart';
import '../repositories/shop_video_repository.dart';

@injectable
class AddVideoCommentUseCase {
  final ShopVideoRepository repository;

  AddVideoCommentUseCase(this.repository);

  Future<Either<Failure, ShopVideoComment>> call(
    int videoId, {
    required String content,
    int? parentId,
  }) {
    return repository.addComment(
      videoId,
      content: content,
      parentId: parentId,
    );
  }
}
