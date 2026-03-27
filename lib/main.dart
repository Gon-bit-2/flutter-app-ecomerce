// lib/main.dart

import 'dart:async';

import 'package:app_fe_ecomerce/core/services/deep_link_service.dart';
import 'package:app_fe_ecomerce/features/home/presentation/pages/home_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart'; // Để UI co giãn
import 'injection_container.dart'; // Import file cấu hình DI
import 'core/styles/app_theme.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'features/auth/presentation/bloc/auth/auth_bloc.dart';
import 'features/cart/presentation/bloc/cart/cart_bloc.dart';
import 'features/category/presentation/bloc/category/category_bloc.dart';
import 'features/order/presentation/bloc/order/order_bloc.dart';
import 'features/address/presentation/bloc/address_bloc.dart';
import 'features/address/presentation/bloc/address_event.dart';

void main() async {
  // 1. Đảm bảo Flutter Binding được khởi tạo trước
  WidgetsFlutterBinding.ensureInitialized();
  debugPrint('[Main] Flutter Binding Initialized');

  // 2. Khởi tạo "Tủ đồ" (DI)
  debugPrint('[Main] Configuring Dependencies...');
  try {
    await configureDependencies();
    debugPrint('[Main] Dependencies Configured');
  } catch (e) {
    debugPrint('[Main] Error configuring dependencies: $e');
  }

  // 3. Chạy App (DeepLinkService sẽ được khởi tạo trong MyApp để không block UI)
  debugPrint('[Main] App Started');
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  StreamSubscription? _deepLinkSub;

  @override
  void initState() {
    super.initState();
    _initDeepLink();
  }

  /// Khởi tạo DeepLinkService sau khi UI đã sẵn sàng (non-blocking)
  Future<void> _initDeepLink() async {
    try {
      final deepLinkService = GetIt.I<DeepLinkService>();
      debugPrint('[Main] Initializing DeepLinkService...');
      await deepLinkService.init();
      debugPrint('[Main] DeepLinkService Initialized');
    } catch (e) {
      debugPrint('[Main] Error initializing DeepLinkService: $e');
    }
  }

  @override
  void dispose() {
    _deepLinkSub?.cancel();
    super.dispose();
  }

  void _setupDeepLinkListener(BuildContext context) {
    // Tránh đăng ký nhiều lần
    if (_deepLinkSub != null) return;

    final deepLinkService = GetIt.I<DeepLinkService>();
    _deepLinkSub = deepLinkService.deepLinkStream.listen((uri) {
      debugPrint('[Main] DeepLink received: $uri');
      final accessToken = uri.queryParameters['accessToken'];
      final refreshToken = uri.queryParameters['refreshToken'];
      if (accessToken != null && refreshToken != null) {
        context.read<AuthBloc>().add(
          AuthSocialLoginTokenReceived(
            accessToken: accessToken,
            refreshToken: refreshToken,
          ),
        );
      }
    });
  }

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
            BlocProvider<AddressBloc>(
              create: (context) =>
                  GetIt.I<AddressBloc>()..add(GetAddressesEvent()),
            ),
          ],
          child: MaterialApp(
            title: 'Ứng dụng TMĐT',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            home: Builder(
              builder: (context) {
                // Đăng ký lắng nghe deep link ở cấp toàn cục, có quyền truy cập BlocProvider
                _setupDeepLinkListener(context);
                return const HomePage();
              },
            ),
          ),
        );
      },
    );
  }
}
