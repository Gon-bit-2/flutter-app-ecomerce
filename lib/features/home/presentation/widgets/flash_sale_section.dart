import 'dart:async';
import 'package:app_fe_ecomerce/core/styles/app_colors.dart';
import 'package:app_fe_ecomerce/core/common/widgets/app_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../domain/entities/flash_sale_entity.dart';
import 'package:intl/intl.dart';
import '../../../product/presentation/pages/product_detail_page.dart';
import '../pages/flash_sale_page.dart';

class FlashSaleSection extends StatefulWidget {
  final FlashSaleEntity flashSale;

  const FlashSaleSection({super.key, required this.flashSale});

  @override
  State<FlashSaleSection> createState() => _FlashSaleSectionState();
}

class _FlashSaleSectionState extends State<FlashSaleSection> {
  late Timer _timer;
  late Duration _timeLeft;

  @override
  void initState() {
    super.initState();
    _initTimer();
  }

  void _initTimer() {
    final now = DateTime.now();
    // Calculate minutes and seconds until the next 30-minute mark
    int minutesLeft = 29 - (now.minute % 30);
    int secondsLeft = 60 - now.second;
    if (secondsLeft == 60) {
      secondsLeft = 0;
      minutesLeft += 1;
    }
    _timeLeft = Duration(hours: 0, minutes: minutesLeft, seconds: secondsLeft);

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_timeLeft.inSeconds > 0) {
          _timeLeft -= const Duration(seconds: 1);
        } else {
          _timeLeft = const Duration(minutes: 30);
        }
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.flashSale.products.isEmpty) return const SizedBox.shrink();

    String hoursStr = _timeLeft.inHours.toString().padLeft(2, '0');
    // We shouldn't pad the hours but actually in the UI, they had '02'.
    // Flash sales can be 2 hours, but if it resets every 30m, hours is '00'.
    String minutesStr = (_timeLeft.inMinutes % 60).toString().padLeft(2, '0');
    String secondsStr = (_timeLeft.inSeconds % 60).toString().padLeft(2, '0');

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
                    color: AppColors.primaryBlue,
                  ),
                ),
                SizedBox(width: 10.w),
                // Timer Mock -> Real Timer
                _buildTimerBox(hoursStr),
                const Text(' : ', style: TextStyle(fontWeight: FontWeight.bold)),
                _buildTimerBox(minutesStr),
                const Text(' : ', style: TextStyle(fontWeight: FontWeight.bold)),
                _buildTimerBox(secondsStr),
                const Spacer(),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => FlashSalePage(
                          initialProducts: widget.flashSale.products,
                        ),
                      ),
                    );
                  },
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
            height: 240.h,
            child: ListView.separated(
              padding: EdgeInsets.symmetric(horizontal: 10.w),
              scrollDirection: Axis.horizontal,
              itemCount: widget.flashSale.products.length,
              separatorBuilder: (_, __) => SizedBox(width: 10.w),
              itemBuilder: (context, index) {
                final product = widget.flashSale.products[index];
                final formatCurrency = NumberFormat("#,##0", "vi_VN");
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ProductDetailPage(product: product),
                      ),
                    );
                  },
                  child: SizedBox(
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
                                color: AppColors.surface,
                                borderRadius: BorderRadius.circular(4.r),
                              ),
                              child: AppNetworkImage(
                                imageUrl: product.images.isNotEmpty
                                    ? product.images.first
                                    : '',
                                fit: BoxFit.cover,
                              ),
                            ),
                            Positioned(
                              top: 0,
                              right: 0,
                              child: Container(
                                color: AppColors.warning,
                                padding: EdgeInsets.symmetric(
                                  horizontal: 4.w,
                                  vertical: 2.h,
                                ),
                                child: Text(
                                  '50%',
                                  style: TextStyle(
                                    fontSize: 10.sp,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
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
                            color: AppColors.primaryBlue,
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
                            color: AppColors.secondary,
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: Stack(
                            children: [
                              Container(
                                width: 80.w, // Mock progress
                                decoration: BoxDecoration(
                                  color: AppColors.primaryBlue,
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
