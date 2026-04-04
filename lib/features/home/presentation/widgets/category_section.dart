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

    // Để có một giao diện hiện đại, tôi sẽ chia danh sách danh mục thành 2 hàng nếu số lượng nhiều,
    // hoặc một hàng vuốt ngang mượt mà với hiệu ứng nổi khối.
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Text(
              "Danh mục",
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          SizedBox(height: 12.h),
          SizedBox(
            height: 100.h,
            child: ListView.separated(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: categories.length,
              separatorBuilder: (_, __) => SizedBox(width: 16.w),
              itemBuilder: (context, index) {
                final cat = categories[index];
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
                  child: SizedBox(
                    width: 70.w, // Đặt chiều rộng cố định để các item đều nhau
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        // Nền tròn cho icon / hình ảnh
                        Container(
                          width: 56.w,
                          height: 56.w,
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.04),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: ClipOval(
                            child: Padding(
                              padding: EdgeInsets.all(12.w),
                              child: cat.logo != null && cat.logo!.isNotEmpty
                                  ? AppNetworkImage(
                                      imageUrl: cat.logo!,
                                      fit: BoxFit.contain,
                                    )
                                  : Icon(
                                      Icons.category_outlined,
                                      color: AppColors.primaryBlue,
                                      size: 24.sp,
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
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
