import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:app_fe_ecomerce/core/styles/app_colors.dart';
import 'package:app_fe_ecomerce/features/auth/presentation/bloc/auth/auth_bloc.dart';
import 'package:app_fe_ecomerce/features/auth/presentation/pages/login_page.dart';
import 'package:app_fe_ecomerce/features/product/domain/entities/product.dart';
import 'package:app_fe_ecomerce/features/chat/presentation/pages/chat_detail_page.dart' as app_fe_ecomerce_chat;
import 'package:app_fe_ecomerce/features/shop/presentation/pages/shop_profile_page.dart';

class ProductBottomActionBar extends StatelessWidget {
  final Product product;
  final VoidCallback onAddToCart;
  final VoidCallback onBuyNow;

  const ProductBottomActionBar({
    super.key,
    required this.product,
    required this.onAddToCart,
    required this.onBuyNow,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
      ),
      child: SafeArea(
        child: Row(
          children: [
            // Nút Chat
            Expanded(
              flex: 1,
              child: InkWell(
                onTap: () {
                  if (product.createdById != null) {
                    final authState = context.read<AuthBloc>().state;
                    if (authState is! AuthSuccess) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const LoginPage()),
                      );
                      return;
                    }

                    final shopName = product.shopName ?? 'Shop';
                    
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => app_fe_ecomerce_chat.ChatDetailPage(
                          conversationId: 0,
                          otherUserName: shopName,
                          otherUserAvatar: product.shopAvatar,
                          receiverId: product.createdById!,
                        ),
                      ),
                    );
                  }
                },
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.h),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.chat_bubble_outline,
                        color: AppColors.primaryBlue,
                        size: 20.sp,
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        "Chat",
                        style: TextStyle(
                          fontSize: 10.sp,
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Container(width: 1, height: 30.h, color: Colors.grey.shade300),
            // Nút Xem Shop
            Expanded(
              flex: 1,
              child: InkWell(
                onTap: () {
                  if (product.createdById != null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ShopProfilePage(
                          shopId: product.createdById!,
                          shopName: product.shopName,
                          shopAvatar: product.shopAvatar,
                        ),
                      ),
                    );
                  }
                },
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.h),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.store_outlined,
                        color: AppColors.primaryBlue,
                        size: 20.sp,
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        "Shop",
                        style: TextStyle(
                          fontSize: 10.sp,
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Container(width: 1, height: 30.h, color: Colors.grey.shade300),
            // Thêm vào giỏ
            Expanded(
              flex: 3,
              child: InkWell(
                onTap: onAddToCart,
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 14.h),
                  color: AppColors.secondary,
                  child: Text(
                    "Thêm vào giỏ hàng",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: AppColors.primaryBlue,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
            // Mua ngay
            Expanded(
              flex: 3,
              child: InkWell(
                onTap: onBuyNow,
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 14.h),
                  color: AppColors.primaryBlue,
                  child: Text(
                    "Mua ngay",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
