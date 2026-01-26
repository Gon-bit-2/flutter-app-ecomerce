// lib/core/di/register_module.dart

import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

@module
abstract class RegisterModule {
  // Cung cấp Dio cho toàn App
  @lazySingleton
  Dio get dio => Dio();

  // Cung cấp SharedPreferences (để lưu token) cần chờ (await) nên dùng @preResolve
  @preResolve
  Future<SharedPreferences> get prefs => SharedPreferences.getInstance();

  // Cung cấp Connectivity để check kết nối internet
  @lazySingleton
  Connectivity get connectivity => Connectivity();
}
