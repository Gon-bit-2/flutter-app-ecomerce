// lib/core/constants/app_constants.dart

class AppConstants {
  // Tránh việc khởi tạo class này
  const AppConstants._();

  // URL API gốc
  // Nếu chạy Android Emulator: dùng 10.0.2.2
  // Nếu chạy iOS Simulator: dùng localhost
  // Nếu chạy máy thật: dùng địa chỉ IP LAN của máy tính (VD: 192.168.1.X)
  static const String baseUrl = 'http://10.0.2.2:9999';

  // Thời gian chờ kết nối tối đa (30 giây)
  static const int connectTimeout = 30000;
  static const int receiveTimeout = 30000;

  // Key để lưu Token vào bộ nhớ máy
  static const String accessTokenKey = 'accessToken';
}
