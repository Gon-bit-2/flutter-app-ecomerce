import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart'; // Ensure dependency is added
import '../../../product/domain/entities/product.dart';
import 'product_card.dart';

class DailyDiscoverSection extends StatelessWidget {
  final List<Product> products;

  const DailyDiscoverSection({super.key, required this.products});

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 10.h),
      sliver: SliverMasonryGrid.count(
        crossAxisCount: 2,
        mainAxisSpacing: 8.h,
        crossAxisSpacing: 8.w,
        childCount: products.length,
        itemBuilder: (context, index) {
          return ProductCard(product: products[index]);
        },
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
        color: Colors.grey[50],
        padding: EdgeInsets.symmetric(vertical: 15.h),
        child: Center(
          child: Text(
            'GỢI Ý HÔM NAY',
            style: TextStyle(
              color: Colors.red,
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
