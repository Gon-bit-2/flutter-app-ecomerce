import 'package:injectable/injectable.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/network/dio_client.dart';
import '../models/category_model.dart';

abstract class CategoryRemoteDataSource {
  Future<List<CategoryModel>> getCategories();
}

@LazySingleton(as: CategoryRemoteDataSource)
class CategoryRemoteDataSourceImpl implements CategoryRemoteDataSource {
  final DioClient _dioClient;

  CategoryRemoteDataSourceImpl(this._dioClient);

  @override
  Future<List<CategoryModel>> getCategories() async {
    final response = await _dioClient.get(AppConstants.categoriesEndpoint);
    // Response might be a list or wrapped in data. API LIST: GET /categories -> List of body?
    // API_LIST says: `[ { "id": 1, ... } ]`? No, existing `User Module` says `[... user ...]` or `{ data: ..., meta: ...}`.
    // "Response: [ ... ]" usually means direct list.
    // However, FrontEnd Guide says: "Dữ liệu thường được trả về trực tiếp hoặc trong object tùy endpoint. Ví dụ danh sách có phân trang: ... GET /user ... [ ... ] // Hoặc nếu có metadata".
    // I should check strict response. Assuming List based on typical non-paginated category list.
    // If it is wrapped in 'data', I need to handle.
    // I'll check `response.data` type.

    if (response.data is List) {
      return (response.data as List)
          .map((e) => CategoryModel.fromJson(e))
          .toList();
    } else if (response.data is Map &&
        (response.data as Map).containsKey('data')) {
      // if wrapped in data
      return ((response.data['data']) as List)
          .map((e) => CategoryModel.fromJson(e))
          .toList();
    } else {
      return [];
    }
  }
}
