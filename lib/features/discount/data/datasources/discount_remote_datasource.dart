import 'package:injectable/injectable.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/network/dio_client.dart';
import '../models/discount_model.dart';

abstract class DiscountRemoteDataSource {
  Future<List<DiscountModel>> getMyVouchers({int page = 1, int limit = 10});
  Future<List<DiscountModel>> getAvailableDiscounts({
    int page = 1,
    int limit = 10,
  });
  Future<Map<String, dynamic>> previewDiscount({
    required String code,
    required double orderValue,
    required int userId,
    required int shopId,
    required List<Map<String, dynamic>> items,
  });
  Future<List<DiscountModel>> getDiscountsByAdmin({
    int page = 1,
    int limit = 10,
    int? shopId,
    String? type,
    String? scope,
    bool? isActive,
    String? search,
  });
  Future<DiscountModel> getDiscountDetail(int discountId);
  Future<DiscountModel> createDiscount(Map<String, dynamic> data);
  Future<DiscountModel> updateDiscount(
    int discountId,
    Map<String, dynamic> data,
  );
  Future<void> deleteDiscount(int discountId);
  Future<void> saveDiscount(int discountId);
}

@LazySingleton(as: DiscountRemoteDataSource)
class DiscountRemoteDataSourceImpl implements DiscountRemoteDataSource {
  final DioClient _dioClient;

  DiscountRemoteDataSourceImpl(this._dioClient);

  @override
  Future<List<DiscountModel>> getMyVouchers({
    int page = 1,
    int limit = 10,
  }) async {
    final response = await _dioClient.get(
      AppConstants.myVouchersEndpoint,
      queryParameters: {'page': page, 'limit': limit},
    );

    if (response.data is List) {
      return (response.data as List)
          .map((e) => DiscountModel.fromJson(e))
          .toList();
    } else if (response.data is Map &&
        (response.data as Map).containsKey('data')) {
      return ((response.data['data']) as List)
          .map((e) => DiscountModel.fromJson(e))
          .toList();
    }
    return [];
  }

  @override
  Future<List<DiscountModel>> getAvailableDiscounts({
    int page = 1,
    int limit = 10,
  }) async {
    final response = await _dioClient.get(
      AppConstants.availableDiscountsEndpoint,
      queryParameters: {'page': page, 'limit': limit},
    );

    if (response.data is List) {
      return (response.data as List)
          .map((e) => DiscountModel.fromJson(e))
          .toList();
    } else if (response.data is Map &&
        (response.data as Map).containsKey('data')) {
      return ((response.data['data']) as List)
          .map((e) => DiscountModel.fromJson(e))
          .toList();
    }
    return [];
  }

  @override
  Future<Map<String, dynamic>> previewDiscount({
    required String code,
    required double orderValue,
    required int userId,
    required int shopId,
    required List<Map<String, dynamic>> items,
  }) async {
    final response = await _dioClient.post(
      AppConstants.previewDiscountEndpoint,
      data: {
        "code": code,
        "orderValue": orderValue,
        "userId": userId,
        "shopId": shopId,
        "items": items,
      },
    );

    // Xử lý cả 2 tình huống trả về object bọc bởi `data` hoặc trả trực tiếp JSON response
    if (response.data is Map) {
      if ((response.data as Map).containsKey('data')) {
        return response.data['data'];
      }
      return response.data;
    }
    throw Exception('Invalid preview response format');
  }

  @override
  Future<List<DiscountModel>> getDiscountsByAdmin({
    int page = 1,
    int limit = 10,
    int? shopId,
    String? type,
    String? scope,
    bool? isActive,
    String? search,
  }) async {
    final queryParameters = <String, dynamic>{'page': page, 'limit': limit};
    if (shopId != null) queryParameters['shopId'] = shopId;
    if (type != null && type.isNotEmpty) queryParameters['type'] = type;
    if (scope != null && scope.isNotEmpty) queryParameters['scope'] = scope;
    if (isActive != null) queryParameters['isActive'] = isActive;
    if (search != null && search.isNotEmpty) queryParameters['search'] = search;

    final response = await _dioClient.get(
      AppConstants.discountEndpoint,
      queryParameters: queryParameters,
    );

    if (response.data is List) {
      return (response.data as List)
          .map((e) => DiscountModel.fromJson(e))
          .toList();
    } else if (response.data is Map &&
        (response.data as Map).containsKey('data')) {
      final data = response.data['data'];
      if (data is List) {
        return data.map((e) => DiscountModel.fromJson(e)).toList();
      } else if (data is Map && data.containsKey('items')) {
        return (data['items'] as List)
            .map((e) => DiscountModel.fromJson(e))
            .toList();
      }
    }
    return [];
  }

  @override
  Future<DiscountModel> getDiscountDetail(int discountId) async {
    final response = await _dioClient.get(
      '${AppConstants.discountEndpoint}/$discountId',
    );
    if (response.data is Map && (response.data as Map).containsKey('data')) {
      return DiscountModel.fromJson(response.data['data']);
    }
    return DiscountModel.fromJson(response.data);
  }

  @override
  Future<DiscountModel> createDiscount(Map<String, dynamic> data) async {
    final response = await _dioClient.post(
      AppConstants.discountEndpoint,
      data: data,
    );
    if (response.data is Map && (response.data as Map).containsKey('data')) {
      return DiscountModel.fromJson(response.data['data']);
    }
    return DiscountModel.fromJson(response.data);
  }

  @override
  Future<DiscountModel> updateDiscount(
    int discountId,
    Map<String, dynamic> data,
  ) async {
    final response = await _dioClient.put(
      '${AppConstants.discountEndpoint}/$discountId',
      data: data,
    );
    if (response.data is Map && (response.data as Map).containsKey('data')) {
      return DiscountModel.fromJson(response.data['data']);
    }
    return DiscountModel.fromJson(response.data);
  }

  @override
  Future<void> deleteDiscount(int discountId) async {
    await _dioClient.delete('${AppConstants.discountEndpoint}/$discountId');
  }

  @override
  Future<void> saveDiscount(int discountId) async {
    await _dioClient.post('${AppConstants.saveDiscountEndpoint}/$discountId/save');
  }
}
