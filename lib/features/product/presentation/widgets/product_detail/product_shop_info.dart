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
      padding: EdgeInsets.symmetric(vertical: 12.h),
      child: Row(
        children: [
          // Shop Avatar
          CircleAvatar(
            radius: 22.r,
            backgroundColor: AppColors.secondary,
            backgroundImage: shopAvatar != null ? NetworkImage(shopAvatar) : null,
            child: shopAvatar == null
                ? Icon(Icons.storefront, size: 22.r, color: AppColors.primaryBlue)
                : null,
          ),
          SizedBox(width: 12.w),
          // Shop Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  shopName,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 2.h),
                Row(
                  children: [
                    Icon(Icons.verified, size: 12.sp, color: AppColors.primaryBlue),
                    SizedBox(width: 4.w),
                    Text(
                      'Shop Uy Tín',
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: AppColors.primaryBlue,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Nút Xem Shop nhỏ
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
              side: BorderSide(color: AppColors.primaryBlue),
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
              minimumSize: Size.zero,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4.r),
              ),
            ),
            child: Text(
              'Xem Shop',
              style: TextStyle(
                fontSize: 12.sp,
                color: AppColors.primaryBlue,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
