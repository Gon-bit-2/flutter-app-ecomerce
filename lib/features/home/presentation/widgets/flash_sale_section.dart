import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../domain/entities/flash_sale_entity.dart';
import 'package:intl/intl.dart';

class FlashSaleSection extends StatelessWidget {
  final FlashSaleEntity flashSale;

  const FlashSaleSection({super.key, required this.flashSale});

  @override
  Widget build(BuildContext context) {
    if (flashSale.products.isEmpty) return const SizedBox.shrink();

    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(vertical: 10.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 10.w),
            child: Row(
              children: [
                Text(
                  'FLASH SALE',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    fontStyle: FontStyle.italic,
                    color: Colors.orange[900], // Or black
                  ),
                ),
                SizedBox(width: 10.w),
                // Timer Mock
                _buildTimerBox('02'),
                Text(' : ', style: TextStyle(fontWeight: FontWeight.bold)),
                _buildTimerBox('14'),
                Text(' : ', style: TextStyle(fontWeight: FontWeight.bold)),
                _buildTimerBox('35'),
                const Spacer(),
                GestureDetector(
                  onTap: () {},
                  child: Row(
                    children: [
                      Text(
                        'Xem tất cả',
                        style: TextStyle(color: Colors.grey, fontSize: 12.sp),
                      ),
                      Icon(
                        Icons.chevron_right,
                        size: 16.sp,
                        color: Colors.grey,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 10.h),
          // Product List
          SizedBox(
            height: 220.h,
            child: ListView.separated(
              padding: EdgeInsets.symmetric(horizontal: 10.w),
              scrollDirection: Axis.horizontal,
              itemCount: flashSale.products.length,
              separatorBuilder: (_, __) => SizedBox(width: 10.w),
              itemBuilder: (context, index) {
                final product = flashSale.products[index];
                final formatCurrency = NumberFormat("#,##0", "vi_VN");
                return SizedBox(
                  width: 130.w,
                  child: Column(
                    children: [
                      // Image
                      Stack(
                        children: [
                          Container(
                            height: 130.w,
                            width: 130.w,
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(4.r),
                            ),
                            child: CachedNetworkImage(
                              imageUrl: product.images.isNotEmpty
                                  ? product.images.first
                                  : '',
                              fit: BoxFit.cover,
                              errorWidget: (_, __, ___) =>
                                  const Center(child: Icon(Icons.error)),
                            ),
                          ),
                          Positioned(
                            top: 0,
                            right: 0,
                            child: Container(
                              color: Colors.yellow[700],
                              padding: EdgeInsets.symmetric(
                                horizontal: 4.w,
                                vertical: 2.h,
                              ),
                              child: Text(
                                '50%',
                                style: TextStyle(
                                  fontSize: 10.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 6.h),
                      Text(
                        'đ${formatCurrency.format(product.basePrice)}',
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      // Progress Bar
                      Container(
                        width: double.infinity,
                        height: 16.h,
                        decoration: BoxDecoration(
                          color: Colors.red[100],
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Stack(
                          children: [
                            Container(
                              width: 80.w, // Mock progress
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                            ),
                            Center(
                              child: Text(
                                '${product.sold ?? 0} ĐÃ BÁN',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimerBox(String text) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(4.r),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 12.sp,
        ),
      ),
    );
  }
}
