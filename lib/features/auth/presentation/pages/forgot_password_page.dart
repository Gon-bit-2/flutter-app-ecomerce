import 'package:app_fe_ecomerce/core/common/widgets/custom_button.dart';
import 'package:app_fe_ecomerce/core/common/widgets/custom_text_field.dart';
import 'package:app_fe_ecomerce/core/styles/app_colors.dart';
import 'package:app_fe_ecomerce/core/styles/app_text_styles.dart';
import 'package:app_fe_ecomerce/features/auth/presentation/bloc/auth/auth_bloc.dart';
import 'package:app_fe_ecomerce/features/auth/presentation/pages/login_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pinput/pinput.dart';

import '../../../../injection_container.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final PageController _pageController = PageController();
  int _currentStep = 0; // 0: Email, 1: OTP, 2: New Password

  final _emailController = TextEditingController();
  final _otpController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final _step1Key = GlobalKey<FormState>();
  final _step2Key = GlobalKey<FormState>();
  final _step3Key = GlobalKey<FormState>();

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  @override
  void dispose() {
    _pageController.dispose();
    _emailController.dispose();
    _otpController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < 2) {
      setState(() {
        _currentStep++;
      });
      _pageController.animateToPage(
        _currentStep,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _prevStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
      _pageController.animateToPage(
        _currentStep,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<AuthBloc>(),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
            onPressed: () => _prevStep(),
          ),
          title: Text("Quên mật khẩu", style: AppTextStyles.h3),
          centerTitle: true,
        ),
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: BlocConsumer<AuthBloc, AuthState>(
              listener: (context, state) {
                if (state is AuthFailure) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                      backgroundColor: AppColors.error,
                    ),
                  );
                }
                // Step 1: OTP Sent
                if (state is AuthOtpSentSuccess) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Gửi mã OTP thành công!"),
                      backgroundColor: AppColors.success,
                    ),
                  );
                  if (_currentStep == 0) _nextStep();
                }
                // Step 2: OTP Verified
                if (state is AuthVerifyOtpSuccess) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Xác thực OTP thành công!"),
                      backgroundColor: AppColors.success,
                    ),
                  );
                  if (_currentStep == 1) _nextStep();
                }
                // Step 3: Password Reset Success
                if (state is AuthResetPasswordSuccessResult) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        "Đặt lại mật khẩu thành công! Vui lòng đăng nhập.",
                      ),
                      backgroundColor: AppColors.success,
                    ),
                  );

                  // Pop back to login with clean navigation
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const LoginPage()),
                    (route) => false,
                  );
                }
              },
              builder: (context, state) {
                return Column(
                  children: [
                    SizedBox(height: 20.h),
                    Expanded(
                      child: PageView(
                        controller: _pageController,
                        physics: const NeverScrollableScrollPhysics(),
                        children: [
                          _buildStep1Email(context, state),
                          _buildStep2OTP(context, state),
                          _buildStep3NewPassword(context, state),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  // STEP 1
  Widget _buildStep1Email(BuildContext context, AuthState state) {
    return Form(
      key: _step1Key,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            "Nhập Email",
            style: AppTextStyles.h2,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 16.h),
          Text(
            "Chúng tôi sẽ gửi mã xác nhận tới email của bạn.",
            style: AppTextStyles.bodyMedium,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 40.h),
          CustomTextField(
            controller: _emailController,
            hintText: "Email",
            prefixIcon: Icons.email_outlined,
            validator: (v) {
              if (v == null || v.isEmpty) return "Bắt buộc";
              if (!v.contains('@')) return "Email không hợp lệ";
              return null;
            },
          ),
          SizedBox(height: 40.h),
          CustomButton(
            text: "Gửi mã",
            isLoading: state is AuthLoading,
            onPressed: () {
              if (_step1Key.currentState!.validate()) {
                context.read<AuthBloc>().add(
                  AuthSendOtpStarted(
                    email: _emailController.text.trim(),
                    type: 'FORGOT_PASSWORD',
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  // STEP 2
  Widget _buildStep2OTP(BuildContext context, AuthState state) {
    final defaultPinTheme = PinTheme(
      width: 50.w,
      height: 50.w,
      textStyle: AppTextStyles.h2,
      decoration: BoxDecoration(
        color: AppColors.inputBackground,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: Colors.transparent),
      ),
    );

    return Form(
      key: _step2Key,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            "Xác thực",
            style: AppTextStyles.h2,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 16.h),
          Text(
            "Nhập mã 6 số đã gửi tới ${_emailController.text}",
            style: AppTextStyles.bodyMedium,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 40.h),
          Center(
            child: Pinput(
              length: 6,
              controller: _otpController,
              defaultPinTheme: defaultPinTheme,
              focusedPinTheme: defaultPinTheme.copyWith(
                decoration: defaultPinTheme.decoration!.copyWith(
                  border: Border.all(color: AppColors.primaryBlue),
                ),
              ),
              validator: (v) => (v?.length ?? 0) < 6 ? "Nhập đủ 6 số" : null,
              pinputAutovalidateMode: PinputAutovalidateMode.onSubmit,
            ),
          ),
          SizedBox(height: 40.h),
          CustomButton(
            text: "Xác nhận",
            isLoading: state is AuthLoading,
            onPressed: () {
              if (_step2Key.currentState!.validate()) {
                context.read<AuthBloc>().add(
                  AuthVerifyOtpStarted(
                    email: _emailController.text.trim(),
                    code: _otpController.text.trim(),
                    type: 'FORGOT_PASSWORD',
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  // STEP 3
  Widget _buildStep3NewPassword(BuildContext context, AuthState state) {
    return Form(
      key: _step3Key,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              "Đặt lại mật khẩu",
              style: AppTextStyles.h2,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16.h),
            Text(
              "Nhập mật khẩu mới bên dưới.",
              style: AppTextStyles.bodyMedium,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 40.h),

            CustomTextField(
              controller: _newPasswordController,
              hintText: "Mật khẩu mới",
              prefixIcon: Icons.lock_outline,
              obscureText: !_isPasswordVisible,
              suffixIcon: IconButton(
                icon: Icon(
                  _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                  color: AppColors.textSecondary,
                ),
                onPressed: () =>
                    setState(() => _isPasswordVisible = !_isPasswordVisible),
              ),
              validator: (v) => v!.length < 6 ? "Tối thiểu 6 ký tự" : null,
            ),
            SizedBox(height: 16.h),
            CustomTextField(
              controller: _confirmPasswordController,
              hintText: "Xác nhận mật khẩu mới",
              prefixIcon: Icons.lock_outline,
              obscureText: !_isConfirmPasswordVisible,
              suffixIcon: IconButton(
                icon: Icon(
                  _isConfirmPasswordVisible
                      ? Icons.visibility
                      : Icons.visibility_off,
                  color: AppColors.textSecondary,
                ),
                onPressed: () => setState(
                  () => _isConfirmPasswordVisible = !_isConfirmPasswordVisible,
                ),
              ),
              validator: (v) {
                if (v != _newPasswordController.text) {
                  return "Mật khẩu không khớp";
                }
                return null;
              },
            ),

            SizedBox(height: 40.h),
            CustomButton(
              text: "Đặt lại mật khẩu",
              backgroundColor: AppColors.success,
              isLoading: state is AuthLoading,
              onPressed: () {
                if (_step3Key.currentState!.validate()) {
                  context.read<AuthBloc>().add(
                    AuthResetPasswordStarted(
                      email: _emailController.text,
                      code: _otpController.text,
                      newPassword: _newPasswordController.text,
                      confirmNewPassword: _confirmPasswordController.text,
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
