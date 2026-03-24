import 'package:app_fe_ecomerce/core/styles/app_colors.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../category/domain/entities/category.dart';

class CategorySection extends StatelessWidget {
  final List<CategoryEntity> categories;

  const CategorySection({super.key, required this.categories});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100.h,
      child: ListView.separated(
        padding: EdgeInsets.symmetric(horizontal: 10.w),
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (_, __) => SizedBox(width: 15.w),
        itemBuilder: (context, index) {
          final cat = categories[index];
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 50.w,
                height: 50.w,
                decoration: const BoxDecoration(
                  color: AppColors.secondary,
                  shape: BoxShape.circle,
                ),
                padding: EdgeInsets.all(10.w),
                child: cat.logo != null
                    ? CachedNetworkImage(
                        imageUrl: cat.logo!,
                        errorWidget: (context, url, error) => Icon(
                          Icons.category,
                          color: AppColors.primaryBlue,
                          size: 24.sp,
                        ),
                        placeholder: (context, url) => Padding(
                          padding: EdgeInsets.all(10.w),
                          child: const CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.primaryBlue,
                          ),
                        ),
                      )
                    : Icon(
                        Icons.category,
                        color: AppColors.primaryBlue,
                        size: 24.sp,
                      ),
              ),
              SizedBox(height: 5.h),
              SizedBox(
                width: 60.w,
                child: Text(
                  cat.name,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 10.sp,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
