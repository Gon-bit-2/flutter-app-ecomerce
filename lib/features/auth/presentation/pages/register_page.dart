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
      backgroundColor: Colors.white,
      body: SafeArea(
        child: BlocConsumer<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is AuthFailure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: AppColors.error,
                  behavior: SnackBarBehavior.floating,
                  margin: EdgeInsets.all(16.w),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
                ),
              );
            }
            if (state is AuthOtpSentSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text("Mã xác nhận đã được gửi!"),
                  backgroundColor: AppColors.success,
                  behavior: SnackBarBehavior.floating,
                  margin: EdgeInsets.all(16.w),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
                ),
              );
              if (_currentStep == 0) _nextStep();
            }
            if (state is AuthSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text("Đăng ký thành công!"),
                  backgroundColor: AppColors.success,
                  behavior: SnackBarBehavior.floating,
                  margin: EdgeInsets.all(16.w),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
                ),
              );
              Navigator.of(context).popUntil((route) => route.isFirst);
            }
            if (state is AuthVerifyOtpSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text("Xác thực OTP thành công!"),
                  backgroundColor: AppColors.success,
                  behavior: SnackBarBehavior.floating,
                  margin: EdgeInsets.all(16.w),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
                ),
              );
              _nextStep();
            }
          },
          builder: (context, state) {
            return Column(
              children: [
                Padding(
                  padding: EdgeInsets.only(left: 8.w, top: 8.h, right: 24.w),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.textPrimary),
                        onPressed: () => _prevStep(),
                      ),
                      Expanded(
                        child: _buildProgressIndicator(),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16.h),
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
    );
  }

  Widget _buildProgressIndicator() {
    return Row(
      children: List.generate(3, (index) {
        return Expanded(
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: 4.w),
            height: 4.h,
            decoration: BoxDecoration(
              color: index <= _currentStep ? AppColors.primaryBlue : AppColors.border,
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildInputLabel(String label) {
    return Text(
      label,
      style: AppTextStyles.bodyMedium.copyWith(
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
    );
  }

  // --- STEP 1: EMAIL ---
  Widget _buildStep1Email(BuildContext context, AuthState state) {
    return Form(
      key: _step1Key,
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 16.h),
            Text(
              "Tạo tài khoản\nmới 🚀",
              style: AppTextStyles.h1.copyWith(
                fontSize: 32.sp,
                color: AppColors.textPrimary,
                height: 1.2,
              ),
            ),
            SizedBox(height: 12.h),
            Text(
              "Vui lòng cung cấp địa chỉ email của bạn để bắt đầu quá trình đăng ký.",
              style: AppTextStyles.bodyLarge.copyWith(
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
            SizedBox(height: 48.h),

            _buildInputLabel("Địa chỉ Email"),
            SizedBox(height: 8.h),
            CustomTextField(
              controller: _emailController,
              hintText: "Nhập địa chỉ email",
              keyboardType: TextInputType.emailAddress,
              prefixIcon: Icons.email_outlined,
              validator: (v) {
                if (v == null || v.isEmpty) return "Vui lòng nhập email";
                final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                if (!emailRegex.hasMatch(v)) return "Email không hợp lệ";
                return null;
              },
            ),

            SizedBox(height: 40.h),
            CustomButton(
              text: "Tiếp tục",
              isLoading: state is AuthLoading,
              onPressed: () {
                if (_step1Key.currentState!.validate()) {
                  context.read<AuthBloc>().add(
                    AuthSendOtpStarted(email: _emailController.text.trim()),
                  );
                }
              },
            ),

            SizedBox(height: 32.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Bạn đã có tài khoản? ", style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
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
      ),
    );
  }

  // --- STEP 2: OTP ---
  Widget _buildStep2OTP(BuildContext context, AuthState state) {
    final defaultPinTheme = PinTheme(
      width: 56.w,
      height: 60.h,
      textStyle: AppTextStyles.h2.copyWith(color: AppColors.textPrimary),
      decoration: BoxDecoration(
        color: AppColors.inputBackground,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.transparent),
      ),
    );

    final focusedPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration!.copyWith(
        border: Border.all(color: AppColors.primaryBlue, width: 1.5),
      ),
    );

    final submittedPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration!.copyWith(
        color: AppColors.primaryBlue.withOpacity(0.05),
        border: Border.all(color: AppColors.primaryBlue, width: 1),
      ),
    );

    return Form(
      key: _step2Key,
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 16.h),
            Text(
              "Xác thực OTP 🔐",
              style: AppTextStyles.h1.copyWith(
                fontSize: 32.sp,
                color: AppColors.textPrimary,
                height: 1.2,
              ),
            ),
            SizedBox(height: 12.h),
            Text(
              "Chúng tôi đã gửi mã xác nhận 6 số đến email:\n${_emailController.text}",
              style: AppTextStyles.bodyLarge.copyWith(
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
            SizedBox(height: 48.h),

            Center(
              child: Pinput(
                length: 6,
                controller: _otpController,
                defaultPinTheme: defaultPinTheme,
                focusedPinTheme: focusedPinTheme,
                submittedPinTheme: submittedPinTheme,
                validator: (v) => (v?.length ?? 0) < 6 ? "Vui lòng nhập đủ 6 số" : null,
                pinputAutovalidateMode: PinputAutovalidateMode.onSubmit,
                showCursor: true,
              ),
            ),

            SizedBox(height: 48.h),
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
                          AuthSendOtpStarted(email: _emailController.text.trim()),
                        );
                      },
                child: Text(
                  "Không nhận được mã? Gửi lại",
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.primaryBlue,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- STEP 3: INFO ---
  Widget _buildStep3Info(BuildContext context, AuthState state) {
    return Form(
      key: _step3Key,
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 16.h),
            Text(
              "Hoàn tất\nhồ sơ ✨",
              style: AppTextStyles.h1.copyWith(
                fontSize: 32.sp,
                color: AppColors.textPrimary,
                height: 1.2,
              ),
            ),
            SizedBox(height: 12.h),
            Text(
              "Cung cấp thông tin cá nhân của bạn để hoàn tất đăng ký.",
              style: AppTextStyles.bodyLarge.copyWith(
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
            SizedBox(height: 32.h),

            _buildInputLabel("Họ và tên"),
            SizedBox(height: 8.h),
            CustomTextField(
              controller: _nameController,
              hintText: "Nhập họ và tên",
              prefixIcon: Icons.person_outline,
              validator: (v) => v == null || v.isEmpty ? "Vui lòng nhập họ tên" : null,
            ),
            SizedBox(height: 16.h),

            _buildInputLabel("Số điện thoại"),
            SizedBox(height: 8.h),
            CustomTextField(
              controller: _phoneController,
              hintText: "Nhập số điện thoại",
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

            _buildInputLabel("Mật khẩu"),
            SizedBox(height: 8.h),
            CustomTextField(
              controller: _passwordController,
              hintText: "Nhập mật khẩu",
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

            _buildInputLabel("Xác nhận mật khẩu"),
            SizedBox(height: 8.h),
            CustomTextField(
              controller: _confirmPassController,
              hintText: "Nhập lại mật khẩu",
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
              text: "Hoàn tất đăng ký",
              backgroundColor: AppColors.success,
              isLoading: state is AuthLoading,
              onPressed: () {
                if (_step3Key.currentState!.validate()) {
                  context.read<AuthBloc>().add(
                    AuthRegisterStarted(
                      email: _emailController.text.trim(),
                      password: _passwordController.text,
                      name: _nameController.text.trim(),
                      phoneNumber: _phoneController.text.trim(),
                      confirmPassword: _confirmPassController.text,
                      code: _otpController.text.trim(),
                    ),
                  );
                }
              },
            ),
            SizedBox(height: 32.h),
          ],
        ),
      ),
    );
  }
}
