import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:app_fe_ecomerce/core/styles/app_colors.dart';
import 'package:app_fe_ecomerce/features/product/domain/entities/product.dart';
import 'package:app_fe_ecomerce/features/shop/presentation/pages/shop_profile_page.dart';

class ProductShopInfo extends StatelessWidget {
  final Product product;

  const ProductShopInfo({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final shopName = product.shopName ?? 'Shop #${product.createdById ?? ""}';
    final shopAvatar = product.shopAvatar;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 16.h),
      child: Row(
        children: [
          // Shop Avatar
          CircleAvatar(
            radius: 28.r,
            backgroundColor: AppColors.surface,
            backgroundImage: shopAvatar != null ? NetworkImage(shopAvatar) : null,
            child: shopAvatar == null
                ? Icon(Icons.storefront, size: 28.r, color: AppColors.primaryBlue)
                : null,
          ),
          SizedBox(width: 16.w),
          // Shop Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  shopName,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4.h),
                Row(
                  children: [
                    Icon(Icons.verified, size: 14.sp, color: AppColors.primaryBlue),
                    SizedBox(width: 4.w),
                    Text(
                      'Shop Uy Tín',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Nút Xem Shop
          OutlinedButton(
            onPressed: () {
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
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppColors.primaryBlue),
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.r), // Bo góc viên thuốc
              ),
            ),
            child: Text(
              'Xem Shop',
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.primaryBlue,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
