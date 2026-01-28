part of 'auth_bloc.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object> get props => [];
}

// 1. Trạng thái ban đầu (chưa làm gì cả)
class AuthInitial extends AuthState {}

// 2. Đang tải (Hiện vòng quay)
class AuthLoading extends AuthState {}

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

  const AuthFailure(this.message);

  @override
  List<Object> get props => [message];
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
