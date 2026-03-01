import 'package:app_fe_ecomerce/core/constants/app_constants.dart';
import 'package:app_fe_ecomerce/core/network/dio_client.dart';
import 'package:app_fe_ecomerce/features/cart/data/models/cart_model.dart';
import 'package:injectable/injectable.dart';

abstract class CartRemoteDataSource {
  Future<List<CartModel>> getCart({int? page, int? limit});
  Future<CartModel> addToCart({required int skuId, required int quantity});
  Future<void> removeCartItems({required List<int> cartItemIds});
  Future<void> updateCart({required int id, required int quantity});
}

@LazySingleton(as: CartRemoteDataSource)
class CartRemoteDataSourceImpl implements CartRemoteDataSource {
  final DioClient _dioClient;
  CartRemoteDataSourceImpl(this._dioClient);

  @override
  Future<List<CartModel>> getCart({int? page, int? limit}) async {
    final response = await _dioClient.get(
      AppConstants.cartEndpoint,
      queryParameters: {'page': page, 'limit': limit},
    );
    // API trả về danh sách cart items (mảng JSON)
    final List<dynamic> data = response.data is List
        ? response.data
        : (response.data['data'] as List? ?? []);
    return data.map((item) => CartModel.fromJson(item)).toList();
  }

  @override
  Future<CartModel> addToCart({
    required int skuId,
    required int quantity,
  }) async {
    final response = await _dioClient.post(
      AppConstants.cartEndpoint,
      data: {'skuId': skuId, 'quantity': quantity},
    );
    return CartModel.fromJson(response.data);
  }

  @override
  Future<void> removeCartItems({required List<int> cartItemIds}) async {
    await _dioClient.post(
      AppConstants.cartDeleteEndpoint,
      data: {'cartItemIds': cartItemIds},
    );
  }

  @override
  Future<void> updateCart({required int id, required int quantity}) async {
    await _dioClient.put(
      '${AppConstants.cartEndpoint}/$id',
      data: {'quantity': quantity},
    );
  }
}
