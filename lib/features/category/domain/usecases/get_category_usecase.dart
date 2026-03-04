import 'package:app_fe_ecomerce/core/usecase/usecase.dart';
import 'package:app_fe_ecomerce/features/category/domain/entities/category.dart';
import 'package:app_fe_ecomerce/features/category/domain/repositories/category_repository.dart';
import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';

@injectable
class GetCategoryUseCase
    implements UseCase<List<CategoryEntity>, GetCategoryParams> {
  final CategoryRepository _repository;

  GetCategoryUseCase(this._repository);

  @override
  Future<Either<Failure, List<CategoryEntity>>> call(
    GetCategoryParams params,
  ) async {
    return await _repository.getCategories(
      parentCategoryId: params.parentCategoryId,
    );
  }
}

class GetCategoryParams {
  final int? parentCategoryId;

  const GetCategoryParams({this.parentCategoryId});
}
