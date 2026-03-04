import 'package:app_fe_ecomerce/core/usecase/usecase.dart';
import 'package:app_fe_ecomerce/features/category/domain/entities/category.dart';
import 'package:app_fe_ecomerce/features/category/domain/repositories/category_repository.dart';
import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';

@injectable
class CreateCategoryUseCase
    implements UseCase<CategoryEntity, CreateCategoryParams> {
  final CategoryRepository _repository;

  CreateCategoryUseCase(this._repository);

  @override
  Future<Either<Failure, CategoryEntity>> call(
    CreateCategoryParams params,
  ) async {
    return await _repository.createCategory(
      name: params.name,
      logo: params.logo,
      parentCategoryId: params.parentCategoryId,
    );
  }
}

class CreateCategoryParams {
  final String name;
  final String? logo;
  final int? parentCategoryId;

  CreateCategoryParams({
    required this.name,
    required this.logo,
    required this.parentCategoryId,
  });
}
