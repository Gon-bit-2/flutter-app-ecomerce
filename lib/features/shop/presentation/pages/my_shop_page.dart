import 'package:app_fe_ecomerce/core/styles/app_colors.dart';
import 'package:app_fe_ecomerce/core/utils/currency_formatter.dart';
import 'package:app_fe_ecomerce/features/category/presentation/pages/category_page.dart';
import 'package:app_fe_ecomerce/features/order/presentation/pages/seller_orders_page.dart';
import 'package:app_fe_ecomerce/features/product/presentation/pages/add_product_page.dart';
import 'package:app_fe_ecomerce/features/product/presentation/pages/my_products_page.dart';
import 'package:app_fe_ecomerce/features/discount/presentation/pages/seller_discount_list_page.dart';
import 'package:app_fe_ecomerce/features/shop/presentation/pages/shop_settings_page.dart';
import 'package:app_fe_ecomerce/features/auth/domain/entities/user_entity.dart';
import 'package:app_fe_ecomerce/features/auth/presentation/bloc/auth/auth_bloc.dart';
import 'package:app_fe_ecomerce/features/shop/presentation/bloc/shop_statistics_cubit.dart';
import 'package:app_fe_ecomerce/features/shop/presentation/bloc/shop_statistics_state.dart';
import 'package:app_fe_ecomerce/features/shop/presentation/widgets/statistic_card.dart';
import 'package:app_fe_ecomerce/injection_container.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';

class MyShopPage extends StatefulWidget {
  const MyShopPage({super.key});

  @override
  State<MyShopPage> createState() => _MyShopPageState();
}

