import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/network/dio_client.dart';
import '../models/brand_model.dart';

abstract class BrandRemoteDataSource {
  Future<List<BrandModel>> getBrands();
}

@LazySingleton(as: BrandRemoteDataSource)
class BrandRemoteDataSourceImpl implements BrandRemoteDataSource {
  final DioClient dioClient;

  BrandRemoteDataSourceImpl(this.dioClient);

  @override
  Future<List<BrandModel>> getBrands() async {
    // Assuming the endpoint is /brands
    // Adjust based on your API_LIST.md if needed
    final response = await dioClient.get('/brand');

    if (response.statusCode == 200) {
      final List<dynamic> data = response.data['data'] ?? [];
      return data.map((json) => BrandModel.fromJson(json)).toList();
    } else {
      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        type: DioExceptionType.badResponse,
      );
    }
  }
}
