import 'package:app_fe_ecomerce/core/usecase/usecase.dart';
import 'package:app_fe_ecomerce/features/category/domain/entities/category.dart';
import 'package:app_fe_ecomerce/features/category/domain/repositories/category_repository.dart';
import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';

@injectable
class GetCategoryIdUseCase
    implements UseCase<CategoryEntity, GetCategoryIdParams> {
  final CategoryRepository _repository;

  GetCategoryIdUseCase(this._repository);

  @override
  Future<Either<Failure, CategoryEntity>> call(
    GetCategoryIdParams params,
  ) async {
    return await _repository.getCategoryById(params.id);
  }
}

class GetCategoryIdParams {
  final int id;

  GetCategoryIdParams({required this.id});
}
