import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:app_fe_ecomerce/features/shop/presentation/pages/my_shop_page.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../../auth/presentation/bloc/auth/auth_bloc.dart';
import 'package:app_fe_ecomerce/features/order/presentation/pages/order_history_page.dart'
    as app_fe_ecomerce_order;
import 'package:app_fe_ecomerce/features/address/presentation/pages/address_list_page.dart';
import 'package:app_fe_ecomerce/features/discount/presentation/pages/voucher_wallet_page.dart';

class ProfilePage extends StatelessWidget {
  final UserEntity user;

  const ProfilePage({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthLogoutSuccess) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Đăng xuất thành công')));
          // Navigator logic removed to keep user on HomePage (Guest mode) or let HomePage handle it.
        } else if (state is AuthSetup2FASuccess) {
          _show2FASetupDialog(context, state.data);
        } else if (state is AuthVerify2FASuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Bật xác thực 2 lớp thành công!')),
          );
          // Reload user profile
          context.read<AuthBloc>().add(AuthCheckStatus());
        } else if (state is AuthDisable2FASuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Đã tắt xác thực 2 lớp thành công')),
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
            "Thiết lập tài khoản",
            onTap: () {},
          ),
          const Divider(height: 1),
          _buildMenuItem(
            Icons.location_on_outlined,
            "Sổ địa chỉ",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AddressListPage(),
                ),
              );
            },
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
            title: Text("Xác thực 2 lớp", style: TextStyle(fontSize: 14.sp)),
            value: user.isTwoFactorEnabled,
            onChanged: (value) {
              if (value) {
                // Turning ON
                context.read<AuthBloc>().add(AuthSetup2FAStarted(user: user));
              } else {
                // Turning OFF
                _showDisable2FADialog(context);
              }
            },
            activeThumbColor: const Color(0xFF1A94FF),
          ),
          const Divider(height: 1),
          // --- Seller Section Logic ---
          if (user.roleId == 3 || user.roleId == 2 || user.roleId == 1) ...[
            _buildMenuItem(
              Icons.storefront_outlined,
              "Shop của tôi",
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
              "Bắt đầu bán hàng",
              onTap: () {
                // Navigate to Shop Registration
                // TODO: Implement Shop Registration Page
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Chuyển đến trang đăng ký shop"),
                  ),
                );
              },
              textColor: Colors.blue,
            ),
            const Divider(height: 1),
          ],
          // --- Order History ---
          _buildMenuItem(
            Icons.receipt_long_outlined,
            "Đơn hàng của tôi",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      const app_fe_ecomerce_order.OrderHistoryPage(),
                ),
              );
            },
          ),
          const Divider(height: 1),
          // --- Kho Voucher ---
          _buildMenuItem(
            Icons.local_activity_outlined,
            "Kho Voucher",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const VoucherWalletPage(),
                ),
              );
            },
          ),
          const Divider(height: 1),
          // ----------------------------
          _buildMenuItem(
            Icons.help_outline,
            "Trung tâm trợ giúp",
            onTap: () {},
          ),
          const Divider(height: 1),
          _buildMenuItem(
            Icons.logout,
            "Đăng xuất",
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
        title: const Text('Đăng xuất'),
        content: const Text('Bạn có chắc chắn muốn đăng xuất?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<AuthBloc>().add(AuthLogoutRequested());
            },
            child: const Text('Đăng xuất', style: TextStyle(color: Colors.red)),
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
        title: const Text('Tắt xác thực 2 lớp'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Nhập mã TOTP từ ứng dụng hoặc OTP từ email:'),
            SizedBox(height: 16.h),
            TextField(
              controller: totpController,
              decoration: const InputDecoration(
                labelText: 'Mã TOTP (từ ứng dụng)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 12.h),
            const Text('HOẶC'),
            SizedBox(height: 12.h),
            TextField(
              controller: otpController,
              decoration: const InputDecoration(
                labelText: 'OTP (từ email)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () {
              final totpCode = totpController.text.trim();
              final code = otpController.text.trim();

              if (totpCode.isEmpty && code.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Vui lòng cung cấp mã TOTP hoặc mã OTP'),
                  ),
                );
                return;
              }

              Navigator.pop(dialogContext);
              context.read<AuthBloc>().add(
                AuthDisable2FAStarted(
                  code: code.isNotEmpty ? code : null,
                  user:
                      user, // Accessing accessing 'user' field of ProfilePage? No, ProfilePage is StatelessWidget or Stateful? 'user' variable is from class ProfilePage.
                  // Wait, helper methods like _showDisable2FADialog are inside the class instance?
                  // Yes. `UserEntity user` is a field of ProfilePage.
                ),
              );
            },
            child: const Text('Tắt'),
          ),
        ],
      ),
    );
  }

  void _show2FASetupDialog(BuildContext context, Map<String, dynamic> data) {
    // Lấy URL để tạo QR code (ưu tiên url > qrCode > secret)
    final String? qrData = data['url'] ?? data['qrCode'];
    final String? secret = data['secret'];
    final totpController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Thiết lập 2FA'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Quét mã QR bằng ứng dụng xác thực\n(Google Authenticator, Authy...):',
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16.h),
              // Hiển thị mã QR thực
              if (qrData != null)
                Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8.r),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: SizedBox(
                    width: 200.w,
                    height: 200.w,
                    child: QrImageView(
                      data: qrData,
                      version: QrVersions.auto,
                      size: 200.w,
                      backgroundColor: Colors.white,
                      errorStateBuilder: (ctx, err) => Center(
                        child: Text(
                          'Không thể tạo mã QR',
                          style: TextStyle(fontSize: 12.sp, color: Colors.red),
                        ),
                      ),
                    ),
                  ),
                )
              else
                Container(
                  width: 200.w,
                  height: 200.w,
                  color: Colors.grey[200],
                  child: const Center(
                    child: Text('Không có dữ liệu QR'),
                  ),
                ),
              SizedBox(height: 16.h),
              // Hiển thị secret key có thể copy
              if (secret != null) ...[
                const Text(
                  'Hoặc nhập mã thủ công:',
                  style: TextStyle(fontSize: 12),
                ),
                SizedBox(height: 8.h),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 8.h,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(4.r),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: SelectableText(
                          secret,
                          style: TextStyle(
                            fontSize: 13.sp,
                            fontFamily: 'monospace',
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.copy, size: 18.sp),
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: secret));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Đã sao chép mã secret'),
                              duration: Duration(seconds: 1),
                            ),
                          );
                        },
                        tooltip: 'Sao chép',
                      ),
                    ],
                  ),
                ),
              ],
              SizedBox(height: 16.h),
              const Text(
                'Nhập mã 6 chữ số từ ứng dụng xác thực để xác nhận:',
                style: TextStyle(fontSize: 12),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8.h),
              TextField(
                controller: totpController,
                decoration: const InputDecoration(
                  labelText: 'Mã TOTP (6 chữ số)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                maxLength: 6,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              final totpCode = totpController.text.trim();
              if (totpCode.isEmpty || totpCode.length != 6) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Vui lòng nhập đúng 6 chữ số mã TOTP'),
                  ),
                );
                return;
              }
              Navigator.pop(dialogContext);
              context.read<AuthBloc>().add(
                AuthVerify2FAStarted(totpCode: totpCode),
              );
            },
            child: const Text('Xác nhận'),
          ),
        ],
      ),
    );
  }
}
