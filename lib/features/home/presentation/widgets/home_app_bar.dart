import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../auth/presentation/bloc/auth/auth_bloc.dart';
import '../../../shop/presentation/pages/my_shop_page.dart';

class HomeAppBar extends StatelessWidget {
  const HomeAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      pinned: true,
      floating: true,
      backgroundColor: const Color(0xFF1A94FF), // Blue like the image
      elevation: 0,
      titleSpacing: 0,
      toolbarHeight: 60.h,
      title: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w),
        child: Row(
          children: [
            Expanded(
              child: Container(
                height: 45.h,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4.r),
                ),
                padding: EdgeInsets.symmetric(horizontal: 10.w),
                child: Row(
                  children: [
                    Icon(Icons.search, color: Colors.grey, size: 20.sp),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Text(
                        'Tìm kiếm Tai nghe không dây', // Placeholder
                        style: TextStyle(color: Colors.grey, fontSize: 14.sp),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Icon(
                      Icons.camera_alt_outlined,
                      color: Colors.grey,
                      size: 20.sp,
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(width: 15.w),
            _buildIconAction(Icons.shopping_cart_outlined, badgeCount: 2),
            SizedBox(width: 15.w),
            _buildIconAction(Icons.chat_bubble_outline, badgeCount: 9),
            SizedBox(width: 15.w),
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
            SizedBox(width: 10.w),
          ],
        ),
      ),
    );
  }

  Widget _buildIconAction(IconData icon, {int badgeCount = 0}) {
    return Stack(
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
                color: Colors.red,
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
    );
  }
}
