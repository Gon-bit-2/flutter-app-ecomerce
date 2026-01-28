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
    return BlocProvider(
      create: (context) => getIt<AuthBloc>(),
      child: Scaffold(
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
                      content: Text("Verification code sent!"),
                      backgroundColor: AppColors.success,
                    ),
                  );
                  if (_currentStep == 0) _nextStep();
                }
                if (state is AuthSuccess) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Registration Successful! Please Login."),
                      backgroundColor: AppColors.success,
                    ),
                  );
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => const LoginPage()),
                  );
                }
                if (state is AuthVerifyOtpSuccess) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("OTP Verified!"),
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
          Text("Register", style: AppTextStyles.h1),
          SizedBox(height: 8.h),
          Text(
            "Step 1 of 3: Enter your email to get started",
            style: AppTextStyles.bodyMedium,
          ),
          SizedBox(height: 40.h),

          Text(
            "Email Address",
            style: AppTextStyles.bodyLarge.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 8.h),
          CustomTextField(
            controller: _emailController,
            hintText: "example@email.com",
            suffixIcon: const Icon(
              Icons.email_outlined,
              color: AppColors.textSecondary,
            ),
            validator: (v) {
              if (v == null || v.isEmpty) return "Required";
              if (!v.contains('@')) return "Invalid email";
              return null;
            },
          ),

          SizedBox(height: 40.h),
          CustomButton(
            text: "Next",
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
              Text(
                "Already have an account? ",
                style: AppTextStyles.bodyMedium,
              ),
              GestureDetector(
                onTap: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => const LoginPage()),
                  );
                },
                child: Text(
                  "Login",
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
          Center(child: Text("Verification", style: AppTextStyles.h3)),
          SizedBox(height: 40.h),

          Center(child: Text("Enter OTP Code", style: AppTextStyles.h1)),
          SizedBox(height: 16.h),
          Text(
            "Enter the 6-digit code sent to your email:\n${_emailController.text}",
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
              validator: (v) => (v?.length ?? 0) < 6 ? "Enter 6 digits" : null,
              pinputAutovalidateMode: PinputAutovalidateMode.onSubmit,
              showCursor: true,
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
                "Didn't receive code? Resend",
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
            Text("Complete Profile", style: AppTextStyles.h1),
            SizedBox(height: 8.h),
            Text(
              "Step 3 of 3: Fill in your details",
              style: AppTextStyles.bodyMedium,
            ),
            SizedBox(height: 30.h),

            CustomTextField(
              controller: _nameController,
              hintText: "Full Name",
              prefixIcon: Icons.person_outline,
              validator: (v) => v!.isEmpty ? "Required" : null,
            ),
            SizedBox(height: 16.h),

            CustomTextField(
              controller: _phoneController,
              hintText: "Phone Number",
              prefixIcon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
              validator: (v) => v!.isEmpty ? "Required" : null,
            ),
            SizedBox(height: 16.h),

            CustomTextField(
              controller: _passwordController,
              hintText: "Password",
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
              controller: _confirmPassController,
              hintText: "Confirm Password",
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
                if (v != _passwordController.text)
                  return "Passwords do not match";
                return null;
              },
            ),

            SizedBox(height: 40.h),

            CustomButton(
              text: "Sign Up",
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
