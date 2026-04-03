import 'package:app_fe_ecomerce/core/common/widgets/custom_button.dart';
import 'package:app_fe_ecomerce/core/common/widgets/custom_text_field.dart';
import 'package:app_fe_ecomerce/core/styles/app_colors.dart';
import 'package:app_fe_ecomerce/core/styles/app_text_styles.dart';
import 'package:app_fe_ecomerce/features/auth/presentation/bloc/auth/auth_bloc.dart';
import 'package:app_fe_ecomerce/features/auth/presentation/pages/forgot_password_page.dart';
import 'package:app_fe_ecomerce/features/auth/presentation/pages/register_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:app_fe_ecomerce/features/auth/presentation/pages/google_login_webview.dart' as app_webview;

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const LoginView();
  }
}

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isPasswordVisible = false;
  bool _autoValidate = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthLoginRequiresTwoFactor) {
            _showOtpDialog(context, state.email, state.password);
          }
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
          if (state is AuthSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text("Đăng nhập thành công!"),
                backgroundColor: AppColors.success,
                behavior: SnackBarBehavior.floating,
                margin: EdgeInsets.all(16.w),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
              ),
            );
            Navigator.of(context).popUntil((route) => route.isFirst);
          }
          if (state is AuthGoogleUrlSuccess) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => app_webview.GoogleLoginWebView(url: state.url),
              ),
            );
          }
        },
        builder: (context, state) {
          return SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
              child: Form(
                key: _formKey,
                autovalidateMode: _autoValidate
                    ? AutovalidateMode.onUserInteraction
                    : AutovalidateMode.disabled,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.textPrimary),
                      padding: EdgeInsets.zero,
                      alignment: Alignment.centerLeft,
                      onPressed: () => Navigator.pop(context),
                    ),
                    SizedBox(height: 32.h),
                    
                    Text(
                      "Chào mừng\ntrở lại 👋",
                      style: AppTextStyles.h1.copyWith(
                        fontSize: 32.sp,
                        color: AppColors.textPrimary,
                        height: 1.2,
                      ),
                    ),
                    SizedBox(height: 12.h),
                    Text(
                      "Vui lòng đăng nhập để tiếp tục và trải nghiệm mua sắm tuyệt vời cùng chúng tôi.",
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: AppColors.textSecondary,
                        height: 1.5,
                      ),
                    ),
                    SizedBox(height: 48.h),

                    // Email Input
                    _buildInputLabel("Email của bạn"),
                    SizedBox(height: 8.h),
                    CustomTextField(
                      controller: _emailController,
                      hintText: "Nhập địa chỉ email",
                      prefixIcon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      validator: (val) {
                        if (val == null || val.isEmpty) return "Vui lòng nhập email";
                        final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                        if (!emailRegex.hasMatch(val)) return "Email không hợp lệ";
                        return null;
                      },
                    ),
                    SizedBox(height: 20.h),

                    // Password Input
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
                        onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                      ),
                      validator: (val) {
                        if (val == null || val.isEmpty) return "Vui lòng nhập mật khẩu";
                        if (val.length < 6) return "Mật khẩu có ít nhất 6 ký tự";
                        return null;
                      },
                    ),
                    SizedBox(height: 8.h),

                    // Forgot Password
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const ForgotPasswordPage()),
                          );
                        },
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 8.w),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          "Quên mật khẩu?",
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.primaryBlue,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 24.h),

                    // Login Button
                    CustomButton(
                      text: "Đăng nhập",
                      isLoading: state is AuthLoading,
                      onPressed: () {
                        setState(() => _autoValidate = true);
                        if (_formKey.currentState!.validate()) {
                          FocusScope.of(context).unfocus();
                          context.read<AuthBloc>().add(
                            AuthLoginStarted(
                              email: _emailController.text.trim(),
                              password: _passwordController.text,
                            ),
                          );
                        }
                      },
                    ),

                    SizedBox(height: 40.h),
                    _buildDivider(),
                    SizedBox(height: 24.h),

                    // Social Buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildSocialOption(
                          icon: FontAwesomeIcons.google,
                          color: Colors.red,
                          text: "Google",
                          onPressed: () {
                            context.read<AuthBloc>().add(AuthGoogleUrlRequested());
                          },
                        ),
                      ],
                    ),

                    SizedBox(height: 40.h),
                    
                    // Register Link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Bạn chưa có tài khoản? ",
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const RegisterPage()),
                          ),
                          child: Text(
                            "Đăng ký ngay",
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
            ),
          );
        },
      ),
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

  Widget _buildDivider() {
    return Row(
      children: [
        const Expanded(child: Divider(color: AppColors.border, thickness: 1)),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Text(
            "Hoặc đăng nhập với",
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const Expanded(child: Divider(color: AppColors.border, thickness: 1)),
      ],
    );
  }

  Widget _buildSocialOption({
    required IconData icon,
    required Color color,
    required String text,
    required VoidCallback onPressed,
  }) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 40.w, vertical: 14.h),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 24.sp),
            SizedBox(width: 12.w),
            Text(
              text,
              style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.w600, color: AppColors.textPrimary),
            ),
          ],
        ),
      ),
    );
  }

  void _showOtpDialog(BuildContext context, String email, String password) {
    final otpController = TextEditingController();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        title: Text("Xác thực 2FA", style: AppTextStyles.h3),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Vui lòng nhập mã OTP (Authenticator/Email) để hoàn tất đăng nhập.",
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
            ),
            SizedBox(height: 20.h),
            TextField(
              controller: otpController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: "Nhập mã 6 số",
                hintStyle: AppTextStyles.inputHint,
                filled: true,
                fillColor: AppColors.inputBackground,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.r),
                  borderSide: BorderSide.none,
                ),
              ),
              maxLength: 6,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text("Hủy", style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBlue,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              context.read<AuthBloc>().add(
                AuthLoginStarted(
                  email: email,
                  password: password,
                  totpCode: otpController.text,
                ),
              );
            },
            child: const Text("Xác nhận", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
