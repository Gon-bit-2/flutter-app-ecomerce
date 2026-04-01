import 'dart:convert';
import 'package:injectable/injectable.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/network/dio_client.dart';
import '../models/user_model.dart';
import '../models/token_model.dart'; // Import file mới tạo
import 'package:dio/dio.dart';

abstract class AuthRemoteDataSource {
  Future<TokenModel> login(
    String email,
    String password, {
    String? totpCode,
    String? code,
  }); // Updated
  Future<void> sendOtp(String email, String type); // New
  Future<void> verifyOtp(String email, String code, String type); // New
  Future<UserModel> register({
    required String email,
    required String password,
    required String name,
    required String phoneNumber,
    required String confirmPassword,
    required String code,
  });
  // Re-reading API_LIST... "Register" doesn't show response. "Login" shows response.
  // "Register" -> usually simply creates user. But if we want to auto login, it might return token.
  // Let's assume for now it returns void (success) or maybe TokenModel if backend supports it.
  // Checking `login` response: `accessToken`, `refreshToken`.
  // Checking `register` usually doesn't return token unless specified.
  // Let's make it return `Future<void>` for now, or `Future<TokenModel>` if I want to be safe?
  // User asked to "Follow docs". Docs don't say.
  // Safest is `Future<dynamic>` or check standard.
  // Let's look at `login` again.
  // I will assume simple implementation: `Future<void>` for register unless user wants auto-login.
  // However, looking at the code `AuthRepositoryImpl` references `register` returning `Either<Failure, UserEntity>`. So `RemoteDataSource` should probably return `UserModel` or `void`.
  // Let's stick to `Future<void>` for register if the backend just says "Created". If it returns data, I can change.
  // Actually, standard usually returns the created user. I'll define it as `Future<UserModel>` or `Future<void>`.
  // Let's check `AuthRemoteDataSource::login` returns `TokenModel`.
  // Let's check `AuthRepositoryImpl::register` which creates `UserEntity`. So `register` probably returns `UserModel`.

  Future<TokenModel> refreshToken(String refreshToken); // New
  Future<void> logout(String refreshToken); // New
  Future<String> googleLink(); // New: returns URL
  Future<TokenModel> googleCallback(
    String state,
    String code,
  ); // New: returns Token?
  Future<void> forgotPassword({
    required String email,
    required String code,
    required String newPassword,
    required String confirmNewPassword,
  }); // New
  Future<Map<String, dynamic>> setup2FA(); // Returns QR code data
  Future<void> verify2FA({required String totpCode}); // Confirm 2FA setup
  Future<void> disable2FA({String? totpCode, String? code});
  Future<UserModel> getProfile();
}

@LazySingleton(as: AuthRemoteDataSource)
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final DioClient _dioClient;

  AuthRemoteDataSourceImpl(this._dioClient);

  @override
  Future<TokenModel> login(
    String email,
    String password, {
    String? totpCode,
    String? code,
  }) async {
    final response = await _dioClient.post(
      AppConstants.loginEndpoint,
      data: {
        'email': email,
        'password': password,
        if (totpCode != null) 'totpCode': totpCode,
        if (code != null) 'code': code,
      },
    );
    return TokenModel.fromJson(response.data);
  }

  @override
  Future<void> sendOtp(String email, String type) async {
    await _dioClient.post(
      AppConstants.otpEndpoint,
      data: {'email': email, 'type': type},
    );
  }

  @override
  Future<void> verifyOtp(String email, String code, String type) async {
    await _dioClient.post(
      AppConstants.verifyOtpEndpoint,
      data: {'email': email, 'code': code, 'type': type},
    );
  }

  @override
  Future<UserModel> register({
    required String email,
    required String password,
    required String name,
    required String phoneNumber,
    required String confirmPassword,
    required String code,
  }) async {
    final response = await _dioClient.post(
      AppConstants.registerEndpoint,
      data: {
        'email': email,
        'password': password,
        'name': name,
        'phoneNumber': phoneNumber,
        'confirmPassword': confirmPassword,
        'code': code,
      },
    );
    return UserModel.fromJson(response.data);
  }

  @override
  Future<TokenModel> refreshToken(String refreshToken) async {
    final response = await _dioClient.post(
      AppConstants.refreshTokenEndpoint,
      data: {'refreshToken': refreshToken},
    );
    return TokenModel.fromJson(response.data);
  }

  @override
  Future<void> logout(String refreshToken) async {
    await _dioClient.post(
      AppConstants.logoutEndpoint,
      data: {'refreshToken': refreshToken},
    );
  }

  @override
  Future<String> googleLink() async {
    final response = await _dioClient.get(AppConstants.googleLinkEndpoint);
    if (response.data is String) {
      try {
        final Map<String, dynamic> data = jsonDecode(response.data);
        return data['url'];
      } catch (e) {
        // Fallback: maybe the string itself is the url? Unlikely given the JSON format.
        // Or if jsonDecode fails
        throw Exception(
          "Failed to parse Google Link response: ${response.data}",
        );
      }
    }
    // If it's already a Map (Dio handled it)
    if (response.data is Map<String, dynamic>) {
      return response.data['url'];
    }
    // Fallback for dynamic/other types
    return (response.data as Map)['url'];
  }

  @override
  Future<TokenModel> googleCallback(String state, String code) async {
    final response = await _dioClient.get(
      AppConstants.googleCallbackEndpoint,
      queryParameters: {'state': state, 'code': code},
      options: Options(
        followRedirects: false,
        validateStatus: (status) => status != null && status < 500,
      ),
    );

    // Chặn lỗi Unsupported scheme của Dio
    // Backend trả về redirect 302 về appecomerce://callback?accessToken=...&refreshToken=...
    if (response.statusCode == 302 || response.statusCode == 301) {
      final location = response.headers.value('location');
      if (location != null) {
        final uri = Uri.parse(location);
        final accessToken = uri.queryParameters['accessToken'];
        final refreshToken = uri.queryParameters['refreshToken'];
        if (accessToken != null && refreshToken != null) {
          return TokenModel(
            accessToken: accessToken,
            refreshToken: refreshToken,
          );
        }
      }
    }

    return TokenModel.fromJson(response.data);
  }

  @override
  Future<void> forgotPassword({
    required String email,
    required String code,
    required String newPassword,
    required String confirmNewPassword,
  }) async {
    await _dioClient.post(
      AppConstants.forgotPasswordEndpoint,
      data: {
        'email': email,
        'code': code,
        'newPassword': newPassword,
        'confirmNewPassword': confirmNewPassword,
      },
    );
  }

  @override
  Future<Map<String, dynamic>> setup2FA() async {
    final response = await _dioClient.post(
      AppConstants.setup2faEndpoint,
      data: {},
    );
    return Map<String, dynamic>.from(response.data);
  }

  @override
  Future<void> verify2FA({required String totpCode}) async {
    await _dioClient.post(
      AppConstants.verify2faEndpoint,
      data: {'totpCode': totpCode},
    );
  }

  @override
  Future<void> disable2FA({String? totpCode, String? code}) async {
    await _dioClient.post(
      AppConstants.disable2faEndpoint,
      data: {
        if (totpCode != null) 'totpCode': totpCode,
        if (code != null) 'code': code,
      },
    );
  }

  @override
  Future<UserModel> getProfile() async {
    // Gọi API lấy thông tin user (API này cần Header Token, Dio sẽ tự lo nếu Token đã được lưu)
    final response = await _dioClient.get(AppConstants.profileEndpoint);
    return UserModel.fromJson(response.data);
  }
}
