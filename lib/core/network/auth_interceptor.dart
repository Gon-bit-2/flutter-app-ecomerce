// lib/core/network/auth_interceptor.dart

import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '../../features/auth/data/datasources/auth_local_datasource.dart';

// Interceptor tự động thêm token vào mỗi request
@injectable
class AuthInterceptor extends Interceptor {
  final AuthLocalDataSource _localDataSource;

  AuthInterceptor(this._localDataSource);

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Lấy token từ storage
    final token = await _localDataSource.getAccessToken();

    // Nếu có token thì thêm vào header
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    // Cho phép request tiếp tục
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // Xử lý lỗi 401 Unauthorized (token hết hạn)
    if (err.response?.statusCode == 401) {
      // TODO: Implement refresh token logic here
      await _localDataSource.clearTokens();
    }

    handler.next(err);
  }
}
