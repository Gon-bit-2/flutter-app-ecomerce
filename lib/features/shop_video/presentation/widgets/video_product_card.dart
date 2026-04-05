import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:ui';

import '../../../../injection_container.dart';
import '../../../cart/presentation/bloc/cart/cart_bloc.dart';
import '../../../product/domain/repositories/product_repository.dart';
import '../../../product/presentation/widgets/product_detail/product_variant_bottom_sheet.dart';
import '../../domain/entities/product_info.dart';
import 'video_products_bottom_sheet.dart';

/// Widget hiển thị sản phẩm gắn trong video, thiết kế giống Shopee/TikTok Shop.
/// Theo Design System 5.5: Card mờ (backdrop-filter) chữ trắng,
/// hoặc nền xanh nhạt thu hút click "Mua ngay".
class VideoProductCard extends StatefulWidget {
  final ProductInfo product;
  final List<ProductInfo> allProducts;

  const VideoProductCard({
    super.key,
    required this.product,
    this.allProducts = const [],
  });

  @override
  State<VideoProductCard> createState() => _VideoProductCardState();
}

class _VideoProductCardState extends State<VideoProductCard> {
  bool _isLoading = false;
  
  void _fetchAndShowVariants(bool isBuyNow) async {
    setState(() => _isLoading = true);
    try {
      final repo = getIt<ProductRepository>();
      final result = await repo.getProductById(widget.product.id);
      if (!mounted) return;
      
      result.fold(
        (failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Không thể tải thông tin sản phẩm')),
          );
        },
        (productDetails) {
          showProductVariantBottomSheet(
            context: context,
            product: productDetails,
            initialSelectedVariants: const {},
            initialQuantity: 1,
            isBuyNow: isBuyNow,
            onConfirm: (variants, quantity, buyNow) {
              final sku = _getSelectedSku(productDetails, variants);
              if (sku != null) {
                context.read<CartBloc>().add(
                  CartItemAdded(skuId: sku.id, quantity: quantity),
                );
                Navigator.pop(context);
                if (buyNow) {
                  // TODO: Navigate to checkout / cart
                }
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Vui lòng chọn phân loại hợp lệ')),
                );
              }
            },
          );
        },
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Có lỗi xảy ra')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  dynamic _getSelectedSku(dynamic product, Map<String, String> selectedVariants) {
    if (product.skus.isEmpty) return null;
    if (product.variants == null || product.variants!.isEmpty) {
      return product.skus.first;
    }
    List<String> orderedOptions = [];
    for (var v in product.variants!) {
      if (v is Map) {
        String name = v['value'];
        List opts = v['options'] as List? ?? [];
        if (opts.isNotEmpty) {
          if (!selectedVariants.containsKey(name)) return null;
          orderedOptions.add(selectedVariants[name]!);
        }
      }
    }
    try {
      return product.skus.firstWhere((sku) {
        List<String> skuOptions;
        if (sku.value.contains(',')) {
          skuOptions = sku.value.split(',').map((e) => e.trim()).toList();
        } else if (sku.value.contains('-')) {
          skuOptions = sku.value.split('-').map((e) => e.trim()).toList();
        } else {
          skuOptions = [sku.value.trim()];
        }
        if (skuOptions.length != orderedOptions.length) return false;
        for (var opt in orderedOptions) {
          if (!skuOptions.contains(opt.trim())) return false;
        }
        return true;
      });
    } catch (_) {
      return null;
    }
  }

  void _handleAction(bool isBuyNow) {
    if (widget.product.hasVariants) {
      _fetchAndShowVariants(isBuyNow);
    } else {
      if (widget.product.defaultSkuId != null) {
        context.read<CartBloc>().add(
          CartItemAdded(skuId: widget.product.defaultSkuId!, quantity: 1),
        );
        if (isBuyNow) {
           // TODO: Điều hướng đến trang giỏ hàng / Checkout
        }
      } else {
         _fetchAndShowVariants(isBuyNow);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Nhấn vào card → mở bottom sheet danh sách sản phẩm
        final products = widget.allProducts.isNotEmpty ? widget.allProducts : [widget.product];
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
                    widget.product.images.isNotEmpty
                        ? widget.product.images.first
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
                        widget.product.name,
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
                          Flexible(
                            child: Text(
                              'đ${_formatPrice(widget.product.basePrice)}',
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF00A8E8), // DS Primary
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (widget.product.virtualPrice != null &&
                              widget.product.virtualPrice! > widget.product.basePrice) ...[
                            SizedBox(width: 6.w),
                            Flexible(
                              child: Text(
                                'đ${_formatPrice(widget.product.virtualPrice!)}',
                                style: TextStyle(
                                  fontSize: 10.sp,
                                  color: const Color(0xFF757575), // DS Text phụ
                                  decoration: TextDecoration.lineThrough,
                                ),
                                overflow: TextOverflow.ellipsis,
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
    if (_isLoading) {
      return Padding(
        padding: EdgeInsets.only(right: 8.w),
        child: SizedBox(
          width: 24.w,
          height: 24.w,
          child: const CircularProgressIndicator(
            strokeWidth: 2,
            color: Color(0xFF00A8E8),
          ),
        ),
      );
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Nút thêm giỏ hàng (Outline Button - DS 4.1)
        Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(8.r),
            onTap: () => _handleAction(false),
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
            onTap: () => _handleAction(true),
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

  String _formatPrice(num price) {
    if (price >= 1000000) {
      return '${(price / 1000000).toStringAsFixed(1)}tr';
    } else if (price >= 1000) {
      return '${(price / 1000).toStringAsFixed(0)}.000';
    }
    return price.toStringAsFixed(0);
  }

}