class _MyShopPageState extends State<MyShopPage> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        UserEntity? user;

        if (authState is AuthSuccess) {
          user = authState.user;
        } else if (authState is AuthLoading) {
          user = authState.user;
        }

        if (user == null) {
          return Scaffold(
            backgroundColor: AppColors.surface,
            appBar: AppBar(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              elevation: 0,
            ),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.storefront_outlined,
                    size: 64.sp,
                    color: Colors.grey.shade400,
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    'Vui lòng đăng nhập để tiếp tục',
                    style: TextStyle(
                      fontSize: 16.sp,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return BlocProvider(
          create: (context) => getIt<ShopStatisticsCubit>()..fetchStatistics(),
          child: Scaffold(
            backgroundColor: AppColors.surface,
            appBar: AppBar(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              elevation: 0,
              scrolledUnderElevation: 0,
            ),
            body: Builder(
              builder: (context) {
                return RefreshIndicator(
                  color: AppColors.primaryBlue,
                  backgroundColor: Colors.white,
                  onRefresh: () async {
                    await context.read<ShopStatisticsCubit>().fetchStatistics();
                  },
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 20.h,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildShopHeader(user!),
                        SizedBox(height: 24.h),
                        _buildStatisticsSection(context),
                        SizedBox(height: 24.h),
                        _buildMenuSection(context, user),
                        SizedBox(height: 30.h),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildShopHeader(UserEntity user) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primaryBlue, AppColors.darkBlue],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBlue.withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(3.w),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
            ),
            child: CircleAvatar(
              radius: 35.r,
              backgroundColor: AppColors.secondary,
              backgroundImage: user.avatar != null
                  ? CachedNetworkImageProvider(user.avatar!)
                  : null,
              child: user.avatar == null
                  ? Icon(
                      Icons.storefront,
                      size: 35.r,
                      color: AppColors.primaryBlue,
                    )
                  : null,
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.name,
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 8.h),
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 10.w,
                        vertical: 4.h,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 8.w,
                            height: 8.w,
                            decoration: const BoxDecoration(
                              color: Colors.greenAccent,
                              shape: BoxShape.circle,
                            ),
                          ),
                          SizedBox(width: 6.w),
                          Text(
                            "Đang hoạt động",
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: 4.h,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: Text(
                        "ID: ${user.id}",
                        style: TextStyle(fontSize: 12.sp, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h, left: 4.w),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18.sp,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }

  Widget _buildStatisticsSection(BuildContext context) {
    return BlocBuilder<ShopStatisticsCubit, ShopStatisticsState>(
      builder: (context, state) {
        if (state is ShopStatisticsLoading || state is ShopStatisticsInitial) {
          return _buildSkeletonStatistics();
        } else if (state is ShopStatisticsLoaded) {
          final stats = state.statistics;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle("Thống kê kinh doanh"),
              SizedBox(height: 4.h),
              Text(
                "Hôm nay",
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade600,
                ),
              ),
              SizedBox(height: 12.h),
              Row(
                children: [
                  Expanded(
                    child: StatisticCard(
                      title: "Doanh thu",
                      value: CurrencyFormatter.format(stats.today.totalRevenue),
                      icon: Icons.attach_money,
                      color: Colors.green,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: StatisticCard(
                      title: "Đơn hàng mới",
                      value: "${stats.today.totalOrders}",
                      icon: Icons.shopping_bag_outlined,
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20.h),
              Text(
                "Tháng này",
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade600,
                ),
              ),
              SizedBox(height: 12.h),
              Row(
                children: [
                  Expanded(
                    child: StatisticCard(
                      title: "Doanh thu",
                      value: CurrencyFormatter.format(
                        stats.thisMonth.totalRevenue,
                      ),
                      icon: Icons.account_balance_wallet_outlined,
                      color: Colors.orange,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: StatisticCard(
                      title: "Đơn hàng",
                      value: "${stats.thisMonth.totalOrders}",
                      icon: Icons.inventory_2_outlined,
                      color: Colors.purple,
                    ),
                  ),
                ],
              ),
            ],
          );
        } else if (state is ShopStatisticsError) {
          return Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.error_outline, color: Colors.red, size: 24.sp),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Text(
                        "Không thể tải thống kê",
                        style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                          fontSize: 16.sp,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8.h),
                Text(
                  state.message,
                  style: TextStyle(color: Colors.red.shade700),
                ),
                SizedBox(height: 12.h),
                ElevatedButton(
                  onPressed: () {
                    context.read<ShopStatisticsCubit>().fetchStatistics();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.red.shade900,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                      side: BorderSide(color: Colors.red.shade200),
                    ),
                  ),
                  child: const Text("Thử lại"),
                ),
              ],
            ),
          );
        }
        return const SizedBox();
      },
    );
  }

  Widget _buildSkeletonStatistics() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Shimmer.fromColors(
          baseColor: Colors.grey.shade300,
          highlightColor: Colors.grey.shade100,
          child: Container(
            width: 180.w,
            height: 24.h,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4.r),
            ),
          ),
        ),
        SizedBox(height: 16.h),
        Shimmer.fromColors(
          baseColor: Colors.grey.shade300,
          highlightColor: Colors.grey.shade100,
          child: Container(
            width: 80.w,
            height: 16.h,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4.r),
            ),
          ),
        ),
        SizedBox(height: 12.h),
        Row(
          children: [
            Expanded(child: _buildSkeletonCard()),
            SizedBox(width: 12.w),
            Expanded(child: _buildSkeletonCard()),
          ],
        ),
        SizedBox(height: 20.h),
        Shimmer.fromColors(
          baseColor: Colors.grey.shade300,
          highlightColor: Colors.grey.shade100,
          child: Container(
            width: 80.w,
            height: 16.h,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4.r),
            ),
          ),
        ),
        SizedBox(height: 12.h),
        Row(
          children: [
            Expanded(child: _buildSkeletonCard()),
            SizedBox(width: 12.w),
            Expanded(child: _buildSkeletonCard()),
          ],
        ),
      ],
    );
  }

  Widget _buildSkeletonCard() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Container(
        height: 100.h,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
        ),
      ),
    );
  }

  Widget _buildMenuSection(BuildContext context, UserEntity user) {
    final int shopId = user.id;
    final bool isAdmin = user.roleId == 1;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle("Sản phẩm & Danh mục"),
        _buildMenuGroup([
          _buildListTile(
            icon: Icons.add_circle_outline_rounded,
            title: "Thêm sản phẩm",
            color: Colors.blue,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AddProductPage()),
            ),
          ),
          _buildListTile(
            icon: Icons.inventory_2_outlined,
            title: "Sản phẩm của tôi",
            color: Colors.orange,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const MyProductsPage()),
            ),
          ),
          _buildListTile(
            icon: Icons.category_outlined,
            title: "Quản lý danh mục",
            color: Colors.purple,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const CategoryPage(isAdmin: true),
              ),
            ),
          ),
        ]),
        SizedBox(height: 24.h),
        _buildSectionTitle("Kinh doanh & Bán hàng"),
        _buildMenuGroup([
          _buildListTile(
            icon: Icons.receipt_long_outlined,
            title: "Quản lý đơn hàng",
            color: Colors.green,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SellerOrdersPage()),
            ),
          ),
          _buildListTile(
            icon: Icons.local_offer_outlined,
            title: "Khuyến mãi Shop",
            color: Colors.redAccent,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => SellerDiscountListPage(shopId: shopId),
              ),
            ),
          ),
          if (isAdmin)
            _buildListTile(
              icon: Icons.public,
              title: "Voucher toàn sàn",
              color: Colors.deepPurple,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const SellerDiscountListPage(isAdmin: true),
                ),
              ),
            ),
        ]),
        SizedBox(height: 24.h),
        _buildSectionTitle("Hệ thống"),
        _buildMenuGroup([
          _buildListTile(
            icon: Icons.settings_outlined,
            title: "Thiết lập cửa hàng",
            color: Colors.blueGrey,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ShopSettingsPage(
                  shopName: context.read<AuthBloc>().state is AuthSuccess
                      ? (context.read<AuthBloc>().state as AuthSuccess)
                            .user
                            .name
                      : "Shop của tôi",
                ),
              ),
            ),
          ),
        ]),
      ],
    );
  }

  Widget _buildMenuGroup(List<Widget> items) {
    List<Widget> children = [];
    for (int i = 0; i < items.length; i++) {
      children.add(items[i]);
      if (i < items.length - 1) {
        children.add(
          Divider(
            height: 1,
            thickness: 1,
            indent: 56.w,
            endIndent: 16.w,
            color: Colors.grey.shade100,
          ),
        );
      }
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildListTile({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16.r),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(icon, color: color, size: 24.sp),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: Colors.grey.shade400,
                size: 22.sp,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
