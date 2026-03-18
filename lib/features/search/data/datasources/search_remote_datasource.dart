import 'package:injectable/injectable.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/network/dio_client.dart';
import '../../../product/data/models/product_model.dart';

abstract class SearchRemoteDataSource {
  Future<List<ProductModel>> searchProducts({
    required String query,
    int page = 1,
    int limit = 10,
  });
}

@LazySingleton(as: SearchRemoteDataSource)
class SearchRemoteDataSourceImpl implements SearchRemoteDataSource {
  final DioClient _dioClient;

  SearchRemoteDataSourceImpl(this._dioClient);

  @override
  Future<List<ProductModel>> searchProducts({
    required String query,
    int page = 1,
    int limit = 10,
  }) async {
    final response = await _dioClient.get(
      AppConstants.searchProductsEndpoint,
      queryParameters: {
        'q': query,
        'page': page,
        'limit': limit,
      },
    );

    if (response.data is List) {
      return (response.data as List)
          .map((e) => ProductModel.fromJson(e))
          .toList();
    } else if (response.data is Map &&
        (response.data as Map).containsKey('data')) {
      return ((response.data['data']) as List)
          .map((e) => ProductModel.fromJson(e))
          .toList();
    } else {
      return [];
    }
  }
}
