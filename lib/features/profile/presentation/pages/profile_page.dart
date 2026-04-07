import 'package:app_fe_ecomerce/core/styles/app_colors.dart';
import 'package:app_fe_ecomerce/core/styles/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:app_fe_ecomerce/features/shop/presentation/pages/my_shop_page.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../../auth/presentation/bloc/auth/auth_bloc.dart';
import 'package:app_fe_ecomerce/features/order/presentation/pages/order_history_page.dart'
    as app_fe_ecomerce_order;
import 'package:app_fe_ecomerce/features/address/presentation/pages/address_list_page.dart';
import 'package:app_fe_ecomerce/features/discount/presentation/pages/voucher_wallet_page.dart';
import 'package:app_fe_ecomerce/features/discount/presentation/pages/seller_discount_list_page.dart';
import 'package:app_fe_ecomerce/features/profile/presentation/pages/edit_profile_page.dart';
import 'package:app_fe_ecomerce/features/shop/presentation/pages/register_shop_page.dart';
import 'package:app_fe_ecomerce/features/chat/presentation/pages/chat_detail_page.dart';

class ProfilePage extends StatelessWidget {
  final UserEntity user;

  const ProfilePage({super.key, required this.user});

  String _getRoleName(int? roleId) {
    switch (roleId) {
      case 1:
        return 'Admin';
      case 3:
        return 'Người bán';
      default:
        return 'Người mua';
    }
  }

