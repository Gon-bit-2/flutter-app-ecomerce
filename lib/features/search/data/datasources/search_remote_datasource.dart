import 'package:injectable/injectable.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/network/dio_client.dart';

import '../models/search_response_model.dart';

abstract class SearchRemoteDataSource {
  Future<SearchResponseModel> searchProducts({
    required String query,
    int page = 1,
    int limit = 10,
    double? minPrice,
    double? maxPrice,
    String? sortBy,
    String? categoryId,
  });
}

@LazySingleton(as: SearchRemoteDataSource)
class SearchRemoteDataSourceImpl implements SearchRemoteDataSource {
  final DioClient _dioClient;

  SearchRemoteDataSourceImpl(this._dioClient);

  @override
  Future<SearchResponseModel> searchProducts({
    required String query,
    int page = 1,
    int limit = 10,
    double? minPrice,
    double? maxPrice,
    String? sortBy,
    String? categoryId,
  }) async {
    final Map<String, dynamic> queryParams = {
      'q': query,
      'page': page,
      'limit': limit,
    };

    if (minPrice != null) queryParams['minPrice'] = minPrice;
    if (maxPrice != null) queryParams['maxPrice'] = maxPrice;
    if (sortBy != null) queryParams['sortBy'] = sortBy;
    if (categoryId != null) queryParams['categoryId'] = categoryId;

    final response = await _dioClient.get(
      AppConstants.searchProductsEndpoint,
      queryParameters: queryParams,
    );

    return SearchResponseModel.fromJson(response.data);
  }
}
