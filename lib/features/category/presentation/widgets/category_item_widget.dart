import 'package:app_fe_ecomerce/core/styles/app_colors.dart';
import 'package:app_fe_ecomerce/core/styles/app_text_styles.dart';
import 'package:app_fe_ecomerce/features/category/domain/entities/category.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';

class CategoryItemWidget extends StatelessWidget {
  final CategoryEntity category;
  final VoidCallback onTap;
  final bool isAdmin;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const CategoryItemWidget({
    super.key,
    required this.category,
    required this.onTap,
    this.isAdmin = false,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Nội dung chính
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo danh mục
                ClipRRect(
                  borderRadius: BorderRadius.circular(8.r),
                  child: category.logo != null && category.logo!.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: category.logo!,
                          width: 56.w,
                          height: 56.w,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            width: 56.w,
                            height: 56.w,
                            color: AppColors.inputBackground,
                            child: Center(
                              child: SizedBox(
                                width: 16.w,
                                height: 16.w,
                                child: const CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.primaryBlue,
                                ),
                              ),
                            ),
                          ),
                          errorWidget: (context, url, error) =>
                              _buildPlaceholderIcon(),
                        )
                      : _buildPlaceholderIcon(),
                ),
                SizedBox(height: 8.h),

                // Tên danh mục
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4.w),
                  child: Text(
                    category.name,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                      fontSize: 12.sp,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),

            // Menu admin (sửa/xóa) — chỉ hiện khi isAdmin = true
            if (isAdmin)
              Positioned(
                top: 2,
                right: 2,
                child: PopupMenuButton<String>(
                  padding: EdgeInsets.zero,
                  constraints: BoxConstraints(minWidth: 120.w),
                  icon: Icon(
                    Icons.more_vert,
                    size: 18.sp,
                    color: AppColors.textSecondary,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  onSelected: (value) {
                    if (value == 'edit') {
                      onEdit?.call();
                    } else if (value == 'delete') {
                      onDelete?.call();
                    }
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(
                            Icons.edit_outlined,
                            size: 18.sp,
                            color: AppColors.primaryBlue,
                          ),
                          SizedBox(width: 8.w),
                          Text('Sửa', style: AppTextStyles.bodyMedium),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(
                            Icons.delete_outlined,
                            size: 18.sp,
                            color: AppColors.error,
                          ),
                          SizedBox(width: 8.w),
                          Text(
                            'Xóa',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.error,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholderIcon() {
    return Container(
      width: 56.w,
      height: 56.w,
      decoration: BoxDecoration(
        color: AppColors.primaryBlue.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Icon(
        Icons.category_outlined,
        color: AppColors.primaryBlue,
        size: 28.sp,
      ),
    );
  }
}
