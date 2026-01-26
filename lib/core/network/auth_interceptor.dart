// lib/core/network/auth_interceptor.dart

import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';

// Interceptor tự động thêm token vào mỗi request
@injectable
class AuthInterceptor extends Interceptor {
  final SharedPreferences _prefs;

  AuthInterceptor(this._prefs);

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Lấy token từ SharedPreferences
    final token = _prefs.getString(AppConstants.accessTokenKey);

    // Nếu có token thì thêm vào header
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    // Cho phép request tiếp tục
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // Xử lý lỗi 401 Unauthorized (token hết hạn)
    if (err.response?.statusCode == 401) {
      // TODO: Implement refresh token logic here
      // 1. Gọi API refresh token
      // 2. Lưu token mới
      // 3. Retry request ban đầu

      // Tạm thời: xóa token và chuyển về màn hình login
      _prefs.remove(AppConstants.accessTokenKey);
    }

    handler.next(err);
  }
}
