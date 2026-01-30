import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import '../../../product/presentation/pages/product_detail_page.dart';
import '../../../product/domain/entities/product.dart';

class ProductCard extends StatelessWidget {
  final Product product;

  const ProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final formatCurrency = NumberFormat("#,##0", "vi_VN");

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailPage(product: product),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(4.r), // Standard Shopee corner
          border: Border.all(color: Colors.grey[200]!),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              offset: const Offset(0, 2),
              blurRadius: 2,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            AspectRatio(
              aspectRatio: 1,
              child: Stack(
                children: [
                  (product.images.isNotEmpty && product.images.first.isNotEmpty)
                      ? CachedNetworkImage(
                          imageUrl: product.images.first.startsWith('url: ')
                              ? product.images.first
                                    .replaceFirst('url: ', '')
                                    .trim()
                              : product.images.first,
                          width: double.infinity,
                          height: double.infinity,
                          fit: BoxFit.cover,
                          errorWidget: (_, __, ___) => Container(
                            color: Colors.grey[100],
                            child: const Icon(
                              Icons.image_not_supported,
                              color: Colors.grey,
                            ),
                          ),
                          placeholder: (_, __) => Container(
                            color: Colors.grey[100],
                            child: const Center(
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                        )
                      : Container(
                          width: double.infinity,
                          height: double.infinity,
                          color: Colors.grey[100],
                          child: const Icon(
                            Icons.image_not_supported,
                            color: Colors.grey,
                          ),
                        ),
                  // Mall Tag
                  if (product.isMall)
                    Positioned(
                      top: 4.h,
                      left: 0,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 4.w,
                          vertical: 2.h,
                        ),
                        color: const Color(0xFFD0011B),
                        child: Text(
                          "Mall",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            // Info
            Padding(
              padding: EdgeInsets.all(8.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    maxLines: 1, // Reduce to 1 line if needed, or check height
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 12.sp, color: Colors.black87),
                  ),
                  SizedBox(height: 4.h),
                  Row(
                    children: [
                      // If virtual price exists, show discount tag? Or old price?
                      // Let's just show Price
                      Text(
                        'đ',
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontSize: 10.sp,
                        ),
                      ),
                      Text(
                        formatCurrency.format(product.basePrice),
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Sold count
                      Text(
                        '${product.sold ?? 0} sold',
                        style: TextStyle(fontSize: 10.sp, color: Colors.grey),
                      ),
                      // Icon(Icons.favorite_border, size: 14.sp, color: Colors.grey),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
