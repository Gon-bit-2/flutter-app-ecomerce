import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import 'package:app_fe_ecomerce/core/styles/app_colors.dart';
import 'package:app_fe_ecomerce/features/product/domain/entities/product.dart';
import 'package:app_fe_ecomerce/features/product/domain/entities/sku.dart';

class ProductPriceInfo extends StatelessWidget {
  final Product product;
  final SKU? selectedSku;

  const ProductPriceInfo({
    super.key,
    required this.product,
    this.selectedSku,
  });

  @override
  Widget build(BuildContext context) {
    final formatCurrency = NumberFormat("#,##0", "vi_VN");
    
    // Ưu tiên giá SKU đã chọn, fallback về giá base
    final displayPrice = selectedSku?.price ?? product.basePrice;
    final originalPrice = product.virtualPrice;
    
    double discount = 0;
    if (originalPrice != null && originalPrice > displayPrice) {
      discount = ((originalPrice - displayPrice) / originalPrice) * 100;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          crossAxisAlignment: WrapCrossAlignment.end,
          spacing: 8.w,
          runSpacing: 4.h,
          children: [
            Text(
              'đ${formatCurrency.format(displayPrice)}',
              style: TextStyle(
                color: AppColors.primaryBlue,
                fontSize: 28.sp,
                fontWeight: FontWeight.w900, // Đậm hơn
              ),
            ),
            if (originalPrice != null && originalPrice > displayPrice) ...[
              Padding(
                padding: EdgeInsets.only(bottom: 4.h),
                child: Text(
                  'đ${formatCurrency.format(originalPrice)}',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 16.sp,
                    decoration: TextDecoration.lineThrough,
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.only(bottom: 4.h),
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: AppColors.secondary, // Nền xanh nhạt
                  borderRadius: BorderRadius.circular(6.r),
                ),
                child: Text(
                  "-${discount.toStringAsFixed(0)}%",
                  style: TextStyle(
                    color: AppColors.primaryBlue, // Chữ xanh da trời đậm
                    fontSize: 12.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}
