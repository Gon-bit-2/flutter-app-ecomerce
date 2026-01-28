import 'package:app_fe_ecomerce/core/usecase/usecase.dart';
import 'package:app_fe_ecomerce/features/auth/domain/entities/user_entity.dart';
import 'package:app_fe_ecomerce/features/auth/domain/usecases/auth/google_auth_usecase.dart';
import 'package:app_fe_ecomerce/features/auth/domain/usecases/auth/google_callback_usecase.dart';
import 'package:app_fe_ecomerce/features/auth/domain/usecases/auth/login_usecase.dart';
import 'package:app_fe_ecomerce/features/auth/domain/usecases/auth/register_usecase.dart';
import 'package:app_fe_ecomerce/features/auth/domain/usecases/auth/reset_password_usecase.dart';
import 'package:app_fe_ecomerce/features/auth/domain/usecases/auth/send_otp_usecase.dart';
import 'package:app_fe_ecomerce/features/auth/domain/usecases/auth/verify_otp_usecase.dart';
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
  final VerifyOtpUseCase _verifyOtpUseCase; // New
  final GoogleAuthUseCase _googleAuthUseCase;
  final GoogleCallbackUseCase _googleCallbackUseCase;
  final ResetPasswordUseCase _resetPasswordUseCase;

  // Constructor: Khởi tạo với trạng thái Initial
  AuthBloc(
    this._loginUseCase,
    this._registerUseCase,
    this._sendOtpUseCase,
    this._verifyOtpUseCase,
    this._googleAuthUseCase,
    this._googleCallbackUseCase,
    this._resetPasswordUseCase,
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
      // GoogleAuthUseCase dùng NoParams (nếu bạn đã sửa usecase nhận NoParams)
      // Nếu chưa sửa file usecase thì phải xem lại, nhưng theo logic trước đó đã sửa thành NoParams.
      // Cần import NoParams từ core/usecase/usecase.dart nếu chưa có.
      // Dựa vào các import hiện tại, file usecase.dart của project có NoParams.
      // Tuy nhiên AuthBloc chưa import UseCase class chứa NoParams.
      // Ta cứ gọi, nếu lỗi import sẽ fix sau. Nhưng tốt nhất là check import.
      // File `auth_bloc.dart` imports `login_usecase.dart` -> `usecase.dart`.
      // Nhưng LoginUseCase, RegisterUseCase export UseCase class? Không.
      // Ta cần import `core/usecase/usecase.dart` để dùng NoParams.

      final result = await _googleAuthUseCase(NoParams());
      result.fold(
        (failure) => emit(AuthFailure(failure.message)),
        (url) => emit(AuthGoogleUrlSuccess(url)),
      );
    });

    // 5. Xử lý Google Callback
    // 5. Xử lý Google Callback
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

    // 6. Reset Password
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
  }
}
