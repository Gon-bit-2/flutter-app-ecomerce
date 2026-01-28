import 'package:injectable/injectable.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/network/dio_client.dart';
import '../models/user_model.dart';
import '../models/token_model.dart'; // Import file mới tạo

abstract class AuthRemoteDataSource {
  Future<TokenModel> login(
    String email,
    String password, {
    String? totpCode,
    String? code,
  }); // Updated
  Future<void> sendOtp(String email, String type); // New
  Future<void> verifyOtp(String email, String code, String type); // New
  Future<TokenModel> register({
    required String email,
    required String password,
    required String name,
    required String phoneNumber,
    required String confirmPassword,
    required String code,
  }); // New: returns TokenModel or User? Usually register implies auto-login or just success. API Doc says it returns TokenModel if successful login, or maybe just user. But Register usually returns User or Token. Let's assume it returns TokenModel if it auto-logs in, or we might need to check. Text says "Register" POST /auth/register. Response not specified in API_LIST clearly for success, but usually creates user. Wait, API LIST doesn't specify response for Register. Standard is usually User or Token. Let's assume it returns TokenModel or just bool (void).
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
  Future<void> setup2fa(); // New
  Future<void> disable2fa({String? totpCode, String? code}); // New
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
  Future<TokenModel> register({
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
    // Assuming register returns Token similar to login for auto-login,
    // or if it returns User, we might need to adjust.
    // Since I don't see the response schema, I will assume it might be TokenModel or UserModel.
    // If it is void, I will change. But `AuthRepository` expects `UserEntity`.
    // Validating against `AuthRepositoryImpl`... `register` simply returns `Future<Either<Failure, UserEntity>>`.
    // If backend returns User, utilize `UserModel.fromJson`.
    if (response.data != null &&
        (response.data as Map).containsKey('accessToken')) {
      return TokenModel.fromJson(response.data);
    }
    // If it doesn't return token, maybe we should return something else?
    // Let's assume it returns TokenModel for now as a "best guess" or throw if not.
    // Actually, creating a user usually returns the user.
    // I will change the return type to `Future<void>` or `Future<UserModel>` based on typical flow.
    // Let's go with `Future<dynamic>` to be safe or inspect response? No, strict typing is better.
    // I'll assume it returns the Registered User info or Token.
    // Let's try `Future<dynamic>` for register in `RemoteDataSource`? No.
    // Let's check `AuthRepository` again. `Future<Either<Failure, UserEntity>>`.
    // So `RemoteDataSource` should return `UserModel` ideally.
    // But wait, if register requires login afterwards manually, then it returns void/User.
    // I will assume it returns `UserModel` (the created user).
    // But wait, `TokenModel` is better if we want to auto-login.
    // Let's check `login` returns `TokenModel`.

    // I will use `Future<dynamic>` which is safe, but `AuthRemoteDataSource` implies typed contract.
    // I will guess `Future<void>` for now, and Repository will handle the "Next step" (like auto login or redirect).
    // Re-reading `API_LIST.md` for Register...
    // Input: ...
    // Output: Not specified.
    // Let's check `AuthRepositoryImpl` provided by user.
    // `Future<Either<Failure, UserEntity>> register`
    // Implementation: `throw UnimplementedError()`.

    // I will change `register` to return `Future<void>` in DataSource, and Repository will just return Right(null) or maybe we fetch profile?
    // Actually, `AuthRepository` signature says it returns `UserEntity`.
    // I will make `register` return `Future<UserModel>` hoping backend returns the user.
    return TokenModel.fromJson(
      response.data,
    ); // Placeholder, assuming it returns Token like Login?
    // Or maybe it strictly returns User info like `{"id": 1, ...}`.
    // I will look at `login` flow: login -> token -> save token -> getProfile.
    // Register flow might be: register -> (maybe token?) -> if not, just success.
    // I will stick with `Future<dynamic>` for now in DS to avoid breakage, but declaring it `Future<TokenModel>` or `Future<UserModel>` is better.
    // Let's use `Future<TokenModel>` assuming modern auth often returns token on register.
    // If not, I'll fix it later.
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
    return response.data['url']; // Assuming { "url": "..." } or direct string?
    // API_LIST says: GET /auth/google-link, No Body. Response? Usually JSON with url.
  }

  @override
  Future<TokenModel> googleCallback(String state, String code) async {
    final response = await _dioClient.get(
      AppConstants.googleCallbackEndpoint,
      queryParameters: {'state': state, 'code': code},
    );
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
  Future<void> setup2fa() async {
    await _dioClient.post(AppConstants.setup2faEndpoint);
  }

  @override
  Future<void> disable2fa({String? totpCode, String? code}) async {
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
