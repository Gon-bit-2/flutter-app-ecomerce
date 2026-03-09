import 'package:injectable/injectable.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/network/dio_client.dart';
import '../models/product_model.dart';

abstract class ProductRemoteDataSource {
  Future<List<ProductModel>> getProducts({int page = 1, int limit = 10});
  Future<ProductModel> getProductById(int productId);
  Future<bool> createProduct(Map<String, dynamic> productData);
  Future<bool> updateProduct(int id, Map<String, dynamic> productData);
  Future<void> deleteProduct(int id);
  Future<List<ProductModel>> getManageProducts({int page = 1, int limit = 10});
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
  Future<ProductModel> getProductById(int productId) async {
    final response = await _dioClient.get(
      '${AppConstants.productsEndpoint}/$productId',
    );

    // Response could be wrapped in 'data' or be the product directly
    if (response.data is Map) {
      final data = response.data as Map<String, dynamic>;
      if (data.containsKey('data')) {
        return ProductModel.fromJson(data['data']);
      }
      return ProductModel.fromJson(data);
    }
    throw Exception('Invalid response format');
  }

  @override
  Future<bool> createProduct(Map<String, dynamic> productData) async {
    await _dioClient.post(
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

  @override
  Future<void> deleteProduct(int id) async {
    await _dioClient.delete('${AppConstants.manageProductsEndpoint}/$id');
  }

  @override
  Future<List<ProductModel>> getManageProducts({
    int page = 1,
    int limit = 10,
  }) async {
    final response = await _dioClient.get(
      AppConstants.manageProductsEndpoint,
      queryParameters: {'page': page, 'limit': limit},
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
