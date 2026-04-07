import 'package:app_fe_ecomerce/core/constants/app_constants.dart';
import 'package:app_fe_ecomerce/core/network/dio_client.dart';
import 'package:app_fe_ecomerce/features/order/data/models/order_creation_result_model.dart';
import 'package:app_fe_ecomerce/features/order/data/models/order_model.dart';
import 'package:app_fe_ecomerce/features/order/domain/usecases/create_order_usecase.dart';
import 'package:injectable/injectable.dart';

abstract class OrderRemoteDataSource {
  Future<List<OrderModel>> getOrders({int? page, int? limit, String? status});
  Future<List<OrderModel>> getSellerOrders({int? page, int? limit, String? status});
  Future<OrderModel> getOrderDetail(int id);
  Future<OrderCreationResultModel> createOrder({
    required List<ShopOrderParams> orders,
  });
  Future<void> cancelOrder(int id);
  Future<void> updateOrderStatus(int id, String status);
}

@LazySingleton(as: OrderRemoteDataSource)
class OrderRemoteDataSourceImpl implements OrderRemoteDataSource {
  final DioClient _dioClient;

  OrderRemoteDataSourceImpl(this._dioClient);

  @override
  Future<List<OrderModel>> getOrders({
    int? page,
    int? limit,
    String? status,
  }) async {
    final queryParams = <String, dynamic>{
      if (page != null) 'page': page,
      if (limit != null) 'limit': limit,
      if (status != null) 'status': status,
    };
    final response = await _dioClient.get(
      AppConstants.buyerOrdersEndpoint,
      queryParameters: queryParams,
    );
    final List<dynamic> data = response.data is List
        ? response.data
        : (response.data['data'] as List? ?? []);
    return data.map((item) => OrderModel.fromJson(item)).toList();
  }

  @override
  Future<List<OrderModel>> getSellerOrders({
    int? page,
    int? limit,
    String? status,
  }) async {
    final queryParams = <String, dynamic>{
      if (page != null) 'page': page,
      if (limit != null) 'limit': limit,
      if (status != null) 'status': status,
    };
    final response = await _dioClient.get(
      AppConstants.sellerOrdersEndpoint,
      queryParameters: queryParams,
    );
    final List<dynamic> data = response.data is List
        ? response.data
        : (response.data['data'] as List? ?? []);
    return data.map((item) => OrderModel.fromJson(item)).toList();
  }

  @override
  Future<OrderModel> getOrderDetail(int id) async {
    final response = await _dioClient.get('${AppConstants.ordersEndpoint}/$id');
    return OrderModel.fromJson(response.data);
  }

  @override
  Future<OrderCreationResultModel> createOrder({
    required List<ShopOrderParams> orders,
  }) async {
    final payload = orders.map((o) => o.toJson()).toList();
    final response = await _dioClient.post(
      AppConstants.ordersEndpoint,
      data: payload,
    );
    return OrderCreationResultModel.fromJson(response.data);
  }

  @override
  Future<void> cancelOrder(int id) async {
    await _dioClient.put('${AppConstants.ordersEndpoint}/$id');
  }

  @override
  Future<void> updateOrderStatus(int id, String status) async {
    await _dioClient.post(
      '${AppConstants.ordersEndpoint}/$id/status',
      data: {'status': status},
    );
  }
}
