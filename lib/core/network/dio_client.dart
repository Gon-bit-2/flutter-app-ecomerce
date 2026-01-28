// lib/core/network/dio_client.dart

import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '../constants/app_constants.dart';
import 'auth_interceptor.dart';

// @lazySingleton nghĩa là: Chỉ tạo 1 bản sao DioClient duy nhất dùng cho toàn app
// (Giúp tiết kiệm bộ nhớ)
@lazySingleton
class DioClient {
  final Dio _dio;
  final AuthInterceptor _authInterceptor;

  DioClient(this._dio, this._authInterceptor) {
    // Cấu hình mặc định cho mỗi request
    _dio
      ..options.baseUrl = AppConstants.baseUrl
      ..options.connectTimeout = const Duration(
        milliseconds: AppConstants.connectTimeout,
      )
      ..options.receiveTimeout = const Duration(
        milliseconds: AppConstants.receiveTimeout,
      )
      ..options.responseType = ResponseType.json
      ..options.headers = {
        'Content-Type': 'application/json', // Báo cho server biết mình gửi JSON
        'Accept': 'application/json',
      };

    // Thêm Interceptor (Người gác cổng)
    // 1. AuthInterceptor: Tự động thêm token vào mỗi request
    _dio.interceptors.add(_authInterceptor);

    // 2. LogInterceptor: In log ra màn hình console để bạn dễ theo dõi lỗi
    _dio.interceptors.add(
      LogInterceptor(
        request: true, // In nội dung gửi đi
        requestHeader: true, // In header gửi đi
        requestBody: true, // In body (JSON) gửi đi
        responseHeader: true, // In header nhận về
        responseBody: true, // In body nhận về
        error: true, // In lỗi nếu có
      ),
    );
  }

  // Hàm GET
  Future<Response> get(
    String url, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _dio.get(
        url,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
      return response;
    } catch (e) {
      rethrow; // Ném lỗi ra để tầng trên xử lý
    }
  }

  // Hàm POST
  Future<Response> post(
    String url, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _dio.post(
        url,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  // Hàm PUT
  Future<Response> put(
    String url, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _dio.put(
        url,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  // Hàm DELETE
  Future<Response> delete(
    String url, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _dio.delete(
        url,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }
}
