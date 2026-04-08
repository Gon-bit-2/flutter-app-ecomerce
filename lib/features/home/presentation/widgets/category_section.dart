import 'package:app_fe_ecomerce/core/styles/app_colors.dart';
import 'package:app_fe_ecomerce/core/common/widgets/app_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../category/domain/entities/category.dart';
import '../../../../features/search/presentation/pages/search_page.dart';

class CategorySection extends StatelessWidget {
  final List<CategoryEntity> categories;

  const CategorySection({super.key, required this.categories});

  @override
  Widget build(BuildContext context) {
    if (categories.isEmpty) return const SizedBox.shrink();

    // Sắp xếp thành 2 hàng nếu số lượng nhiều hơn 4
    final bool isMultiRow = categories.length > 4;
    final double itemHeight = 96.h; // Tăng một chút chiều cao
    final double listHeight = isMultiRow ? (itemHeight * 2 + 16.h) : itemHeight;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 20.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Danh mục nổi bật",
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.5,
                  ),
                ),
                Icon(Icons.arrow_forward_ios_rounded, size: 16.sp, color: AppColors.textSecondary),
              ],
            ),
          ),
          SizedBox(height: 16.h),
          SizedBox(
            height: listHeight,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Wrap(
                direction: Axis.vertical,
                spacing: 16.h,
                runSpacing: 20.w, // Khoảng cách giữa các cột
                children: categories.map((cat) => SizedBox(
                  width: 72.w, // Cố định chiều rộng của mỗi item
                  child: _buildCategoryItem(context, cat),
                )).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryItem(BuildContext context, CategoryEntity cat) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => SearchPage(
              initialCategoryId: cat.id.toString(),
            ),
          ),
        );
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 58.w,
            height: 58.w,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18.r), // Bo tròn dạng squircle
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryBlue.withOpacity(0.06),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18.r),
              child: cat.logo != null && cat.logo!.isNotEmpty
                  ? AppNetworkImage(
                      imageUrl: cat.logo!,
                      fit: BoxFit.cover,
                    )
                  : Center(
                      child: Icon(
                        Icons.category_rounded,
                        color: AppColors.primaryBlue,
                        size: 28.sp,
                      ),
                    ),
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            cat.name,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 11.sp,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}
