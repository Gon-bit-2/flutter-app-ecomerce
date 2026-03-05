import 'package:injectable/injectable.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/network/dio_client.dart';
import '../models/category_model.dart';

abstract class CategoryRemoteDataSource {
  Future<List<CategoryModel>> getCategories({int? parentCategoryId});
  Future<CategoryModel> getCategoryById(int id);
  Future<CategoryModel> createCategory({
    required String name,
    required String? logo,
    required int? parentCategoryId,
  });
  Future<CategoryModel> updateCategory({
    required int id,
    required String name,
    required String? logo,
    required int? parentCategoryId,
  });
  Future<void> deleteCategory(int id);
}

@LazySingleton(as: CategoryRemoteDataSource)
class CategoryRemoteDataSourceImpl implements CategoryRemoteDataSource {
  final DioClient _dioClient;

  CategoryRemoteDataSourceImpl(this._dioClient);

  @override
  Future<List<CategoryModel>> getCategories({int? parentCategoryId}) async {
    final response = await _dioClient.get(
      AppConstants.categoriesEndpoint,
      queryParameters: {
        if (parentCategoryId != null) 'parentCategoryId': parentCategoryId,
      },
    );

    if (response.data is List) {
      return (response.data as List)
          .map((e) => CategoryModel.fromJson(e))
          .toList();
    } else if (response.data is Map &&
        (response.data as Map).containsKey('data')) {
      return ((response.data['data']) as List)
          .map((e) => CategoryModel.fromJson(e))
          .toList();
    } else {
      return [];
    }
  }

  @override
  Future<CategoryModel> getCategoryById(int id) async {
    final response = await _dioClient.get(
      '${AppConstants.categoriesEndpoint}/$id',
    );
    return CategoryModel.fromJson(response.data);
  }

  @override
  Future<CategoryModel> createCategory({
    required String name,
    required String? logo,
    required int? parentCategoryId,
  }) async {
    final response = await _dioClient.post(
      AppConstants.categoriesEndpoint,
      data: {
        'name': name,
        'logo': logo,
        'parent_category_id': parentCategoryId,
      },
    );
    return CategoryModel.fromJson(response.data);
  }

  @override
  Future<CategoryModel> updateCategory({
    required int id,
    required String name,
    required String? logo,
    required int? parentCategoryId,
  }) async {
    final response = await _dioClient.put(
      '${AppConstants.categoriesEndpoint}/$id',
      data: {
        'name': name,
        'logo': logo,
        'parent_category_id': parentCategoryId,
      },
    );
    return CategoryModel.fromJson(response.data);
  }

  @override
  Future<void> deleteCategory(int id) async {
    await _dioClient.delete('${AppConstants.categoriesEndpoint}/$id');
  }
}
