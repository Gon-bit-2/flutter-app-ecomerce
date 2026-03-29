import 'package:app_fe_ecomerce/core/styles/app_colors.dart';
import 'package:app_fe_ecomerce/features/category/presentation/pages/category_page.dart';
import 'package:app_fe_ecomerce/features/order/presentation/pages/seller_orders_page.dart';
import 'package:app_fe_ecomerce/features/product/presentation/pages/add_product_page.dart';
import 'package:app_fe_ecomerce/features/product/presentation/pages/my_products_page.dart';
import 'package:app_fe_ecomerce/features/discount/presentation/pages/seller_discount_list_page.dart';
import 'package:app_fe_ecomerce/features/shop/presentation/pages/shop_settings_page.dart';
import 'package:app_fe_ecomerce/features/auth/domain/entities/user_entity.dart';
import 'package:app_fe_ecomerce/features/auth/presentation/bloc/auth/auth_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MyShopPage extends StatefulWidget {
  const MyShopPage({super.key});

  @override
  State<MyShopPage> createState() => _MyShopPageState();
}

class _MyShopPageState extends State<MyShopPage> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        UserEntity? user;

        // Extract user from current auth state
        if (state is AuthSuccess) {
          user = state.user;
        } else if (state is AuthLoading) {
          user = state.user;
        }

        if (user == null) {
          return Scaffold(
            appBar: AppBar(
              title: const Text("Shop của tôi"),
              centerTitle: true,
            ),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.grey),
                  SizedBox(height: 16.h),
                  Text(
                    'Vui lòng đăng nhập để tiếp tục',
                    style: TextStyle(fontSize: 16.sp),
                  ),
                ],
              ),
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(title: const Text("Shop của tôi"), centerTitle: true),
          body: SingleChildScrollView(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildShopHeader(user),
                SizedBox(height: 20.h),
                _buildStatisticsSection(),
                SizedBox(height: 24.h),
                _buildMenuGrid(context, user),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildShopHeader(UserEntity user) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30.r,
            backgroundColor: AppColors.secondary,
            backgroundImage: user.avatar != null
                ? NetworkImage(user.avatar!)
                : null,
            child: user.avatar == null
                ? Icon(Icons.storefront, size: 30.r, color: AppColors.primaryBlue)
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
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  "Đang hoạt động",
                  style: TextStyle(fontSize: 14.sp, color: Colors.green),
                ),
                SizedBox(height: 4.h),
                Text(
                  "ID: ${user.id}",
                  style: TextStyle(fontSize: 12.sp, color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticsSection() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Thống kê hôm nay",
            style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              _buildStatItem(
                title: "Doanh thu",
                value: "0 đ",
                icon: Icons.trending_up,
              ),
              SizedBox(width: 16.w),
              _buildStatItem(
                title: "Đơn hàng",
                value: "0",
                icon: Icons.shopping_bag,
              ),
              SizedBox(width: 16.w),
              _buildStatItem(
                title: "Tỷ lệ hoàn",
                value: "0%",
                icon: Icons.assessment,
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: Colors.amber.shade50,
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  size: 16.r,
                  color: Colors.amber.shade700,
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    "Thống kê sẽ được cập nhật sau khi có đơn hàng",
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.amber.shade700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required String title,
    required String value,
    required IconData icon,
  }) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, size: 24.sp, color: AppColors.primaryBlue),
          SizedBox(height: 4.h),
          Text(
            value,
            style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
          ),
          Text(
            title,
            style: TextStyle(fontSize: 11.sp, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuGrid(BuildContext context, UserEntity user) {
    final int shopId = user.id;
    // Kiểm tra admin: roleId == 1 hoặc role name chứa 'admin'
    final bool isAdmin = user.roleId == 1;

    final menuItems = <Map<String, dynamic>>[
      {
        "icon": Icons.add_box_outlined,
        "title": "Thêm sản phẩm",
        "onTap": () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddProductPage()),
          );
        },
      },
      {
        "icon": Icons.category_outlined,
        "title": "Quản lý danh mục",
        "onTap": () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const CategoryPage(isAdmin: true),
            ),
          );
        },
      },
      {
        "icon": Icons.inventory_2_outlined,
        "title": "Sản phẩm của tôi",
        "onTap": () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const MyProductsPage()),
          );
        },
      },
      {
        "icon": Icons.list_alt,
        "title": "Đơn hàng",
        "onTap": () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const SellerOrdersPage()),
          );
        },
      },
      {
        "icon": Icons.local_offer_outlined,
        "title": "Khuyến mãi Shop",
        "onTap": () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SellerDiscountListPage(shopId: shopId),
            ),
          );
        },
      },
      // Admin: Thêm menu riêng cho quản lý voucher toàn sàn
      if (isAdmin)
        {
          "icon": Icons.public,
          "title": "Voucher sàn",
          "onTap": () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const SellerDiscountListPage(
                  isAdmin: true,
                ),
              ),
            );
          },
        },
      {
        "icon": Icons.settings_outlined,
        "title": "Thiết lập Shop",
        "onTap": () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ShopSettingsPage(
                shopName: context.read<AuthBloc>().state is AuthSuccess
                    ? (context.read<AuthBloc>().state as AuthSuccess).user.name
                    : "Shop của tôi",
              ),
            ),
          );
        },
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16.w,
        mainAxisSpacing: 16.w,
        childAspectRatio: 1.2,
      ),
      itemCount: menuItems.length,
      itemBuilder: (context, index) {
        final item = menuItems[index];
        return _buildMenuCard(
          icon: item['icon'] as IconData,
          title: item['title'] as String,
          onTap: item['onTap'] as VoidCallback,
        );
      },
    );
  }

  Widget _buildMenuCard({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32.sp, color: AppColors.primaryBlue),
            SizedBox(height: 12.h),
            Text(
              title,
              style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}
