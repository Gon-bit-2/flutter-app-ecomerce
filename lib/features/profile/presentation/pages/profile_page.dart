import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:app_fe_ecomerce/features/shop/presentation/pages/my_shop_page.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../../auth/presentation/bloc/auth/auth_bloc.dart';

class ProfilePage extends StatelessWidget {
  final UserEntity user;

  const ProfilePage({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthLogoutSuccess) {
          Navigator.of(
            context,
          ).pushNamedAndRemoveUntil('/login', (route) => false);
        } else if (state is AuthSetup2FASuccess) {
          _show2FASetupDialog(context, state.data);
        } else if (state is AuthDisable2FASuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('2FA has been disabled successfully')),
          );
        } else if (state is AuthFailure) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));
        }
      },
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        body: SingleChildScrollView(
          child: Column(
            children: [
              _buildHeader(context),
              _buildMenuSection(context),
              SizedBox(height: 20.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      color: const Color(0xFF1A94FF),
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 20.h,
        bottom: 30.h,
        left: 20.w,
        right: 20.w,
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 35.r,
            backgroundImage: user.avatar != null
                ? NetworkImage(user.avatar!)
                : null,
            backgroundColor: Colors.white,
            child: user.avatar == null
                ? Icon(Icons.person, size: 40.sp, color: Colors.grey)
                : null,
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.name,
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  user.email,
                  style: TextStyle(color: Colors.white70, fontSize: 12.sp),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuSection(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 10.h, left: 16.w, right: 16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Column(
        children: [
          _buildMenuItem(
            Icons.person_outline,
            "Account Settings",
            onTap: () {},
          ),
          const Divider(height: 1),
          SwitchListTile(
            secondary: Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.security_outlined,
                color: Colors.blue,
                size: 20.sp,
              ),
            ),
            title: Text(
              "Two-Factor Authentication",
              style: TextStyle(fontSize: 14.sp),
            ),
            value: user.totpSecret != null,
            onChanged: (value) {
              if (value) {
                // Turning ON
                context.read<AuthBloc>().add(AuthSetup2FAStarted());
              } else {
                // Turning OFF
                _showDisable2FADialog(context);
              }
            },
            activeColor: const Color(0xFF1A94FF),
          ),
          const Divider(height: 1),
          // --- Seller Section Logic ---
          if (user.roleId == 3) ...[
            _buildMenuItem(
              Icons.storefront_outlined,
              "My Shop",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const MyShopPage()),
                );
              },
            ),
            const Divider(height: 1),
          ] else ...[
            _buildMenuItem(
              Icons.store_outlined,
              "Start Selling",
              onTap: () {
                // Navigate to Shop Registration
                // TODO: Implement Shop Registration Page
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Navigate to Shop Registration"),
                  ),
                );
              },
              textColor: Colors.blue,
            ),
            const Divider(height: 1),
          ],
          // ----------------------------
          _buildMenuItem(Icons.help_outline, "Help Centre", onTap: () {}),
          const Divider(height: 1),
          _buildMenuItem(
            Icons.logout,
            "Logout",
            onTap: () {
              _showLogoutDialog(context);
            },
            textColor: Colors.red,
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(
    IconData icon,
    String title, {
    VoidCallback? onTap,
    Color? textColor,
  }) {
    return ListTile(
      leading: Container(
        padding: EdgeInsets.all(8.w),
        decoration: BoxDecoration(
          color: Colors.blue.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.blue, size: 20.sp),
      ),
      title: Text(
        title,
        style: TextStyle(fontSize: 14.sp, color: textColor),
      ),
      trailing: Icon(Icons.chevron_right, size: 20.sp, color: Colors.grey),
      onTap: onTap,
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<AuthBloc>().add(AuthLogoutRequested());
            },
            child: const Text('Logout', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showDisable2FADialog(BuildContext context) {
    final totpController = TextEditingController();
    final otpController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Disable 2FA'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Enter TOTP code from your authenticator app OR OTP from email:',
            ),
            SizedBox(height: 16.h),
            TextField(
              controller: totpController,
              decoration: const InputDecoration(
                labelText: 'TOTP Code (from app)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 12.h),
            const Text('OR'),
            SizedBox(height: 12.h),
            TextField(
              controller: otpController,
              decoration: const InputDecoration(
                labelText: 'OTP (from email)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final totpCode = totpController.text.trim();
              final code = otpController.text.trim();

              if (totpCode.isEmpty && code.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please provide either TOTP code or OTP'),
                  ),
                );
                return;
              }

              Navigator.pop(dialogContext);
              context.read<AuthBloc>().add(
                AuthDisable2FAStarted(
                  totpCode: totpCode.isNotEmpty ? totpCode : null,
                  code: code.isNotEmpty ? code : null,
                ),
              );
            },
            child: const Text('Disable'),
          ),
        ],
      ),
    );
  }

  void _show2FASetupDialog(BuildContext context, Map<String, dynamic> data) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Setup 2FA'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Scan this QR code with your authenticator app:',
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16.h),
              // Display QR code or secret based on API response
              if (data['qrCode'] != null) Text('QR Code: ${data['qrCode']}'),
              if (data['secret'] != null)
                SelectableText('Secret: ${data['secret']}'),
              if (data['url'] != null) SelectableText('URL: ${data['url']}'),
              SizedBox(height: 16.h),
              const Text(
                'After scanning, use your authenticator app to generate codes for login.',
                style: TextStyle(fontSize: 12),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
