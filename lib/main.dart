// lib/main.dart

import 'package:app_fe_ecomerce/features/home/presentation/pages/home_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart'; // Để UI co giãn
import 'injection_container.dart'; // Import file cấu hình DI
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'features/auth/presentation/bloc/auth/auth_bloc.dart';
import 'features/cart/presentation/bloc/cart/cart_bloc.dart';
import 'features/category/presentation/bloc/category/category_bloc.dart';
import 'features/order/presentation/bloc/order/order_bloc.dart';

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
        return MultiBlocProvider(
          providers: [
            BlocProvider<AuthBloc>(
              create: (context) => GetIt.I<AuthBloc>()..add(AuthCheckStatus()),
            ),
            BlocProvider<CartBloc>(
              create: (context) =>
                  GetIt.I<CartBloc>()..add(const CartLoadRequested()),
            ),
            BlocProvider<CategoryBloc>(
              create: (context) => GetIt.I<CategoryBloc>(),
            ),
            BlocProvider<OrderBloc>(create: (context) => GetIt.I<OrderBloc>()),
          ],
          child: MaterialApp(
            title: 'Ứng dụng TMĐT',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor: const Color(0xFF1A94FF),
              ),
              primaryColor: const Color(0xFF1A94FF),
              useMaterial3: true,
              appBarTheme: const AppBarTheme(
                backgroundColor: Color(0xFF1A94FF),
                foregroundColor: Colors.white,
              ),
            ),
            home: const HomePage(),
          ),
        );
      },
    );
  }
}
