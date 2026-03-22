import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../domain/entities/product_info.dart';

class VideoProductCard extends StatelessWidget {
  final ProductInfo product;

  const VideoProductCard({
    super.key,
    required this.product,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Navigate to product detail
        // Navigator.pushNamed(context, RouteName.productDetail, arguments: product.id);
      },
      child: Container(
        padding: EdgeInsets.all(8.w),
        margin: EdgeInsets.only(bottom: 8.h),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.95),
          borderRadius: BorderRadius.circular(8.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 4,
              offset: const Offset(0, 2),
            )
          ],
        ),
        child: Row(
          children: [
            // Thumbnail
            ClipRRect(
              borderRadius: BorderRadius.circular(6.r),
              child: Image.network(
                product.images.isNotEmpty
                    ? product.images.first
                    : 'https://via.placeholder.com/150',
                width: 60.w,
                height: 60.w,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  width: 60.w,
                  height: 60.w,
                  color: Colors.grey[300],
                  child: const Icon(Icons.image_not_supported, color: Colors.grey),
                ),
              ),
            ),
            SizedBox(width: 12.w),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4.h),
                  Row(
                    children: [
                      Text(
                        'đ${product.basePrice.toStringAsFixed(0)}',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                      if (product.virtualPrice != null &&
                          product.virtualPrice! > product.basePrice) ...[
                        SizedBox(width: 8.w),
                        Text(
                          'đ${product.virtualPrice!.toStringAsFixed(0)}',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Colors.grey,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                      ]
                    ],
                  ),
                ],
              ),
            ),
            // Cart Icon Button
            Container(
              padding: EdgeInsets.all(6.w),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.shopping_cart_outlined,
                color: Theme.of(context).primaryColor,
                size: 20.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
