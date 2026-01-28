// lib/injection_container.dart

import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'injection_container.config.dart'; // <-- Dòng này sẽ báo lỗi đỏ, ĐỪNG LO!

// Khởi tạo biến toàn cục cho "Tủ đồ"
final getIt = GetIt.instance;
@InjectableInit(
  initializerName: 'init', // Tên hàm khởi tạo mặc định
  preferRelativeImports: true, // Dùng import tương đối cho gọn
  asExtension: true, // Tạo hàm mở rộng
)
Future<void> configureDependencies() async => await getIt.init();
