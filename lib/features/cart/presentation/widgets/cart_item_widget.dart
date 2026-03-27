import 'package:app_fe_ecomerce/core/styles/app_colors.dart';
import 'package:app_fe_ecomerce/core/styles/app_text_styles.dart';
import 'package:app_fe_ecomerce/features/cart/domain/entities/cart_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:app_fe_ecomerce/core/common/widgets/app_network_image.dart';

class CartItemWidget extends StatelessWidget {
  final CartEntity item;
  final bool isSelected;
  final ValueChanged<bool?> onSelected;
  final VoidCallback onIncrease;
  final VoidCallback onDecrease;
  final VoidCallback onRemove;

  const CartItemWidget({
    super.key,
    required this.item,
    required this.isSelected,
    required this.onSelected,
    required this.onIncrease,
    required this.onDecrease,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Checkbox chọn sản phẩm
          Checkbox(
            value: isSelected,
            onChanged: onSelected,
            activeColor: AppColors.primaryBlue,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4.r),
            ),
          ),

          // Ảnh sản phẩm
          ClipRRect(
            borderRadius: BorderRadius.circular(8.r),
            child: item.image != null && item.image!.isNotEmpty
                ? AppNetworkImage(
                    imageUrl: item.image!,
                    width: 80.w,
                    height: 80.w,
                    fit: BoxFit.cover,
                  )
                : Container(
                    width: 80.w,
                    height: 80.w,
                    color: AppColors.inputBackground,
                    child: Icon(
                      Icons.shopping_bag_outlined,
                      color: AppColors.textSecondary,
                      size: 24.sp,
                    ),
                  ),
          ),

          SizedBox(width: 12.w),

          // Thông tin sản phẩm
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Tên sản phẩm
                Text(
                  item.productName ?? 'Sản phẩm',
                  style: AppTextStyles.bodyLarge.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4.h),

                // Phân loại (SKU Value)
                if (item.skuValue != null && item.skuValue!.isNotEmpty)
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.w,
                      vertical: 2.h,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.inputBackground,
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                    child: Text(
                      item.skuValue!,
                      style: AppTextStyles.bodyMedium.copyWith(fontSize: 12.sp),
                    ),
                  ),
                SizedBox(height: 8.h),

                // Giá + Số lượng
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Giá
                    Text(
                      '${_formatPrice(item.price)}đ',
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: AppColors.error,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    // Nút +/-
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.border),
                        borderRadius: BorderRadius.circular(6.r),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _QuantityButton(
                            icon: Icons.remove,
                            onTap: item.quantity > 1 ? onDecrease : null,
                          ),
                          Container(
                            constraints: BoxConstraints(minWidth: 36.w),
                            alignment: Alignment.center,
                            child: Text(
                              '${item.quantity}',
                              style: AppTextStyles.bodyMedium.copyWith(
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                          _QuantityButton(icon: Icons.add, onTap: onIncrease),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Nút xóa
          InkWell(
            onTap: onRemove,
            borderRadius: BorderRadius.circular(20.r),
            child: Padding(
              padding: EdgeInsets.all(4.w),
              child: Icon(
                Icons.delete_outline,
                color: AppColors.textSecondary,
                size: 20.sp,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatPrice(num? price) {
    if (price == null) return '0';
    return price
        .toStringAsFixed(0)
        .replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        );
  }
}

class _QuantityButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const _QuantityButton({required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4.r),
      child: Container(
        padding: EdgeInsets.all(6.w),
        child: Icon(
          icon,
          size: 16.sp,
          color: onTap != null ? AppColors.textPrimary : AppColors.border,
        ),
      ),
    );
  }
}
