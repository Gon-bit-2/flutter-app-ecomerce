// lib/main.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart'; // Để UI co giãn
import 'injection_container.dart'; // Import file cấu hình DI

void main() async {
  // 1. Đảm bảo Flutter Binding được khởi tạo trước
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Khởi tạo "Tủ đồ" (DI)
  await configureDependencies();

  // 3. Chạy App
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Cấu hình ScreenUtil để UI tự co giãn theo thiết kế (Ví dụ thiết kế chuẩn là 375x812 của iPhone X)
    return ScreenUtilInit(
      designSize: const Size(375, 812), // Kích thước thiết kế chuẩn
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp(
          title: 'E-Commerce App',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
            useMaterial3: true,
          ),
          home: const Scaffold(
            body: Center(child: Text("Setup xong! Sẵn sàng chiến đấu!")),
          ),
        );
      },
    );
  }
}
