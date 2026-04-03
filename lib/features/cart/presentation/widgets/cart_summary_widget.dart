import 'package:app_fe_ecomerce/core/styles/app_colors.dart';
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
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            // Checkbox "Chọn tất cả"
            SizedBox(
              width: 24.w,
              height: 24.w,
              child: Checkbox(
                value: isAllSelected,
                onChanged: onSelectAll,
                activeColor: AppColors.primaryBlue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4.r),
                ),
                side: BorderSide(color: AppColors.border, width: 1.5),
              ),
            ),
            SizedBox(width: 8.w),
            Text(
              'Tất cả',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),

            // Tổng tiền
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.w),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Tổng thanh toán',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerRight,
                      child: Text(
                        'đ${_formatPrice(totalPrice)}',
                        style: TextStyle(
                          color: AppColors.primaryBlue, // Primary Blue instead of Red
                          fontWeight: FontWeight.bold,
                          fontSize: 18.sp,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(width: 8.w),

            // Nút "Mua hàng"
            SizedBox(
              height: 48.h, // Nút cao hơn chút cho hiện đại
              child: ElevatedButton(
                onPressed: (!isLoading && selectedCount > 0) ? onCheckout : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                child: isLoading
                    ? SizedBox(
                        height: 20.h,
                        width: 20.h,
                        child: const CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          'Mua hàng ($selectedCount)',
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                        ),
                      ),
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
