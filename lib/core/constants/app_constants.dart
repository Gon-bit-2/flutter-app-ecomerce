import 'package:flutter/foundation.dart';
import 'dart:io';

class AppConstants {
  // Tránh việc khởi tạo class này
  const AppConstants._();

  // URL API gốc
  // Nếu chạy Android Emulator: dùng 10.0.2.2
  // Nếu chạy iOS Simulator: dùng localhost
  // Nếu chạy máy thật: dùng địa chỉ IP LAN của máy tính (VD: 192.168.1.X)

  // *** QUAN TRỌNG: Thay đổi cấu hình này tùy theo môi trường ***
  // - Chạy trên emulator: đặt useRealDevice = false
  // - Chạy trên điện thoại thật: đặt useRealDevice = true
  static const bool useRealDevice = true;
  static const String realDeviceIp = '192.168.29.93'; // IP máy tính của bạn

  static String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:9999'; // Dành cho Web
    } else if (Platform.isAndroid) {
      // Chọn IP phù hợp cho Android
      if (useRealDevice) {
        return 'http://$realDeviceIp:9999'; // Dành cho điện thoại thật
      } else {
        return 'http://10.0.2.2:9999'; // Dành cho Android Emulator
      }
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
  static const String verify2faEndpoint = '/auth/2fa/verify';
  static const String disable2faEndpoint = '/auth/2fa/disable';

  // Product & Category Endpoints
  static const String categoriesEndpoint = '/categories';
  static const String productsEndpoint = '/product';
  static const String manageProductsEndpoint = '/manage-product/products';

  // Cart Endpoints
  static const String cartEndpoint = '/cart';
  static const String cartDeleteEndpoint = '/cart/delete';

  // Order Endpoints
  static const String ordersEndpoint = '/order';

  // Payment Endpoints
  static const String paymentConfigEndpoint = '/payment/config';
  static const String paymentSocketNamespace = '/payment';

  // Discount Endpoints
  static const String myVouchersEndpoint = '/discount/my-vouchers';
  static const String availableDiscountsEndpoint = '/discount/available';
  static const String previewDiscountEndpoint = '/discount/preview';
  static const String discountEndpoint =
      '/discount'; // For Admin/Seller List, Create, Update, Delete
      
  static const String saveDiscountEndpoint = '/discount'; // Needs id and /save appended

  // Search Endpoints
  static const String searchProductsEndpoint = '/product/search';
}
