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
      if (mounted) {
        setState(() {
          if (_timeLeft.inSeconds > 0) {
            _timeLeft -= const Duration(seconds: 1);
          } else {
            _timeLeft = const Duration(minutes: 30);
          }
        });
      }
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
    String minutesStr = (_timeLeft.inMinutes % 60).toString().padLeft(2, '0');
    String secondsStr = (_timeLeft.inSeconds % 60).toString().padLeft(2, '0');

    return Container(
      margin: EdgeInsets.symmetric(vertical: 8.h),
      padding: EdgeInsets.symmetric(vertical: 16.h),
      decoration: BoxDecoration(
        color: AppColors.secondary, // Xanh nhạt (#E3F2FD) từ Design System
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Row(
              children: [
                Icon(Icons.bolt, color: const Color(0xFFFF9800), size: 28.sp), // Cảnh báo/Vàng cam
                SizedBox(width: 4.w),
                Text(
                  'FLASH SALE',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w900,
                    fontStyle: FontStyle.italic,
                    color: AppColors.primaryBlue, // Sky Blue chủ đạo
                  ),
                ),
                SizedBox(width: 12.w),
                // Timer
                _buildTimerBox(hoursStr),
                Text(':', style: _colonStyle()),
                _buildTimerBox(minutesStr),
                Text(':', style: _colonStyle()),
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
                        style: TextStyle(
                          color: AppColors.primaryBlue,
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Icon(
                        Icons.chevron_right,
                        size: 18.sp,
                        color: AppColors.primaryBlue,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 16.h),
          // Product List
          SizedBox(
            height: 250.h,
            child: ListView.separated(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: widget.flashSale.products.length,
              separatorBuilder: (_, __) => SizedBox(width: 12.w),
              itemBuilder: (context, index) {
                final product = widget.flashSale.products[index];
                final formatCurrency = NumberFormat("#,##0", "vi_VN");

                String? discountPercent;
                if (product.virtualPrice != null && product.virtualPrice! > product.basePrice) {
                  final percent = ((product.virtualPrice! - product.basePrice) / product.virtualPrice! * 100).round();
                  discountPercent = '-$percent%';
                }

                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ProductDetailPage(product: product),
                      ),
                    );
                  },
                  child: Container(
                    width: 140.w,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12.r),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Image Stack
                        Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(12.r),
                                topRight: Radius.circular(12.r),
                              ),
                              child: SizedBox(
                                height: 140.w,
                                width: double.infinity,
                                child: AppNetworkImage(
                                  imageUrl: product.images.isNotEmpty
                                      ? product.images.first
                                      : '',
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            if (discountPercent != null)
                              Positioned(
                                top: 8.h,
                                left: 0,
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 8.w,
                                    vertical: 4.h,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFF9800), // Vàng cam để nổi bật trên nền xanh
                                    borderRadius: BorderRadius.only(
                                      topRight: Radius.circular(8.r),
                                      bottomRight: Radius.circular(8.r),
                                    ),
                                  ),
                                  child: Text(
                                    discountPercent,
                                    style: TextStyle(
                                      fontSize: 12.sp,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                        Padding(
                          padding: EdgeInsets.all(8.w),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                'đ${formatCurrency.format(product.basePrice)}',
                                style: TextStyle(
                                  color: AppColors.primaryBlue, // Giá tiền màu chính
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 8.h),
                              // Custom Progress Bar
                              LayoutBuilder(
                                builder: (context, constraints) {
                                  final totalSold = product.sold ?? 0;
                                  final totalStock = product.skus.isNotEmpty
                                      ? product.skus.fold(0, (sum, sku) => sum + sku.stock)
                                      : 100;
                                  final total = totalSold + totalStock;
                                  final ratio = total > 0
                                      ? (totalSold / total).clamp(0.0, 1.0)
                                      : 0.0;

                                  return Container(
                                    width: double.infinity,
                                    height: 18.h,
                                    decoration: BoxDecoration(
                                      color: AppColors.surface, // Trắng xám
                                      borderRadius: BorderRadius.circular(10.r),
                                    ),
                                    child: Stack(
                                      children: [
                                        FractionallySizedBox(
                                          widthFactor: ratio == 0.0 ? 0.05 : ratio,
                                          child: Container(
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                colors: [
                                                  AppColors.primaryBlue.withOpacity(0.6),
                                                  AppColors.primaryBlue,
                                                ],
                                              ),
                                              borderRadius: BorderRadius.circular(10.r),
                                            ),
                                          ),
                                        ),
                                        Center(
                                          child: Text(
                                            totalSold > 0 ? 'ĐÃ BÁN $totalSold' : 'SẮP BÁN HẾT',
                                            style: TextStyle(
                                              color: ratio > 0.3 ? Colors.white : AppColors.textPrimary,
                                              fontSize: 9.sp,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
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

  TextStyle _colonStyle() {
    return TextStyle(
      color: AppColors.primaryBlue,
      fontWeight: FontWeight.bold,
      fontSize: 16.sp,
    );
  }

  Widget _buildTimerBox(String text) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 4.h),
      margin: EdgeInsets.symmetric(horizontal: 2.w),
      decoration: BoxDecoration(
        color: AppColors.primaryBlue,
        borderRadius: BorderRadius.circular(6.r),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 13.sp,
        ),
      ),
    );
  }
}
