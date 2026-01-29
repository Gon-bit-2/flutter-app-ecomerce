import 'package:app_fe_ecomerce/core/usecase/usecase.dart';
import 'package:app_fe_ecomerce/features/auth/domain/entities/user_entity.dart';
import 'package:app_fe_ecomerce/features/auth/domain/usecases/auth/google_auth_usecase.dart';
import 'package:app_fe_ecomerce/features/auth/domain/usecases/auth/google_callback_usecase.dart';
import 'package:app_fe_ecomerce/features/auth/domain/usecases/auth/login_usecase.dart';
import 'package:app_fe_ecomerce/features/auth/domain/usecases/auth/register_usecase.dart';
import 'package:app_fe_ecomerce/features/auth/domain/usecases/auth/reset_password_usecase.dart';
import 'package:app_fe_ecomerce/features/auth/domain/usecases/auth/send_otp_usecase.dart';
import 'package:app_fe_ecomerce/features/auth/domain/usecases/auth/verify_otp_usecase.dart';
import 'package:app_fe_ecomerce/features/auth/domain/usecases/auth/process_social_login_usecase.dart';
import 'package:app_fe_ecomerce/features/auth/domain/usecases/auth/logout_usecase.dart';
import 'package:app_fe_ecomerce/features/auth/domain/usecases/auth/setup_2fa_usecase.dart';
import 'package:app_fe_ecomerce/features/auth/domain/usecases/auth/disable_2fa_usecase.dart';
import 'package:app_fe_ecomerce/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

part 'auth_event.dart';
part 'auth_state.dart';