  IconData _getRoleIcon(int? roleId) {
    switch (roleId) {
      case 1:
        return Icons.admin_panel_settings_rounded;
      case 3:
        return Icons.storefront_rounded;
      default:
        return Icons.shopping_bag_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthLogoutSuccess) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Đăng xuất thành công')));
        } else if (state is AuthSetup2FASuccess) {
          _show2FASetupDialog(context, state.data);
        } else if (state is AuthVerify2FASuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Bật xác thực 2 lớp thành công!')),
          );
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
        backgroundColor: const Color(0xFFF0F2F5),
        body: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // Header với gradient hiện đại
            SliverToBoxAdapter(child: _buildModernHeader(context)),
            // Các quick actions
            SliverToBoxAdapter(child: _buildQuickActions(context)),
            // Menu chính
            SliverToBoxAdapter(child: _buildMenuGroups(context)),
            // Nút đăng xuất
            SliverToBoxAdapter(child: _buildLogoutButton(context)),
            SliverToBoxAdapter(child: SizedBox(height: 32.h)),
          ],
        ),
      ),
    );
  }

  Widget _buildModernHeader(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF1565C0),
            Color(0xFF1E88E5),
            Color(0xFF42A5F5),
          ],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Top bar với settings
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EditProfilePage(user: user),
                        ),
                      );
                    },
                    icon: Icon(
                      Icons.settings_outlined,
                      color: Colors.white.withValues(alpha: 0.9),
                      size: 22.sp,
                    ),
                  ),
                ],
              ),
            ),
            // Profile info
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Column(
                children: [
                  // Avatar với viền gradient
                  Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.5),
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 20,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: CircleAvatar(
                      radius: 42.r,
                      backgroundColor: Colors.white,
                      child: CircleAvatar(
                        radius: 39.r,
                        backgroundColor: const Color(0xFFE3F2FD),
                        backgroundImage: user.avatar != null
                            ? CachedNetworkImageProvider(user.avatar!)
                            : null,
                        child: user.avatar == null
                            ? Icon(
                                Icons.person_rounded,
                                size: 42.sp,
                                color: const Color(0xFF90CAF9),
                              )
                            : null,
                      ),
                    ),
                  ),
                  SizedBox(height: 14.h),
                  // Tên user
                  Text(
                    user.name,
                    style: AppTextStyles.h2.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.3,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  // Email
                  Text(
                    user.email,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: Colors.white.withValues(alpha: 0.8),
                      letterSpacing: 0.2,
                    ),
                  ),
                  SizedBox(height: 10.h),
                  // Badge vai trò
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 14.w,
                      vertical: 5.h,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20.r),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _getRoleIcon(user.roleId),
                          color: Colors.white,
                          size: 14.sp,
                        ),
                        SizedBox(width: 6.w),
                        Text(
                          _getRoleName(user.roleId),
                          style: AppTextStyles.caption.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 11.sp,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 24.h),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Transform.translate(
      offset: Offset(0, -16.h),
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 16.w),
        padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 8.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildQuickActionItem(
              icon: Icons.receipt_long_rounded,
              label: 'Đơn hàng',
              color: const Color(0xFFFF6B35),
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
            _buildQuickActionItem(
              icon: Icons.local_activity_rounded,
              label: 'Voucher',
              color: const Color(0xFF7C4DFF),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const VoucherWalletPage(),
                  ),
                );
              },
            ),
            _buildQuickActionItem(
              icon: Icons.location_on_rounded,
              label: 'Địa chỉ',
              color: const Color(0xFF00BFA5),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AddressListPage(),
                  ),
                );
              },
            ),
            if (user.roleId == 3 || user.roleId == 1)
              _buildQuickActionItem(
                icon: Icons.storefront_rounded,
                label: 'Shop',
                color: const Color(0xFF2196F3),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const MyShopPage()),
                  );
                },
              )
            else
              _buildQuickActionItem(
                icon: Icons.store_rounded,
                label: 'Bán hàng',
                color: const Color(0xFF2196F3),
                onTap: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const RegisterShopPage()),
                  );
                  if (result == true && context.mounted) {
                    context.read<AuthBloc>().add(AuthCheckStatus());
                  }
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionItem({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 48.w,
            height: 48.w,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(14.r),
            ),
            child: Icon(icon, color: color, size: 24.sp),
          ),
          SizedBox(height: 8.h),
          Text(
            label,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w500,
              fontSize: 11.sp,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuGroups(BuildContext context) {
    return Column(
      children: [
        // Nhóm: Tài khoản & Bảo mật
        _buildMenuGroup(
          title: 'Tài khoản & Bảo mật',
          children: [
            _buildModernMenuItem(
              icon: Icons.person_outline_rounded,
              iconColor: const Color(0xFF1E88E5),
              iconBgColor: const Color(0xFFE3F2FD),
              title: 'Thiết lập tài khoản',
              subtitle: 'Thông tin cá nhân, mật khẩu',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditProfilePage(user: user),
                  ),
                );
              },
            ),
            _buildDivider(),
            _buildModernSwitchItem(
              icon: Icons.shield_outlined,
              iconColor: user.isTwoFactorEnabled
                  ? const Color(0xFF43A047)
                  : const Color(0xFFFF9800),
              iconBgColor: user.isTwoFactorEnabled
                  ? const Color(0xFFE8F5E9)
                  : const Color(0xFFFFF3E0),
              title: 'Xác thực 2 lớp',
              subtitle: user.isTwoFactorEnabled ? 'Đang bật' : 'Chưa kích hoạt',
              value: user.isTwoFactorEnabled,
              onChanged: (value) {
                if (value) {
                  context.read<AuthBloc>().add(AuthSetup2FAStarted(user: user));
                } else {
                  _showDisable2FADialog(context);
                }
              },
            ),
          ],
        ),

        // Nhóm: Mua sắm
        _buildMenuGroup(
          title: 'Mua sắm',
          children: [
            _buildModernMenuItem(
              icon: Icons.receipt_long_rounded,
              iconColor: const Color(0xFFFF6B35),
              iconBgColor: const Color(0xFFFFF3E0),
              title: 'Đơn hàng của tôi',
              subtitle: 'Theo dõi và quản lý đơn hàng',
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
            _buildDivider(),
            _buildModernMenuItem(
              icon: Icons.local_activity_rounded,
              iconColor: const Color(0xFF7C4DFF),
              iconBgColor: const Color(0xFFEDE7F6),
              title: 'Kho Voucher',
              subtitle: 'Mã giảm giá đã lưu',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const VoucherWalletPage(),
                  ),
                );
              },
            ),
            _buildDivider(),
            _buildModernMenuItem(
              icon: Icons.location_on_rounded,
              iconColor: const Color(0xFF00BFA5),
              iconBgColor: const Color(0xFFE0F2F1),
              title: 'Sổ địa chỉ',
              subtitle: 'Quản lý địa chỉ nhận hàng',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AddressListPage(),
                  ),
                );
              },
            ),
          ],
        ),

        // Nhóm: Shop (nếu là seller/admin)
        if (user.roleId == 3 || user.roleId == 1)
          _buildMenuGroup(
            title: 'Kênh bán hàng',
            children: [
              _buildModernMenuItem(
                icon: Icons.storefront_rounded,
                iconColor: const Color(0xFF1E88E5),
                iconBgColor: const Color(0xFFE3F2FD),
                title: 'Shop của tôi',
                subtitle: 'Quản lý sản phẩm, đơn hàng',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const MyShopPage()),
                  );
                },
              ),
              if (user.roleId == 1) ...[
                _buildDivider(),
                _buildModernMenuItem(
                  icon: Icons.public_rounded,
                  iconColor: const Color(0xFFE53935),
                  iconBgColor: const Color(0xFFFFEBEE),
                  title: 'Quản lý Voucher Sàn',
                  subtitle: 'Quản trị mã giảm giá toàn hệ thống',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SellerDiscountListPage(
                          isAdmin: true,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ],
          )
        else
          _buildMenuGroup(
            title: 'Kênh bán hàng',
            children: [
              _buildModernMenuItem(
                icon: Icons.store_rounded,
                iconColor: const Color(0xFF1E88E5),
                iconBgColor: const Color(0xFFE3F2FD),
                title: 'Bắt đầu bán hàng',
                subtitle: 'Mở shop và bắt đầu kinh doanh',
                onTap: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const RegisterShopPage()),
                  );
                  if (result == true && context.mounted) {
                    context.read<AuthBloc>().add(AuthCheckStatus());
                  }
                },
              ),
            ],
          ),

        // Nhóm: Hỗ trợ
        _buildMenuGroup(
          title: 'Hỗ trợ',
          children: [
            _buildModernMenuItem(
              icon: Icons.help_outline_rounded,
              iconColor: const Color(0xFF78909C),
              iconBgColor: const Color(0xFFECEFF1),
              title: 'Trung tâm trợ giúp',
              subtitle: 'Hỏi đáp và hướng dẫn sử dụng',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ChatDetailPage(
                      conversationId: 0,
                      otherUserName: 'Trung tâm trợ giúp',
                      otherUserAvatar: null,
                      receiverId: 1, // ID của Admin
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMenuGroup({
    required String title,
    required List<Widget> children,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(left: 4.w, bottom: 8.h, top: 4.h),
            child: Text(
              title,
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
                fontSize: 12.sp,
                letterSpacing: 0.5,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(children: children),
          ),
          SizedBox(height: 16.h),
        ],
      ),
    );
  }

  Widget _buildModernMenuItem({
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required String title,
    String? subtitle,
    VoidCallback? onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14.r),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
          child: Row(
            children: [
              Container(
                width: 40.w,
                height: 40.w,
                decoration: BoxDecoration(
                  color: iconBgColor,
                  borderRadius: BorderRadius.circular(11.r),
                ),
                child: Icon(icon, color: iconColor, size: 20.sp),
              ),
              SizedBox(width: 14.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w500,
                        fontSize: 14.sp,
                      ),
                    ),
                    if (subtitle != null) ...[
                      SizedBox(height: 2.h),
                      Text(
                        subtitle,
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textSecondary,
                          fontSize: 11.sp,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                size: 20.sp,
                color: AppColors.textSecondary.withValues(alpha: 0.5),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModernSwitchItem({
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required String title,
    String? subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
      child: Row(
        children: [
          Container(
            width: 40.w,
            height: 40.w,
            decoration: BoxDecoration(
              color: iconBgColor,
              borderRadius: BorderRadius.circular(11.r),
            ),
            child: Icon(icon, color: iconColor, size: 20.sp),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w500,
                    fontSize: 14.sp,
                  ),
                ),
                if (subtitle != null) ...[
                  SizedBox(height: 2.h),
                  Text(
                    subtitle,
                    style: AppTextStyles.caption.copyWith(
                      color: value
                          ? const Color(0xFF43A047)
                          : AppColors.textSecondary,
                      fontSize: 11.sp,
                      fontWeight: value ? FontWeight.w500 : FontWeight.normal,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Transform.scale(
            scale: 0.8,
            child: Switch.adaptive(
              value: value,
              onChanged: onChanged,
              activeColor: const Color(0xFF43A047),
              activeTrackColor: const Color(0xFFA5D6A7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Divider(height: 1, color: Colors.grey.withValues(alpha: 0.12)),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showLogoutDialog(context),
          borderRadius: BorderRadius.circular(14.r),
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 14.h),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.logout_rounded,
                  color: const Color(0xFFE53935),
                  size: 20.sp,
                ),
                SizedBox(width: 8.w),
                Text(
                  'Đăng xuất',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: const Color(0xFFE53935),
                    fontWeight: FontWeight.w600,
                    fontSize: 14.sp,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        title: Row(
          children: [
            Icon(Icons.logout_rounded, color: const Color(0xFFE53935), size: 24.sp),
            SizedBox(width: 10.w),
            const Text('Đăng xuất'),
          ],
        ),
        content: const Text('Bạn có chắc chắn muốn đăng xuất?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(
              'Hủy',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<AuthBloc>().add(AuthLogoutRequested());
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE53935),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
            child: const Text('Đăng xuất'),
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
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        title: Row(
          children: [
            Icon(Icons.shield_outlined, color: const Color(0xFFFF9800), size: 24.sp),
            SizedBox(width: 10.w),
            const Text('Tắt xác thực 2 lớp'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Nhập mã TOTP từ ứng dụng hoặc OTP từ email:'),
            SizedBox(height: 16.h),
            TextField(
              controller: totpController,
              decoration: InputDecoration(
                labelText: 'Mã TOTP (từ ứng dụng)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.r),
                ),
                prefixIcon: const Icon(Icons.lock_clock),
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 12.h),
            Row(
              children: [
                Expanded(child: Divider(color: Colors.grey[300])),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12.w),
                  child: Text(
                    'HOẶC',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
                Expanded(child: Divider(color: Colors.grey[300])),
              ],
            ),
            SizedBox(height: 12.h),
            TextField(
              controller: otpController,
              decoration: InputDecoration(
                labelText: 'OTP (từ email)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.r),
                ),
                prefixIcon: const Icon(Icons.email_outlined),
              ),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(
              'Hủy',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          ElevatedButton(
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
                  user: user,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF9800),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
            child: const Text('Tắt'),
          ),
        ],
      ),
    );
  }

  void _show2FASetupDialog(BuildContext context, Map<String, dynamic> data) {
    final String? qrData = data['url'] ?? data['qrCode'];
    final String? secret = data['secret'];
    final totpController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        title: Row(
          children: [
            Icon(Icons.security_rounded, color: const Color(0xFF1E88E5), size: 24.sp),
            SizedBox(width: 10.w),
            const Text('Thiết lập 2FA'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Quét mã QR bằng ứng dụng xác thực\n(Google Authenticator, Authy...):',
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16.h),
              if (qrData != null)
                Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12.r),
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
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: const Center(child: Text('Không có dữ liệu QR')),
                ),
              SizedBox(height: 16.h),
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
                    borderRadius: BorderRadius.circular(8.r),
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
                decoration: InputDecoration(
                  labelText: 'Mã TOTP (6 chữ số)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  prefixIcon: const Icon(Icons.pin),
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
            child: Text(
              'Hủy',
              style: TextStyle(color: AppColors.textSecondary),
            ),
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
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1E88E5),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
            child: const Text('Xác nhận'),
          ),
        ],
      ),
    );
  }
}
