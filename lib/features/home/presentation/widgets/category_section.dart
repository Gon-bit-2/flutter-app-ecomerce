import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../category/domain/entities/category.dart';

class CategorySection extends StatelessWidget {
  final List<Category> categories;

  const CategorySection({super.key, required this.categories});

  @override
  Widget build(BuildContext context) {
    // Determine how many rows/cols. ScreenUtil helps.
    // Basic Shoppee has 2 rows of 5 items scrollable horizontally.
    // For now, let's do a simple horizontal list or wrap.
    // If categories < 10, Wrap is fine.

    // Using a horizontal scroll view for flexibility
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
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(15.r),
                ),
                padding: EdgeInsets.all(10.w),
                // If cat.logo is null, use Icon
                child: cat.logo != null
                    ? CachedNetworkImage(
                        imageUrl: cat.logo!,
                        errorWidget: (context, url, error) => Icon(
                          Icons.category,
                          color: Colors.blue,
                          size: 24.sp,
                        ),
                        placeholder: (context, url) => Padding(
                          padding: EdgeInsets.all(10.w),
                          child: const CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        ),
                      )
                    : Icon(Icons.category, color: Colors.blue, size: 24.sp),
              ),
              SizedBox(height: 5.h),
              SizedBox(
                width: 60.w,
                child: Text(
                  cat.name,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 10.sp, color: Colors.black87),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