@injectable
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase _loginUseCase;
  final RegisterUseCase _registerUseCase;
  final SendOtpUseCase _sendOtpUseCase;
  final VerifyOtpUseCase _verifyOtpUseCase;
  final GoogleAuthUseCase _googleAuthUseCase;
  final GoogleCallbackUseCase _googleCallbackUseCase;
  final ResetPasswordUseCase _resetPasswordUseCase;
  final ProcessSocialLoginUseCase _processSocialLoginUseCase;
  final LogoutUseCase _logoutUseCase;
  final Setup2FAUseCase _setup2FAUseCase;
  final Disable2FAUseCase _disable2FAUseCase;
  final AuthLocalDataSource _localDataSource;

  // Constructor: Khởi tạo với trạng thái Initial
  AuthBloc(
    this._loginUseCase,
    this._registerUseCase,
    this._sendOtpUseCase,
    this._verifyOtpUseCase,
    this._googleAuthUseCase,
    this._googleCallbackUseCase,
    this._resetPasswordUseCase,
    this._processSocialLoginUseCase,
    this._logoutUseCase,
    this._setup2FAUseCase,
    this._disable2FAUseCase,
    this._localDataSource,
  ) : super(AuthInitial()) {
    // 1. Xử lý Đăng Nhập
    on<AuthLoginStarted>((event, emit) async {
      emit(AuthLoading());
      final result = await _loginUseCase(
        LoginParams(email: event.email, password: event.password),
      );
      result.fold(
        (failure) => emit(AuthFailure(failure.message)),
        (user) => emit(AuthSuccess(user)),
      );
    });

    // 2. Xử lý Đăng Ký
    on<AuthRegisterStarted>((event, emit) async {
      emit(AuthLoading());
      final result = await _registerUseCase(
        RegisterParams(
          email: event.email,
          password: event.password,
          name: event.name,
          phoneNumber: event.phoneNumber,
          confirmPassword: event.confirmPassword,
          code: event.code,
        ),
      );
      result.fold(
        (failure) => emit(AuthFailure(failure.message)),
        (user) => emit(AuthSuccess(user)),
      );
    });

    // 3. Xử lý Gửi OTP
    on<AuthSendOtpStarted>((event, emit) async {
      emit(AuthLoading());
      final result = await _sendOtpUseCase(
        SendOtpParams(email: event.email, type: event.type),
      );
      result.fold(
        (failure) => emit(AuthFailure(failure.message)),
        (_) => emit(AuthOtpSentSuccess()),
      );
    });

    // 4. Verify OTP
    on<AuthVerifyOtpStarted>((event, emit) async {
      emit(AuthLoading());
      final result = await _verifyOtpUseCase(
        VerifyOtpParams(email: event.email, code: event.code, type: event.type),
      );
      result.fold(
        (failure) => emit(AuthFailure(failure.message)),
        (_) => emit(AuthVerifyOtpSuccess()),
      );
    });

    // 5. Lấy Link Google
    on<AuthGoogleUrlRequested>((event, emit) async {
      emit(AuthLoading());
      final result = await _googleAuthUseCase(NoParams());
      result.fold(
        (failure) => emit(AuthFailure(failure.message)),
        (url) => emit(AuthGoogleUrlSuccess(url)),
      );
    });

    // 6. Xử lý Google Callback (Legacy / Manual)
    on<AuthGoogleCallbackReceived>((event, emit) async {
      emit(AuthLoading());
      final result = await _googleCallbackUseCase(
        GoogleCallbackParams(state: event.state, code: event.code),
      );
      result.fold(
        (failure) => emit(AuthFailure(failure.message)),
        (user) => emit(AuthSuccess(user)),
      );
    });

    // 7. Xử lý Social Login Token (Deep Link)
    on<AuthSocialLoginTokenReceived>((event, emit) async {
      emit(AuthLoading());
      final result = await _processSocialLoginUseCase(
        ProcessSocialLoginParams(
          accessToken: event.accessToken,
          refreshToken: event.refreshToken,
        ),
      );
      result.fold(
        (failure) => emit(AuthFailure(failure.message)),
        (user) => emit(AuthSuccess(user)),
      );
    });

    // 8. Reset Password
    on<AuthResetPasswordStarted>((event, emit) async {
      emit(AuthLoading());
      final result = await _resetPasswordUseCase(
        ResetPasswordParams(
          email: event.email,
          code: event.code,
          newPassword: event.newPassword,
          confirmNewPassword: event.confirmNewPassword,
        ),
      );
      result.fold(
        (failure) => emit(AuthFailure(failure.message)),
        (_) => emit(AuthResetPasswordSuccessResult()),
      );
    });

    // 9. Logout
    on<AuthLogoutRequested>((event, emit) async {
      emit(AuthLoading());
      final result = await _logoutUseCase(NoParams());
      result.fold(
        (failure) => emit(AuthFailure(failure.message)),
        (_) => emit(AuthLogoutSuccess()),
      );
    });

    // 10. Setup 2FA
    on<AuthSetup2FAStarted>((event, emit) async {
      emit(AuthLoading());
      final result = await _setup2FAUseCase(NoParams());
      result.fold(
        (failure) => emit(AuthFailure(failure.message)),
        (data) => emit(AuthSetup2FASuccess(data)),
      );
    });

    // 11. Disable 2FA
    on<AuthDisable2FAStarted>((event, emit) async {
      emit(AuthLoading());
      final result = await _disable2FAUseCase(
        Disable2FAParams(totpCode: event.totpCode, code: event.code),
      );
      result.fold(
        (failure) => emit(AuthFailure(failure.message)),
        (_) => emit(AuthDisable2FASuccess()),
      );
    });

    // 12. Check Authentication Status
    on<AuthCheckStatus>((event, emit) async {
      final token = await _localDataSource.getAccessToken();
      if (token != null && token.isNotEmpty) {
        // Token exists, try to get profile
        final result = await _processSocialLoginUseCase(
          ProcessSocialLoginParams(
            accessToken: token,
            refreshToken: await _localDataSource.getRefreshToken() ?? '',
          ),
        );
        result.fold(
          (failure) => emit(AuthUnauthenticated()),
          (user) => emit(AuthSuccess(user)),
        );
      } else {
        emit(AuthUnauthenticated());
      }
    });
  }
}
