import 'dart:async';
import 'package:app_fe_ecomerce/core/styles/app_colors.dart';
import 'package:app_fe_ecomerce/core/styles/app_text_styles.dart';
import 'package:app_fe_ecomerce/core/common/widgets/app_network_image.dart';
import 'package:app_fe_ecomerce/features/product/domain/entities/product.dart';
import 'package:app_fe_ecomerce/features/product/data/models/product_model.dart';
import 'package:app_fe_ecomerce/features/product/presentation/pages/product_detail_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import '../../../../core/network/dio_client.dart';

/// Trang hiển thị tất cả sản phẩm Flash Sale
class FlashSalePage extends StatefulWidget {
  final List<Product> initialProducts;

  const FlashSalePage({super.key, this.initialProducts = const []});

  @override
  State<FlashSalePage> createState() => _FlashSalePageState();
}

class _FlashSalePageState extends State<FlashSalePage> {
  final List<Product> _products = [];
  bool _isLoading = true;
  bool _hasMore = true;
  int _page = 1;
  static const int _limit = 20;

  late Timer _timer;
  late Duration _timeLeft;

  @override
  void initState() {
    super.initState();
    _products.addAll(widget.initialProducts);
    _initTimer();
    if (_products.isEmpty) {
      _loadProducts();
    } else {
      _isLoading = false;
    }
  }

  void _initTimer() {
    final now = DateTime.now();
    int minutesLeft = 29 - (now.minute % 30);
    int secondsLeft = 60 - now.second;
    if (secondsLeft == 60) {
      secondsLeft = 0;
      minutesLeft += 1;
    }
    _timeLeft = Duration(minutes: minutesLeft, seconds: secondsLeft);

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

  Future<void> _loadProducts({bool isRefresh = false}) async {
    if (isRefresh) {
      setState(() {
        _page = 1;
        _products.clear();
        _hasMore = true;
      });
    }

    setState(() => _isLoading = true);
    try {
      final dioClient = GetIt.I<DioClient>();
      final response = await dioClient.get(
        '/product',
        queryParameters: {
          'page': _page,
          'limit': _limit,
        },
      );

      List<dynamic> data;
      if (response.data is List) {
        data = response.data as List;
      } else if (response.data is Map && response.data['data'] != null) {
        data = response.data['data'] as List;
      } else {
        data = [];
      }

      final products = data.map((e) => ProductModel.fromJson(e)).toList();
      setState(() {
        _products.addAll(products);
        _hasMore = products.length >= _limit;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  void _loadMore() {
    if (!_isLoading && _hasMore) {
      _page++;
      _loadProducts();
    }
  }

  @override
  Widget build(BuildContext context) {
    final formatCurrency = NumberFormat("#,##0", "vi_VN");
    String hoursStr = _timeLeft.inHours.toString().padLeft(2, '0');
    String minutesStr = (_timeLeft.inMinutes % 60).toString().padLeft(2, '0');
    String secondsStr = (_timeLeft.inSeconds % 60).toString().padLeft(2, '0');

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.primaryBlue,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            Text(
              'FLASH SALE',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                fontStyle: FontStyle.italic,
                color: Colors.white,
              ),
            ),
            SizedBox(width: 12.w),
            _buildTimerBox(hoursStr),
            const Text(' : ',
                style:
                    TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
            _buildTimerBox(minutesStr),
            const Text(' : ',
                style:
                    TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
            _buildTimerBox(secondsStr),
          ],
        ),
      ),
      body: NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          if (notification is ScrollEndNotification &&
              notification.metrics.extentAfter < 200) {
            _loadMore();
          }
          return false;
        },
        child: RefreshIndicator(
          onRefresh: () => _loadProducts(isRefresh: true),
          color: AppColors.primaryBlue,
          child: _products.isEmpty && _isLoading
              ? Center(
                  child: CircularProgressIndicator(
                    color: AppColors.primaryBlue,
                  ),
                )
              : _products.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.flash_off,
                              size: 64.sp, color: AppColors.textSecondary),
                          SizedBox(height: 12.h),
                          Text(
                            'Chưa có sản phẩm Flash Sale',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    )
                  : GridView.builder(
                      padding: EdgeInsets.all(10.w),
                      gridDelegate:
                          SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.55,
                        crossAxisSpacing: 10.w,
                        mainAxisSpacing: 10.w,
                      ),
                      itemCount: _products.length + (_hasMore ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index >= _products.length) {
                          return Center(
                            child: Padding(
                              padding: EdgeInsets.all(16.w),
                              child: SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ),
                          );
                        }
                        return _buildFlashSaleCard(
                            _products[index], formatCurrency);
                      },
                    ),
        ),
      ),
    );
  }

  Widget _buildTimerBox(String text) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(4.r),
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

  Widget _buildFlashSaleCard(Product product, NumberFormat formatCurrency) {
    final imageUrl = product.images.isNotEmpty
        ? product.images[0].replaceFirst('url: ', '').trim()
        : '';

    // Tính phần trăm giảm giá (nếu có virtualPrice)
    String? discountPercent;
    if (product.virtualPrice != null && product.virtualPrice! > product.basePrice) {
      final percent =
          ((product.virtualPrice! - product.basePrice) / product.virtualPrice! * 100)
              .round();
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
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image + badge giảm giá
            Expanded(
              flex: 3,
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(8.r)),
                    child: imageUrl.isNotEmpty
                        ? AppNetworkImage(
                            imageUrl: imageUrl,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          )
                        : Container(
                            color: AppColors.surface,
                            child: Center(
                              child: Icon(Icons.image,
                                  color: AppColors.textSecondary, size: 32.sp),
                            ),
                          ),
                  ),
                  if (discountPercent != null)
                    Positioned(
                      top: 0,
                      right: 0,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 6.w,
                          vertical: 3.h,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.warning,
                          borderRadius: BorderRadius.only(
                            topRight: Radius.circular(8.r),
                            bottomLeft: Radius.circular(8.r),
                          ),
                        ),
                        child: Text(
                          discountPercent,
                          style: TextStyle(
                            fontSize: 11.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            // Info
            Expanded(
              flex: 2,
              child: Padding(
                padding: EdgeInsets.all(8.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 12.sp),
                    ),
                    const Spacer(),
                    // Giá
                    Text(
                      'đ${formatCurrency.format(product.basePrice)}',
                      style: TextStyle(
                        color: AppColors.primaryBlue,
                        fontSize: 15.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (product.virtualPrice != null &&
                        product.virtualPrice! > product.basePrice)
                      Text(
                        'đ${formatCurrency.format(product.virtualPrice)}',
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: AppColors.textSecondary,
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                    SizedBox(height: 4.h),
                    // Progress bar bán
                    Container(
                      width: double.infinity,
                      height: 16.h,
                      decoration: BoxDecoration(
                        color: AppColors.secondary,
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Stack(
                        children: [
                          FractionallySizedBox(
                            widthFactor: 0.6, // Mock progress
                            child: Container(
                              decoration: BoxDecoration(
                                color: AppColors.primaryBlue,
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                            ),
                          ),
                          Center(
                            child: Text(
                              '${product.sold ?? 0} ĐÃ BÁN',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 9.sp,
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
            ),
          ],
        ),
      ),
    );
  }
}
