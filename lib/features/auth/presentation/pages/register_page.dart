import 'package:app_fe_ecomerce/core/common/widgets/custom_button.dart';
import 'package:app_fe_ecomerce/core/common/widgets/custom_text_field.dart';
import 'package:app_fe_ecomerce/core/styles/app_colors.dart';
import 'package:app_fe_ecomerce/core/styles/app_text_styles.dart';
import 'package:app_fe_ecomerce/features/auth/presentation/bloc/auth/auth_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pinput/pinput.dart';



class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final PageController _pageController = PageController();
  int _currentStep = 0; // 0: Email, 1: OTP, 2: Info

  // Controllers
  final _emailController = TextEditingController();
  final _otpController = TextEditingController();

  // Info
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPassController = TextEditingController();

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
    _nameController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPassController.dispose();
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
    return Scaffold(
      backgroundColor: Colors.white, // AppColors.background
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
            onPressed: () => _prevStep(),
          ),
          actions: [
            IconButton(
              icon: const Icon(
                Icons.help_outline,
                color: AppColors.primaryBlue,
              ),
              onPressed: () {},
            ),
          ],
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
                if (state is AuthOtpSentSuccess) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Mã xác nhận đã được gửi!"),
                      backgroundColor: AppColors.success,
                    ),
                  );
                  if (_currentStep == 0) _nextStep();
                }
                if (state is AuthSuccess) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Đăng ký thành công!"),
                      backgroundColor: AppColors.success,
                    ),
                  );
                  // Quay về trang chủ (isFirst)
                  Navigator.of(context).popUntil((route) => route.isFirst);
                }
                if (state is AuthVerifyOtpSuccess) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Xác thực OTP thành công!"),
                      backgroundColor: AppColors.success,
                    ),
                  );
                  _nextStep();
                }
              },
              builder: (context, state) {
                return Column(
                  children: [
                    // Progress Indicator (Custom)
                    // _buildProgressIndicator(),
                    SizedBox(height: 20.h),

                    Expanded(
                      child: PageView(
                        controller: _pageController,
                        physics: const NeverScrollableScrollPhysics(),
                        children: [
                          _buildStep1Email(context, state),
                          _buildStep2OTP(context, state),
                          _buildStep3Info(context, state),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      );
  }

  // --- STEP 1: EMAIL ---
  Widget _buildStep1Email(BuildContext context, AuthState state) {
    return Form(
      key: _step1Key,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text("Đăng ký", style: AppTextStyles.h1),
          SizedBox(height: 8.h),
          Text(
            "Bước 1 / 3: Nhập email để bắt đầu",
            style: AppTextStyles.bodyMedium,
          ),
          SizedBox(height: 40.h),

          Text(
            "Địa chỉ Email",
            style: AppTextStyles.bodyLarge.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 8.h),
          CustomTextField(
            controller: _emailController,
            hintText: "example@email.com",
            keyboardType: TextInputType.emailAddress,
            suffixIcon: const Icon(
              Icons.email_outlined,
              color: AppColors.textSecondary,
            ),
            validator: (v) {
              if (v == null || v.isEmpty) return "Vui lòng nhập email";
              final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
              if (!emailRegex.hasMatch(v)) return "Email không đúng định dạng";
              return null;
            },
          ),

          SizedBox(height: 40.h),
          CustomButton(
            text: "Tiếp theo",
            isLoading: state is AuthLoading,
            onPressed: () {
              if (_step1Key.currentState!.validate()) {
                context.read<AuthBloc>().add(
                  AuthSendOtpStarted(email: _emailController.text.trim()),
                );
              }
            },
            // The design has an arrow, CustomButton is simple.
            // We can enhance CustomButton later or just use text for now.
          ),

          SizedBox(height: 24.h),
          // Progress Bar Placeholder or similar if needed as per design "Step 1"
          // Design shows a simple progress bar at bottom, can implement if needed.
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Đã có tài khoản? ", style: AppTextStyles.bodyMedium),
              GestureDetector(
              onTap: () {
                Navigator.of(context).pop();
              },
                child: Text(
                  "Đăng nhập",
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.primaryBlue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 20.h),
        ],
      ),
    );
  }

  // --- STEP 2: OTP ---
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

    final focusedPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration!.copyWith(
        border: Border.all(color: AppColors.primaryBlue),
      ),
    );

    final submittedPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration!.copyWith(
        color: AppColors.primaryBlue.withOpacity(0.1),
      ),
    );

    return Form(
      key: _step2Key,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Title
          Center(child: Text("Xác thực", style: AppTextStyles.h3)),
          SizedBox(height: 40.h),

          Center(child: Text("Nhập mã OTP", style: AppTextStyles.h1)),
          SizedBox(height: 16.h),
          Text(
            "Nhập mã 6 số đã gửi tới email:\n${_emailController.text}",
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMedium,
          ),
          SizedBox(height: 40.h),

          // Pinput
          Center(
            child: Pinput(
              length: 6,
              controller: _otpController,
              defaultPinTheme: defaultPinTheme,
              focusedPinTheme: focusedPinTheme,
              submittedPinTheme: submittedPinTheme,
              validator: (v) => (v?.length ?? 0) < 6 ? "Nhập đủ 6 số" : null,
              pinputAutovalidateMode: PinputAutovalidateMode.onSubmit,
              showCursor: true,
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
                  ),
                );
              }
            },
          ),

          SizedBox(height: 24.h),
          Center(
            child: TextButton(
              onPressed: state is AuthLoading
                  ? null
                  : () {
                      context.read<AuthBloc>().add(
                        AuthSendOtpStarted(email: _emailController.text),
                      );
                    },
              child: Text(
                "Không nhận được mã? Gửi lại",
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.primaryBlue,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- STEP 3: INFO ---
  Widget _buildStep3Info(BuildContext context, AuthState state) {
    return Form(
      key: _step3Key,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text("Hoàn tất hồ sơ", style: AppTextStyles.h1),
            SizedBox(height: 8.h),
            Text(
              "Bước 3 / 3: Điền thông tin cá nhân",
              style: AppTextStyles.bodyMedium,
            ),
            SizedBox(height: 30.h),

            CustomTextField(
              controller: _nameController,
              hintText: "Họ và tên",
              prefixIcon: Icons.person_outline,
              validator: (v) => v!.isEmpty ? "Bắt buộc" : null,
            ),
            SizedBox(height: 16.h),

            CustomTextField(
              controller: _phoneController,
              hintText: "Số điện thoại",
              prefixIcon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
              validator: (v) {
                if (v == null || v.isEmpty) return "Vui lòng nhập số điện thoại";
                final phoneRegex = RegExp(r'^(0|\+84)[3-9]\d{8}$');
                if (!phoneRegex.hasMatch(v)) return "Số điện thoại không hợp lệ";
                return null;
              },
            ),
            SizedBox(height: 16.h),

            CustomTextField(
              controller: _passwordController,
              hintText: "Mật khẩu",
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
              validator: (v) {
                if (v == null || v.isEmpty) return "Vui lòng nhập mật khẩu";
                if (v.length < 6) return "Mật khẩu phải có ít nhất 6 ký tự";
                return null;
              },
            ),
            SizedBox(height: 16.h),

            CustomTextField(
              controller: _confirmPassController,
              hintText: "Xác nhận mật khẩu",
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
                if (v != _passwordController.text) {
                  return "Mật khẩu không khớp";
                }
                return null;
              },
            ),

            SizedBox(height: 40.h),

            CustomButton(
              text: "Đăng ký",
              backgroundColor: AppColors.success,
              isLoading: state is AuthLoading,
              onPressed: () {
                if (_step3Key.currentState!.validate()) {
                  context.read<AuthBloc>().add(
                    AuthRegisterStarted(
                      email: _emailController.text,
                      password: _passwordController.text,
                      name: _nameController.text,
                      phoneNumber: _phoneController.text,
                      confirmPassword: _confirmPassController.text,
                      code: _otpController.text,
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
