part of 'auth_bloc.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object> get props => [];
}

// 1. Trạng thái ban đầu (chưa làm gì cả)
class AuthInitial extends AuthState {}

// 2. Đang tải (Hiện vòng quay)
class AuthLoading extends AuthState {
  final UserEntity? user;

  const AuthLoading({this.user});

  @override
  List<Object> get props => [if (user != null) user!];
}

// 3. Thành công (Đăng nhập/Đăng ký xong)
class AuthSuccess extends AuthState {
  final UserEntity user; // Cầm theo thông tin user để hiển thị nếu cần

  const AuthSuccess(this.user);

  @override
  List<Object> get props => [user];
}

// 4. Thất bại (Hiện lỗi màu đỏ)
class AuthFailure extends AuthState {
  final String message;
  final UserEntity? user;

  const AuthFailure(this.message, {this.user});

  @override
  List<Object> get props => [message, if (user != null) user!];
}

// 5. Google Link Thành công (Có link để mở trình duyệt)
class AuthGoogleUrlSuccess extends AuthState {
  final String url;

  const AuthGoogleUrlSuccess(this.url);

  @override
  List<Object> get props => [url];
}

// 6. Gửi OTP thành công
class AuthOtpSentSuccess extends AuthState {}

// 7. Verify OTP thành công (Code đúng)
class AuthVerifyOtpSuccess extends AuthState {}

// 8. Đổi mật khẩu thành công
class AuthResetPasswordSuccessResult extends AuthState {}

// 9. Logout thành công
class AuthLogoutSuccess extends AuthState {}

// 10. Setup 2FA thành công (trả về dữ liệu QR code)
class AuthSetup2FASuccess extends AuthState {
  final Map<String, dynamic> data; // QR code, secret, etc.
  final UserEntity? user;

  const AuthSetup2FASuccess(this.data, {this.user});

  @override
  List<Object> get props => [data, if (user != null) user!];
}

// 11. Disable 2FA thành công
class AuthDisable2FASuccess extends AuthState {
  final UserEntity? user;
  const AuthDisable2FASuccess({this.user});

  @override
  List<Object> get props => [if (user != null) user!];
}

// 12. Verify 2FA thành công (xác nhận bật 2FA)
class AuthVerify2FASuccess extends AuthState {}

// 12. Unauthenticated (không có token hoặc token hết hạn)
class AuthUnauthenticated extends AuthState {}

// 13. Yêu cầu nhập mã 2FA khi đăng nhập
class AuthLoginRequiresTwoFactor extends AuthState {
  final String email;
  final String password;

  const AuthLoginRequiresTwoFactor({
    required this.email,
    required this.password,
  });

  @override
  List<Object> get props => [email, password];
}
