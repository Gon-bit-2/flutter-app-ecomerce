import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../entities/user_entity.dart';

abstract class AuthRepository {
  // Hàm đăng nhập: Nhận email, pass -> Trả về Lỗi hoặc UserEntity
  Future<Either<Failure, UserEntity>> login({
    required String email,
    required String password,
    String? totpCode,
    String? code,
  });

  // Hàm đăng ký
  Future<Either<Failure, UserEntity>> register({
    required String email,
    required String password,
    required String name,
    required String phoneNumber,
    required String confirmPassword,
    required String code,
  });

  // Hàm đăng xuất
  Future<Either<Failure, void>> logout();

  // Send OTP
  Future<Either<Failure, void>> sendOtp({
    required String email,
    required String type,
  });

  Future<Either<Failure, void>> verifyOtp({
    required String email,
    required String code,
    required String type,
  });

  // Refresh Token
  Future<Either<Failure, String>> refreshToken(
    String refreshToken,
  ); // Returns new Access Token? Or void? Usually returns new tokens.

  // Google Link
  Future<Either<Failure, String>> getGoogleAuthUrl();

  // Google Callback
  Future<Either<Failure, UserEntity>> googleCallback({
    required String state,
    required String code,
  });

  // Forgot Password
  Future<Either<Failure, void>> forgotPassword({
    required String email,
    required String code,
    required String newPassword,
    required String confirmNewPassword,
  });

  // Setup 2FA
  Future<Either<Failure, Map<String, dynamic>>> setup2FA();

  // Verify 2FA (xác nhận bật 2FA sau khi setup)
  Future<Either<Failure, void>> verify2FA({required String totpCode});

  // Disable 2FA
  Future<Either<Failure, void>> disable2FA({String? totpCode, String? code});

  // Xử lý Social Login từ Deep Link
  Future<Either<Failure, UserEntity>> processSocialLogin({
    required String accessToken,
    required String refreshToken,
  });
}
