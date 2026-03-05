import 'package:app_fe_ecomerce/core/usecase/usecase.dart';
import 'package:app_fe_ecomerce/features/category/domain/entities/category.dart';
import 'package:app_fe_ecomerce/features/category/domain/repositories/category_repository.dart';
import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';

@injectable
class UpdateCategoryUseCase
    implements UseCase<CategoryEntity, UpdateCategoryParams> {
  final CategoryRepository _repository;

  UpdateCategoryUseCase(this._repository);

  @override
  Future<Either<Failure, CategoryEntity>> call(
    UpdateCategoryParams params,
  ) async {
    return await _repository.updateCategory(
      id: params.id,
      name: params.name,
      logo: params.logo,
      parentCategoryId: params.parentCategoryId,
    );
  }
}

class UpdateCategoryParams {
  final int id;
  final String name;
  final String? logo;
  final int? parentCategoryId;

  UpdateCategoryParams({
    required this.id,
    required this.name,
    required this.logo,
    required this.parentCategoryId,
  });
}
