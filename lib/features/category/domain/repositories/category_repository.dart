import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../entities/category.dart';

abstract class CategoryRepository {
  //get all categories
  Future<Either<Failure, List<CategoryEntity>>> getCategories({
    int? parentCategoryId,
  });
  //get category by id
  Future<Either<Failure, CategoryEntity>> getCategoryById(int id);
  //create category
  Future<Either<Failure, CategoryEntity>> createCategory({
    required String name,
    required String? logo,
    required int? parentCategoryId,
  });
  //update category
  Future<Either<Failure, CategoryEntity>> updateCategory({
    required int id,
    required String name,
    required String? logo,
    required int? parentCategoryId,
  });
  //delete category
  Future<Either<Failure, void>> deleteCategory(int id);
}
