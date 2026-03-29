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

/// Trang hiển thị thông tin Shop cho buyer xem
class ShopProfilePage extends StatefulWidget {
  final int shopId;
  final String? shopName;
  final String? shopAvatar;

  const ShopProfilePage({
    super.key,
    required this.shopId,
    this.shopName,
    this.shopAvatar,
  });

  @override
  State<ShopProfilePage> createState() => _ShopProfilePageState();
}

class _ShopProfilePageState extends State<ShopProfilePage> {
  final List<Product> _products = [];
  bool _isLoading = true;
  bool _hasMore = true;
  int _page = 1;
  static const int _limit = 10;

  @override
  void initState() {
    super.initState();
    _loadProducts();
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
          'createdById': widget.shopId,
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

    return Scaffold(
      backgroundColor: AppColors.surface,
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
          child: CustomScrollView(
            slivers: [
              // AppBar
              SliverAppBar(
                expandedHeight: 200.h,
                pinned: true,
                backgroundColor: AppColors.primaryBlue,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          AppColors.primaryBlue,
                          AppColors.primaryLight,
                        ],
                      ),
                    ),
                    child: SafeArea(
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(16.w, 56.h, 16.w, 16.h),
                        child: Row(
                          children: [
                            // Avatar
                            CircleAvatar(
                              radius: 36.r,
                              backgroundColor: Colors.white.withOpacity(0.2),
                              backgroundImage: widget.shopAvatar != null
                                  ? NetworkImage(widget.shopAvatar!)
                                  : null,
                              child: widget.shopAvatar == null
                                  ? Icon(Icons.storefront,
                                      size: 36.r, color: Colors.white)
                                  : null,
                            ),
                            SizedBox(width: 16.w),
                            // Info
                            Expanded(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.shopName ?? 'Shop #${widget.shopId}',
                                    style: TextStyle(
                                      fontSize: 20.sp,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  SizedBox(height: 6.h),
                                  Row(
                                    children: [
                                      Container(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 8.w,
                                          vertical: 2.h,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.2),
                                          borderRadius:
                                              BorderRadius.circular(4.r),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(Icons.verified,
                                                size: 12.sp,
                                                color: Colors.white),
                                            SizedBox(width: 4.w),
                                            Text(
                                              'Shop Uy Tín',
                                              style: TextStyle(
                                                fontSize: 11.sp,
                                                color: Colors.white,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(width: 8.w),
                                      Text(
                                        '${_products.length}+ sản phẩm',
                                        style: TextStyle(
                                          fontSize: 12.sp,
                                          color: Colors.white70,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 10.h),
                                  // Action buttons
                                  Row(
                                    children: [
                                      _buildShopActionButton(
                                        icon: Icons.chat_bubble_outline,
                                        label: 'Nhắn tin',
                                        onTap: () {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                  'Tính năng chat đang phát triển'),
                                              duration: Duration(seconds: 1),
                                            ),
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // Divider
              SliverToBoxAdapter(
                child: Container(
                  padding: EdgeInsets.all(16.w),
                  color: Colors.white,
                  child: Text(
                    'Sản phẩm của Shop',
                    style: AppTextStyles.bodyLarge.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              // Product grid
              _products.isEmpty && _isLoading
                  ? SliverFillRemaining(
                      child: Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primaryBlue,
                        ),
                      ),
                    )
                  : _products.isEmpty
                      ? SliverFillRemaining(
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.inventory_2_outlined,
                                    size: 64.sp,
                                    color: AppColors.textSecondary),
                                SizedBox(height: 12.h),
                                Text(
                                  'Shop chưa có sản phẩm nào',
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      : SliverPadding(
                          padding: EdgeInsets.all(10.w),
                          sliver: SliverGrid(
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 0.65,
                              crossAxisSpacing: 10.w,
                              mainAxisSpacing: 10.w,
                            ),
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                if (index >= _products.length) {
                                  return null;
                                }
                                final product = _products[index];
                                return _buildProductCard(
                                    product, formatCurrency);
                              },
                              childCount: _products.length,
                            ),
                          ),
                        ),

              // Loading more indicator
              if (_hasMore && _products.isNotEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(16.w),
                    child: Center(
                      child: SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildShopActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.white70),
          borderRadius: BorderRadius.circular(4.r),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14.sp, color: Colors.white),
            SizedBox(width: 6.w),
            Text(
              label,
              style: TextStyle(
                fontSize: 12.sp,
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductCard(Product product, NumberFormat formatCurrency) {
    final imageUrl = product.images.isNotEmpty
        ? product.images[0].replaceFirst('url: ', '').trim()
        : '';

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
            // Image
            Expanded(
              flex: 3,
              child: ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(8.r)),
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
                    Text(
                      'đ${formatCurrency.format(product.basePrice)}',
                      style: TextStyle(
                        color: AppColors.primaryBlue,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (product.sold != null)
                      Text(
                        'Đã bán ${product.sold}',
                        style: TextStyle(
                          fontSize: 10.sp,
                          color: AppColors.textSecondary,
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
