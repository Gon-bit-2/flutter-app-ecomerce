import 'package:app_fe_ecomerce/core/styles/app_colors.dart';
import 'package:app_fe_ecomerce/core/styles/app_text_styles.dart';
import 'package:app_fe_ecomerce/features/category/domain/entities/category.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:app_fe_ecomerce/core/common/widgets/app_network_image.dart';

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
            Padding(
              padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 6.w),
              child: Column(
                children: [
                  // Logo danh mục (Ưu tiên Icon thông minh nếu ảnh là placeholder)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12.r),
                    child: _shouldShowPlaceholder(category.logo)
                        ? _buildPlaceholderIcon()
                        : AppNetworkImage(
                            imageUrl: category.logo!,
                            width: 60.w,
                            height: 60.w,
                            fit: BoxFit.cover,
                          ),
                  ),
                  SizedBox(height: 10.h),

                  // Tên danh mục (Cố định chiều cao hoặc dùng Expanded để cân đối hàng ngang)
                  Expanded(
                    child: Center(
                      child: Text(
                        category.name,
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                          fontSize: 11.5.sp,
                          height: 1.2,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ],
              ),
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
    IconData iconData = _getCategoryIcon(category.name);

    // Tạo màu sắc dựa trên hash code của tên danh mục để mỗi loại có một màu riêng biệt
    final colorIndex = category.name.hashCode % 5;
    final List<Color> bgColors = [
      Colors.blue.shade50,
      Colors.orange.shade50,
      Colors.green.shade50,
      Colors.purple.shade50,
      Colors.pink.shade50,
    ];
    final List<Color> iconColors = [
      Colors.blue.shade600,
      Colors.orange.shade600,
      Colors.green.shade600,
      Colors.purple.shade600,
      Colors.pink.shade600,
    ];

    return Container(
      width: 60.w,
      height: 60.w,
      decoration: BoxDecoration(
        color: bgColors[colorIndex],
        borderRadius: BorderRadius.circular(16.r), // Bo tròn hơn cho hiện đại
      ),
      child: Icon(
        iconData,
        color: iconColors[colorIndex],
        size: 32.sp,
      ),
    );
  }

  IconData _getCategoryIcon(String name) {
    final lowerName = name.toLowerCase();

    if (lowerName.contains('điện thoại') ||
        lowerName.contains('phone') ||
        lowerName.contains('di động')) {
      return Icons.smartphone_rounded;
    } else if (lowerName.contains('máy tính') ||
        lowerName.contains('laptop') ||
        lowerName.contains('computer')) {
      return Icons.laptop_mac_rounded;
    } else if (lowerName.contains('quần áo') ||
        lowerName.contains('thời trang') ||
        lowerName.contains('fashion')) {
      return Icons.checkroom_rounded;
    } else if (lowerName.contains('giày') || lowerName.contains('shoes')) {
      return Icons.snowshoeing_rounded; // Icon giống hình đôi giày hơn
    } else if (lowerName.contains('túi') || lowerName.contains('bag')) {
      return Icons.shopping_bag_rounded;
    } else if (lowerName.contains('công nghệ') ||
        lowerName.contains('electronics') ||
        lowerName.contains('điện tử')) {
      return Icons.memory_rounded;
    } else if (lowerName.contains('nhà cửa') ||
        lowerName.contains('đời sống') ||
        lowerName.contains('home')) {
      return Icons.home_work_rounded;
    } else if (lowerName.contains('đồ chơi') ||
        lowerName.contains('toy') ||
        lowerName.contains('trẻ em')) {
      return Icons.smart_toy_rounded;
    } else if (lowerName.contains('sức khỏe') ||
        lowerName.contains('làm đẹp') ||
        lowerName.contains('health')) {
      return Icons.spa_rounded;
    } else if (lowerName.contains('thể thao') || lowerName.contains('sport')) {
      return Icons.fitness_center_rounded;
    } else if (lowerName.contains('sách') || lowerName.contains('book')) {
      return Icons.menu_book_rounded;
    } else if (lowerName.contains('trang sức') || lowerName.contains('jewelry')) {
      return Icons.diamond_rounded;
    } else if (lowerName.contains('máy ảnh') || lowerName.contains('camera')) {
      return Icons.camera_alt_rounded;
    } else if (lowerName.contains('ô tô') ||
        lowerName.contains('xe') ||
        lowerName.contains('transport')) {
      return Icons.directions_car_rounded;
    } else if (lowerName.contains('đồng hồ') || lowerName.contains('watch')) {
      return Icons.watch_rounded;
    } else if (lowerName.contains('siêu thị') ||
        lowerName.contains('thực phẩm') ||
        lowerName.contains('food')) {
      return Icons.shopping_cart_rounded;
    }

    return Icons.category_rounded;
  }

  bool _shouldShowPlaceholder(String? logo) {
    if (logo == null || logo.isEmpty) return true;
    final lowerLogo = logo.toLowerCase();
    // Danh sách các URL placeholder phổ biến cần bỏ qua để hiện Icon thông minh
    return lowerLogo.contains('picsum.photos') ||
        lowerLogo.contains('via.placeholder') ||
        lowerLogo.contains('example.com') ||
        lowerLogo.contains('placeholder.png');
  }
}
