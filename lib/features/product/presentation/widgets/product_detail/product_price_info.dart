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
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              'đ${formatCurrency.format(displayPrice)}',
              style: TextStyle(
                color: AppColors.primaryBlue,
                fontSize: 24.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (originalPrice != null && originalPrice > displayPrice) ...[
              SizedBox(width: 8.w),
              Text(
                'đ${formatCurrency.format(originalPrice)}',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 14.sp,
                  decoration: TextDecoration.lineThrough,
                ),
              ),
              SizedBox(width: 8.w),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color: AppColors.secondary,
                  borderRadius: BorderRadius.circular(2.r),
                ),
                child: Text(
                  "-${discount.toStringAsFixed(0)}%",
                  style: TextStyle(
                    color: AppColors.primaryBlue,
                    fontSize: 10.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
        // Hiển thị stock SKU đã chọn
        if (selectedSku != null) ...[
          SizedBox(height: 4.h),
          Text(
            selectedSku!.stock > 0
                ? 'Còn ${selectedSku!.stock} sản phẩm'
                : 'Hết hàng',
            style: TextStyle(
              color: selectedSku!.stock > 0 ? Colors.grey[600] : Colors.red,
              fontSize: 12.sp,
            ),
          ),
        ],
      ],
    );
  }
}
