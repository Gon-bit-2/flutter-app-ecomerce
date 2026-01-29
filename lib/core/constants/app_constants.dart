import 'package:flutter/foundation.dart';
import 'dart:io';

class AppConstants {
  // Tránh việc khởi tạo class này
  const AppConstants._();

  // URL API gốc
  // Nếu chạy Android Emulator: dùng 10.0.2.2
  // Nếu chạy iOS Simulator: dùng localhost
  // Nếu chạy máy thật: dùng địa chỉ IP LAN của máy tính (VD: 192.168.1.X)
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:9999'; // Dành cho Web
    } else if (Platform.isAndroid) {
      return 'http://10.0.2.2:9999'; // Dành cho Android Emulator
    } else {
      return 'http://localhost:9999'; // Dành cho iOS Simulator
    }
  }

  // Thời gian chờ kết nối tối đa (30 giây)
  static const int connectTimeout = 30000;
  static const int receiveTimeout = 30000;

  // Key để lưu Token vào bộ nhớ máy
  static const String accessTokenKey = 'accessToken';

  // API Endpoints
  static const String loginEndpoint = '/auth/login';
  static const String profileEndpoint = '/profile';
  static const String otpEndpoint = '/auth/otp';
  static const String verifyOtpEndpoint = '/auth/verify-otp';
  static const String registerEndpoint = '/auth/register';
  static const String refreshTokenEndpoint = '/auth/refresh-token';
  static const String logoutEndpoint = '/auth/logout';
  static const String googleLinkEndpoint = '/auth/google-link';
  static const String googleCallbackEndpoint = '/auth/google/callback';
  static const String forgotPasswordEndpoint = '/auth/forgot-password';
  static const String setup2faEndpoint = '/auth/2fa/setup';
  static const String disable2faEndpoint = '/auth/2fa/disable';

  // Product & Category Endpoints
  static const String categoriesEndpoint = '/categories';
  static const String productsEndpoint = '/product';
  static const String manageProductsEndpoint = '/manage-product/products';
}
