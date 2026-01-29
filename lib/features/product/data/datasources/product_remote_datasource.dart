import 'package:injectable/injectable.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/network/dio_client.dart';
import '../models/product_model.dart';

abstract class ProductRemoteDataSource {
  Future<List<ProductModel>> getProducts({int page = 1, int limit = 10});
  Future<bool> createProduct(Map<String, dynamic> productData);
  Future<bool> updateProduct(int id, Map<String, dynamic> productData);
}

@LazySingleton(as: ProductRemoteDataSource)
class ProductRemoteDataSourceImpl implements ProductRemoteDataSource {
  final DioClient _dioClient;

  ProductRemoteDataSourceImpl(this._dioClient);

  @override
  Future<List<ProductModel>> getProducts({int page = 1, int limit = 10}) async {
    final response = await _dioClient.get(
      AppConstants.productsEndpoint,
      queryParameters: {'page': page, 'limit': limit},
    );

    // Similar check for wrapping
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

  @override
  Future<bool> createProduct(Map<String, dynamic> productData) async {
    final response = await _dioClient.post(
      AppConstants.manageProductsEndpoint,
      data: productData,
    );
    return true;
  }

  @override
  Future<bool> updateProduct(int id, Map<String, dynamic> productData) async {
    await _dioClient.put(
      '${AppConstants.manageProductsEndpoint}/$id',
      data: productData,
    );
    return true;
  }
}
