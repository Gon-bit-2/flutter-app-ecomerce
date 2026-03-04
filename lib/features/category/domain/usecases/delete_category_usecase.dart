import 'package:app_fe_ecomerce/core/usecase/usecase.dart';
import 'package:app_fe_ecomerce/features/category/domain/repositories/category_repository.dart';
import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';

@injectable
class DeleteCategoryUseCase implements UseCase<void, DeleteCategoryParams> {
  final CategoryRepository _repository;

  DeleteCategoryUseCase(this._repository);

  @override
  Future<Either<Failure, void>> call(DeleteCategoryParams params) async {
    return await _repository.deleteCategory(params.id);
  }
}

class DeleteCategoryParams {
  final int id;

  DeleteCategoryParams({required this.id});
}
