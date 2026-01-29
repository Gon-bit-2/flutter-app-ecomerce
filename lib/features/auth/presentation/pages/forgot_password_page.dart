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
          title: Text("Forgot Password", style: AppTextStyles.h3),
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
                      content: Text("OTP Sent Successfully!"),
                      backgroundColor: AppColors.success,
                    ),
                  );
                  if (_currentStep == 0) _nextStep();
                }
                // Step 2: OTP Verified
                if (state is AuthVerifyOtpSuccess) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("OTP Verified!"),
                      backgroundColor: AppColors.success,
                    ),
                  );
                  if (_currentStep == 1) _nextStep();
                }
                // Step 3: Password Reset Success
                if (state is AuthResetPasswordSuccessResult) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Password Reset Successful! Please Login."),
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
            "Enter Email",
            style: AppTextStyles.h2,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 16.h),
          Text(
            "We will send a verification code to your email.",
            style: AppTextStyles.bodyMedium,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 40.h),
          CustomTextField(
            controller: _emailController,
            hintText: "Email",
            prefixIcon: Icons.email_outlined,
            validator: (v) {
              if (v == null || v.isEmpty) return "Required";
              if (!v.contains('@')) return "Invalid email";
              return null;
            },
          ),
          SizedBox(height: 40.h),
          CustomButton(
            text: "Send Code",
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
            "Verification",
            style: AppTextStyles.h2,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 16.h),
          Text(
            "Enter the 6-digit code sent to ${_emailController.text}",
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
              validator: (v) => (v?.length ?? 0) < 6 ? "Enter 6 digits" : null,
              pinputAutovalidateMode: PinputAutovalidateMode.onSubmit,
            ),
          ),
          SizedBox(height: 40.h),
          CustomButton(
            text: "Verify",
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
              "Reset Password",
              style: AppTextStyles.h2,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16.h),
            Text(
              "Enter your new password below.",
              style: AppTextStyles.bodyMedium,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 40.h),

            CustomTextField(
              controller: _newPasswordController,
              hintText: "New Password",
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
              validator: (v) => v!.length < 6 ? "Min 6 chars" : null,
            ),
            SizedBox(height: 16.h),
            CustomTextField(
              controller: _confirmPasswordController,
              hintText: "Confirm New Password",
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
                  return "Passwords do not match";
                }
                return null;
              },
            ),

            SizedBox(height: 40.h),
            CustomButton(
              text: "Reset Password",
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
