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
      queryParameters: {
        if (page != null) 'page': page,
        if (limit != null) 'limit': limit,
      },
    );

    // API returns nested structure: { data: [{ shop: {...}, cartItems: [...] }] }
    final List<dynamic> data = response.data is List
        ? response.data
        : (response.data['data'] as List? ?? []);

    // Flatten the nested structure: extract all cartItems from all shops
    final List<CartModel> cartItems = [];

    for (var shopData in data) {
      if (shopData is Map && shopData.containsKey('cartItems')) {
        // Extract shop information from the group
        final shopInfo = shopData['shop'] as Map<String, dynamic>?;
        final int? shopIdFromGroup = shopInfo?['id'] as int?;

        final items = shopData['cartItems'] as List? ?? [];

        for (var item in items) {
          // Extract nested data
          final Map<String, dynamic> itemData = item is Map<String, dynamic>
              ? Map<String, dynamic>.from(item)
              : {};

          // Get SKU data
          final skuData = itemData['sku'] as Map<String, dynamic>?;
          final productData = skuData?['product'] as Map<String, dynamic>?;

          // IMPORTANT: Backend validates shopId against sku.createdById
          // Try multiple sources: sku.createdById > product.createdById > shopIdFromGroup
          int? shopId = skuData?['createdById'] as int?;
          shopId ??= productData?['createdById'] as int?;
          shopId ??= shopIdFromGroup;

          // Extract price: use sku.price if > 0, otherwise use product.basePrice
          num? price;
          if (skuData != null) {
            final skuPrice = skuData['price'] as num?;
            if (skuPrice != null && skuPrice > 0) {
              price = skuPrice;
            } else if (productData != null) {
              price = productData['basePrice'] as num?;
            }
          }

          // Extract image: from product.images or sku.image
          String? image;
          if (productData != null && productData['images'] is List) {
            final images = productData['images'] as List;
            if (images.isNotEmpty) {
              image = images[0].toString();
            }
          }
          if (image == null || image.isEmpty) {
            image = skuData?['image']?.toString();
          }

          // Build flat cart model
          final flatItem = {
            'id': itemData['id'],
            'skuId': itemData['skuId'],
            'quantity': itemData['quantity'],
            'productId': productData?['id'],
            'productName': productData?['name'],
            'skuValue': skuData?['value'],
            'image': image,
            'price': price,
            'shopId': shopId,
          };

          cartItems.add(CartModel.fromJson(flatItem));
        }
      }
    }

    return cartItems;
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
