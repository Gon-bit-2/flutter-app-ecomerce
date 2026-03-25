import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:ui';

import '../../../cart/presentation/bloc/cart/cart_bloc.dart';
import '../../domain/entities/product_info.dart';
import 'video_products_bottom_sheet.dart';

/// Widget hiển thị sản phẩm gắn trong video, thiết kế giống Shopee/TikTok Shop.
/// Theo Design System 5.5: Card mờ (backdrop-filter) chữ trắng,
/// hoặc nền xanh nhạt thu hút click "Mua ngay".
class VideoProductCard extends StatelessWidget {
  final ProductInfo product;
  final List<ProductInfo> allProducts;

  const VideoProductCard({
    super.key,
    required this.product,
    this.allProducts = const [],
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Nhấn vào card → mở bottom sheet danh sách sản phẩm
        final products = allProducts.isNotEmpty ? allProducts : [product];
        VideoProductsBottomSheet.show(context, products);
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12.r),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: Container(
            padding: EdgeInsets.all(10.w),
            decoration: BoxDecoration(
              // DS 5.5: Card mờ backdrop-filter, nền tối bán trong suốt
              color: const Color(0xFF212121).withOpacity(0.75),
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(
                color: Colors.white.withOpacity(0.12),
                width: 0.5,
              ),
            ),
            child: Row(
              children: [
                // Thumbnail sản phẩm
                ClipRRect(
                  borderRadius: BorderRadius.circular(8.r),
                  child: Image.network(
                    product.images.isNotEmpty
                        ? product.images.first
                        : 'https://via.placeholder.com/150',
                    width: 52.w,
                    height: 52.w,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: 52.w,
                      height: 52.w,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F5F7), // DS Surface
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Icon(Icons.image_not_supported,
                          color: const Color(0xFF757575), size: 20.sp),
                    ),
                  ),
                ),
                SizedBox(width: 10.w),
                // Thông tin sản phẩm
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        product.name,
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 4.h),
                      Row(
                        children: [
                          Text(
                            'đ${_formatPrice(product.basePrice)}',
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF00A8E8), // DS Primary
                            ),
                          ),
                          if (product.virtualPrice != null &&
                              product.virtualPrice! > product.basePrice) ...[
                            SizedBox(width: 6.w),
                            Text(
                              'đ${_formatPrice(product.virtualPrice!)}',
                              style: TextStyle(
                                fontSize: 10.sp,
                                color: const Color(0xFF757575), // DS Text phụ
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 8.w),
                // Nút thêm giỏ hàng + Mua ngay
                _buildActionButtons(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Nút thêm giỏ hàng (Outline Button - DS 4.1)
        Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(8.r),
            onTap: () => _addToCart(context),
            child: Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                border: Border.all(
                  color: const Color(0xFF00A8E8), // DS Primary viền
                  width: 1.2,
                ),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Icon(
                Icons.add_shopping_cart_rounded,
                color: const Color(0xFF00A8E8), // DS Primary
                size: 18.sp,
              ),
            ),
          ),
        ),
        SizedBox(width: 6.w),
        // Nút Mua ngay (Primary Button - DS 4.1)
        Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(8.r),
            onTap: () {
              _addToCart(context);
              // TODO: Điều hướng đến trang giỏ hàng / Checkout
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: const Color(0xFF00A8E8), // DS Primary nền
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Text(
                'Mua',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _addToCart(BuildContext context) {
    if (product.defaultSkuId != null) {
      context.read<CartBloc>().add(
            CartItemAdded(skuId: product.defaultSkuId!, quantity: 1),
          );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Vui lòng vào trang sản phẩm để chọn phân loại'),
          backgroundColor: const Color(0xFFFF9800), // DS Cảnh báo
          behavior: SnackBarBehavior.floating,
          action: SnackBarAction(
            label: 'Xem',
            textColor: Colors.white,
            onPressed: () {
              // TODO: Navigator.pushNamed(context, RouteName.productDetail, arguments: product.id);
            },
          ),
        ),
      );
    }
  }

  String _formatPrice(num price) {
    if (price >= 1000000) {
      return '${(price / 1000000).toStringAsFixed(1)}tr';
    } else if (price >= 1000) {
      return '${(price / 1000).toStringAsFixed(0)}.000';
    }
    return price.toStringAsFixed(0);
  }

  /// Badge hiển thị số sản phẩm còn lại
  static Widget buildMultiProductBadge(int count) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: const Color(0xFF00A8E8).withOpacity(0.2),
        borderRadius: BorderRadius.circular(4.r),
      ),
      child: Text(
        '+$count sản phẩm',
        style: TextStyle(
          color: const Color(0xFF00A8E8),
          fontSize: 10.sp,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
