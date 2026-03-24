import 'package:app_fe_ecomerce/core/styles/app_colors.dart';
import 'package:app_fe_ecomerce/core/styles/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../product/domain/entities/product.dart';
import 'product_card.dart';

class DailyDiscoverSection extends StatelessWidget {
  final List<Product> products;

  const DailyDiscoverSection({super.key, required this.products});

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 10.h),
      sliver: SliverGrid(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 8.h,
          crossAxisSpacing: 8.w,
          childAspectRatio: 0.65,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) => ProductCard(product: products[index]),
          childCount: products.length,
        ),
      ),
    );
  }
}

// Header for Sticky usage
class DailyDiscoverHeader extends StatelessWidget {
  const DailyDiscoverHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Container(
        color: AppColors.surface,
        padding: EdgeInsets.symmetric(vertical: 15.h),
        child: Center(
          child: Text(
            'GỢI Ý HÔM NAY',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.primaryBlue,
              fontWeight: FontWeight.bold,
              fontSize: 14.sp,
              letterSpacing: 1.2,
            ),
          ),
        ),
      ),
    );
  }
}
