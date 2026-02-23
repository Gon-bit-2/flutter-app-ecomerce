import 'dart:async';

import 'package:app_fe_ecomerce/core/common/widgets/custom_button.dart';
import 'package:app_fe_ecomerce/core/common/widgets/custom_text_field.dart';
import 'package:app_fe_ecomerce/core/common/widgets/social_button.dart';
import 'package:app_fe_ecomerce/core/services/deep_link_service.dart';
import 'package:app_fe_ecomerce/core/styles/app_colors.dart';
import 'package:app_fe_ecomerce/core/styles/app_text_styles.dart';
import 'package:app_fe_ecomerce/features/auth/presentation/bloc/auth/auth_bloc.dart';
import 'package:app_fe_ecomerce/features/auth/presentation/pages/forgot_password_page.dart';
import 'package:app_fe_ecomerce/features/auth/presentation/pages/register_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../injection_container.dart';

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
  StreamSubscription? _sub;

  @override
  void initState() {
    super.initState();
    // Setup Deep Link Listener
    final deepLinkService = getIt<DeepLinkService>();
    deepLinkService.init();
    _sub = deepLinkService.deepLinkStream.listen((uri) {
      if (!mounted) return;
      // print("DeepLink Received: $uri");
      final accessToken = uri.queryParameters['accessToken'];
      final refreshToken = uri.queryParameters['refreshToken'];
      if (accessToken != null && refreshToken != null) {
        context.read<AuthBloc>().add(
          AuthSocialLoginTokenReceived(
            accessToken: accessToken,
            refreshToken: refreshToken,
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          "Đăng nhập",
          style: AppTextStyles.h3.copyWith(color: AppColors.primaryBlue),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline, color: AppColors.primaryBlue),
            onPressed: () {},
          ),
        ],
      ),
      body: SafeArea(
        child: BlocConsumer<AuthBloc, AuthState>(
          listener: (context, state) async {
            if (state is AuthLoginRequiresTwoFactor) {
              _showOtpDialog(context, state.email, state.password);
            }
            if (state is AuthFailure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: AppColors.error,
                ),
              );
            }
            if (state is AuthSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Đăng nhập thành công!"),
                  backgroundColor: AppColors.success,
                ),
              );
              Navigator.pop(context);
            }
            if (state is AuthGoogleUrlSuccess) {
              final uri = Uri.parse(state.url);
              try {
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                } else {
                  await launchUrl(uri);
                }
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Không thể mở đăng nhập Google: $e")),
                );
              }
            }
          },
          builder: (context, state) {
            return SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    SizedBox(height: 40.h),
                    // Logo Placeholder
                    Container(
                      width: 80.w,
                      height: 80.w,
                      decoration: BoxDecoration(
                        color: AppColors.primaryBlue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: Icon(
                        Icons.shopping_bag,
                        size: 40.sp,
                        color: AppColors.primaryBlue,
                      ),
                    ),
                    SizedBox(height: 24.h),
                    Text("Chào mừng", style: AppTextStyles.h2),
                    SizedBox(height: 8.h),
                    Text(
                      "Vui lòng nhập thông tin để tiếp tục",
                      style: AppTextStyles.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 40.h),

                    // User/Email Input
                    CustomTextField(
                      controller: _emailController,
                      hintText: "Email",
                      prefixIcon: Icons.person_outline,
                      validator: (val) => val!.isEmpty ? "Bắt buộc" : null,
                    ),
                    SizedBox(height: 16.h),

                    // Password Input
                    CustomTextField(
                      controller: _passwordController,
                      hintText: "Mật khẩu",
                      prefixIcon: Icons.lock_outline,
                      obscureText: !_isPasswordVisible,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isPasswordVisible
                              ? Icons.visibility
                              : Icons.visibility_off,
                          color: AppColors.textSecondary,
                        ),
                        onPressed: () => setState(
                          () => _isPasswordVisible = !_isPasswordVisible,
                        ),
                      ),
                      validator: (val) =>
                          val!.length < 6 ? "Tối thiểu 6 ký tự" : null,
                    ),
                    SizedBox(height: 24.h),

                    // Login Button
                    CustomButton(
                      text: "Đăng nhập",
                      isLoading: state is AuthLoading,
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          context.read<AuthBloc>().add(
                            AuthLoginStarted(
                              email: _emailController.text,
                              password: _passwordController.text,
                            ),
                          );
                        }
                      },
                    ),

                    SizedBox(height: 16.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const ForgotPasswordPage(),
                              ),
                            );
                          },
                          child: Text(
                            "Quên mật khẩu?",
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 24.h),
                    Row(
                      children: [
                        const Expanded(child: Divider(color: AppColors.border)),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16.w),
                          child: Text(
                            "HOẶC",
                            style: AppTextStyles.bodyMedium.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const Expanded(child: Divider(color: AppColors.border)),
                      ],
                    ),
                    SizedBox(height: 24.h),

                    // Social Buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SocialButton(
                          icon: FontAwesomeIcons.google,
                          iconColor: Colors.red,
                          onPressed: () {
                            context.read<AuthBloc>().add(
                              AuthGoogleUrlRequested(),
                            );
                          },
                        ),
                      ],
                    ),

                    SizedBox(height: 40.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Chưa có tài khoản? ",
                          style: AppTextStyles.bodyMedium,
                        ),
                        GestureDetector(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const RegisterPage(),
                            ),
                          ),
                          child: Text(
                            "Đăng ký",
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
          },
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
        title: const Text("Xác thực 2FA"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Vui lòng nhập mã OTP (Authenticator/Email)."),
            const SizedBox(height: 10),
            TextField(
              controller: otpController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                hintText: "Nhập mã 6 số",
                border: OutlineInputBorder(),
              ),
              maxLength: 6,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Hủy"),
          ),
          ElevatedButton(
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
            child: const Text("Xác nhận"),
          ),
        ],
      ),
    );
  }
}
