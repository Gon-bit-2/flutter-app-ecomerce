import 'package:app_fe_ecomerce/core/styles/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../auth/presentation/bloc/auth/auth_bloc.dart';
import '../../../shop/presentation/pages/my_shop_page.dart';
import '../../../cart/presentation/pages/cart_page.dart';
import '../../../cart/presentation/bloc/cart/cart_bloc.dart';
import '../../../search/presentation/pages/search_page.dart';
import '../../../chat/presentation/pages/conversations_page.dart';

class HomeAppBar extends StatelessWidget {
  const HomeAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      pinned: true,
      floating: true,
      elevation: 0,
      toolbarHeight: 60.h,
      titleSpacing: 0,
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.primaryBlue,
              AppColors.primaryLight,
            ],
          ),
        ),
      ),
      title: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w),
        child: Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SearchPage()),
                  );
                },
                child: Container(
                  height: 40.h,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 12.w),
                  child: Row(
                    children: [
                      Icon(Icons.search, color: AppColors.textSecondary, size: 20.sp),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: Text(
                          'Tìm kiếm sản phẩm...',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 14.sp,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Icon(
                        Icons.camera_alt_outlined,
                        color: AppColors.textSecondary,
                        size: 20.sp,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(width: 12.w),
            BlocBuilder<CartBloc, CartState>(
              builder: (context, state) {
                int cartCount = 0;
                if (state is CartLoaded) {
                  cartCount = state.items.length;
                }
                return _buildIconAction(
                  Icons.shopping_cart_outlined,
                  badgeCount: cartCount,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const CartPage()),
                    );
                  },
                );
              },
            ),
            SizedBox(width: 12.w),
            _buildIconAction(
              Icons.chat_bubble_outline,
              badgeCount: 0,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ConversationsPage()),
                );
              },
            ),
            SizedBox(width: 12.w),
            BlocBuilder<AuthBloc, AuthState>(
              builder: (context, state) {
                if (state is AuthSuccess) {
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const MyShopPage()),
                      );
                    },
                    child: Icon(Icons.store, color: Colors.white, size: 24.sp),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
            SizedBox(width: 8.w),
          ],
        ),
      ),
    );
  }

  Widget _buildIconAction(
    IconData icon, {
    int badgeCount = 0,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Icon(icon, color: Colors.white, size: 24.sp),
          if (badgeCount > 0)
            Positioned(
              top: -5,
              right: -5,
              child: Container(
                padding: EdgeInsets.all(4.w),
                decoration: const BoxDecoration(
                  color: AppColors.error,
                  shape: BoxShape.circle,
                ),
                constraints: BoxConstraints(minWidth: 16.w, minHeight: 16.w),
                child: Center(
                  child: Text(
                    '$badgeCount',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
