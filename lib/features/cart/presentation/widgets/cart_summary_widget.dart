import 'package:app_fe_ecomerce/core/common/widgets/custom_button.dart';
import 'package:app_fe_ecomerce/core/styles/app_colors.dart';
import 'package:app_fe_ecomerce/core/styles/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CartSummaryWidget extends StatelessWidget {
  final bool isAllSelected;
  final ValueChanged<bool?> onSelectAll;
  final int selectedCount;
  final num totalPrice;
  final VoidCallback onCheckout;
  final bool isLoading;

  const CartSummaryWidget({
    super.key,
    required this.isAllSelected,
    required this.onSelectAll,
    required this.selectedCount,
    required this.totalPrice,
    required this.onCheckout,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            // Checkbox "Chọn tất cả"
            Checkbox(
              value: isAllSelected,
              onChanged: onSelectAll,
              activeColor: AppColors.primaryBlue,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4.r),
              ),
            ),
            Text(
              'Tất cả',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textPrimary,
              ),
            ),

            const Spacer(),

            // Tổng tiền
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'Tổng thanh toán',
                  style: AppTextStyles.bodyMedium.copyWith(fontSize: 12.sp),
                ),
                Text(
                  '${_formatPrice(totalPrice)}đ',
                  style: AppTextStyles.h3.copyWith(
                    color: AppColors.error,
                    fontWeight: FontWeight.bold,
                    fontSize: 18.sp,
                  ),
                ),
              ],
            ),
            SizedBox(width: 12.w),

            // Nút "Mua hàng"
            SizedBox(
              width: 120.w,
              height: 44.h,
              child: CustomButton(
                text: 'Mua hàng ($selectedCount)',
                isLoading: isLoading,
                onPressed: selectedCount > 0 ? onCheckout : () {},
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatPrice(num price) {
    // Handle potential null or 0 values safely
    final safePrice = price is int || price is double ? price : 0;
    return safePrice
        .toStringAsFixed(0)
        .replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        );
  }
}
