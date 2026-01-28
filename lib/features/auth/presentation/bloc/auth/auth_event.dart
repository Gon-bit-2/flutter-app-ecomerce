part of 'auth_bloc.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object> get props => [];
}

// sự kiện đăng ký (Đổi tên cho đồng bộ)
class AuthRegisterStarted extends AuthEvent {
  final String email;
  final String password;
  final String name;
  final String phoneNumber;
  final String confirmPassword;
  final String code;

  const AuthRegisterStarted({
    required this.email,
    required this.password,
    required this.name,
    required this.phoneNumber,
    required this.confirmPassword,
    required this.code,
  });

  @override
  List<Object> get props => [
    email,
    password,
    name,
    phoneNumber,
    confirmPassword,
    code,
  ];
}

// sự kiện Bấm nút Google để lấy Link
class AuthGoogleUrlRequested extends AuthEvent {}

// Sự kiện Xử lý khi Google trả về kết quả (Callback)
class AuthGoogleCallbackReceived extends AuthEvent {
  final String state;
  final String code;

  const AuthGoogleCallbackReceived({required this.state, required this.code});

  @override
  List<Object> get props => [state, code];
}

// Sự kiện: Người dùng bấm nút Đăng nhập
class AuthLoginStarted extends AuthEvent {
  final String email;
  final String password;

  const AuthLoginStarted({required this.email, required this.password});

  @override
  List<Object> get props => [email, password];
}

// Sự kiện: Người dùng bấm Logout
class AuthLogoutRequested extends AuthEvent {}

// Sự kiện: Yêu cầu gửi OTP
class AuthSendOtpStarted extends AuthEvent {
  final String email;
  final String type; // 'REGISTER' | 'FORGOT_PASSWORD'

  const AuthSendOtpStarted({
    required this.email,
    this.type = 'REGISTER',
  }); // Server require Uppercase

  @override
  List<Object> get props => [email, type];
}

class AuthVerifyOtpStarted extends AuthEvent {
  final String email;
  final String code;
  final String type; // 'REGISTER'

  const AuthVerifyOtpStarted({
    required this.email,
    required this.code,
    this.type = 'REGISTER',
  });

  @override
  List<Object> get props => [email, code, type];
}

class AuthResetPasswordStarted extends AuthEvent {
  final String email;
  final String code;
  final String newPassword;
  final String confirmNewPassword;

  const AuthResetPasswordStarted({
    required this.email,
    required this.code,
    required this.newPassword,
    required this.confirmNewPassword,
  });

  @override
  List<Object> get props => [email, code, newPassword, confirmNewPassword];
}

class AuthResetPasswordSuccess extends AuthEvent {}
