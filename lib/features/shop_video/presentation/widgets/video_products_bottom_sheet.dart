import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../../injection_container.dart';
import '../../../product/domain/repositories/product_repository.dart';
import '../../../product/domain/entities/product.dart';
import '../../../product/domain/entities/sku.dart';
import '../../../cart/presentation/bloc/cart/cart_bloc.dart';
import '../../domain/entities/product_info.dart';

/// Bottom Sheet hiển thị danh sách sản phẩm gắn trong video.
/// Thiết kế giống Shopee/TikTok Shop: Card mờ, nền tối, nút mua nổi bật.
class VideoProductsBottomSheet extends StatelessWidget {
  final List<ProductInfo> products;

  const VideoProductsBottomSheet({
    super.key,
    required this.products,
  });

  /// Hiển thị bottom sheet
  static void show(BuildContext context, List<ProductInfo> products) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => BlocProvider.value(
        value: context.read<CartBloc>(),
        child: VideoProductsBottomSheet(products: products),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.6,
          ),
          decoration: BoxDecoration(
            // DS: Nền tối mờ cho video overlay
            color: const Color(0xFF212121).withOpacity(0.92),
            borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                margin: EdgeInsets.only(top: 12.h),
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
              // Title
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                child: Row(
                  children: [
                    Icon(
                      Icons.shopping_bag_outlined,
                      color: const Color(0xFF00A8E8), // DS Primary
                      size: 20.sp,
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      'Sản phẩm trong video',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${products.length} sản phẩm',
                      style: TextStyle(
                        color: const Color(0xFF757575), // DS Text phụ
                        fontSize: 12.sp,
                      ),
                    ),
                  ],
                ),
              ),
              Divider(color: Colors.white.withOpacity(0.1), height: 1),
              // Product list
              Flexible(
                child: BlocListener<CartBloc, CartState>(
                  listener: (context, state) {
                    if (state is CartOperationSuccess) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(state.message),
                          backgroundColor: const Color(0xFF4CAF50), // DS Thành công
                          behavior: SnackBarBehavior.floating,
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    } else if (state is CartFailure) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(state.message),
                          backgroundColor: const Color(0xFFF44336), // DS Lỗi
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    } else if (state is CartUnauthenticated) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('Vui lòng đăng nhập để thêm vào giỏ hàng'),
                          backgroundColor: const Color(0xFFFF9800), // DS Cảnh báo
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  },
                  child: ListView.separated(
                    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                    shrinkWrap: true,
                    itemCount: products.length,
                    separatorBuilder: (_, __) => SizedBox(height: 12.h),
                    itemBuilder: (context, index) {
                      return _ProductListItem(product: products[index]);
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Item sản phẩm trong bottom sheet list
class _ProductListItem extends StatefulWidget {
  final ProductInfo product;

  const _ProductListItem({required this.product});

  @override
  State<_ProductListItem> createState() => _ProductListItemState();
}

class _ProductListItemState extends State<_ProductListItem> {
  bool _isLoading = false;

  void _fetchAndShowVariants() async {
    setState(() => _isLoading = true);
    try {
      final repo = getIt<ProductRepository>();
      final result = await repo.getProductById(widget.product.id);
      result.fold(
        (failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Không thể tải thông tin sản phẩm')),
          );
        },
        (productDetails) {
          _showVariantSelectionSheet(context, productDetails);
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

  void _showVariantSelectionSheet(BuildContext context, Product productDetails) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: context.read<CartBloc>(),
        child: _VariantSelectionSheet(product: productDetails),
      ),
    );
  }

  void _addToCartDirectly() {
    if (widget.product.defaultSkuId != null) {
      context.read<CartBloc>().add(
            CartItemAdded(skuId: widget.product.defaultSkuId!, quantity: 1),
          );
    } else {
      // Fallback
      _fetchAndShowVariants();
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasVariants = widget.product.hasVariants;

    return Container(
      padding: EdgeInsets.all(10.w),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Row(
        children: [
          // Thumbnail
          ClipRRect(
            borderRadius: BorderRadius.circular(8.r),
            child: CachedNetworkImage(
              imageUrl: widget.product.images.isNotEmpty
                  ? widget.product.images.first
                  : 'https://via.placeholder.com/150',
              width: 68.w,
              height: 68.w,
              fit: BoxFit.cover,
              errorWidget: (context, error, stackTrace) => Container(
                width: 68.w,
                height: 68.w,
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F7), // DS Surface
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(Icons.image_not_supported,
                    color: const Color(0xFF757575), size: 24.sp),
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
                  widget.product.name,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 6.h),
                Row(
                  children: [
                    Text(
                      'đ${_formatPrice(widget.product.basePrice)}',
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF00A8E8), // DS Primary
                      ),
                    ),
                    if (widget.product.virtualPrice != null &&
                        widget.product.virtualPrice! > widget.product.basePrice) ...[
                      SizedBox(width: 6.w),
                      Text(
                        'đ${_formatPrice(widget.product.virtualPrice!)}',
                        style: TextStyle(
                          fontSize: 11.sp,
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
          // Action buttons
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (hasVariants)
                _buildActionBtn(
                  context,
                  label: 'Chọn loại',
                  isPrimary: true,
                  isLoading: _isLoading,
                  icon: Icons.format_list_bulleted,
                  onTap: _fetchAndShowVariants,
                )
              else ...[
                _buildActionBtn(
                  context,
                  label: 'Thêm',
                  isPrimary: false,
                  icon: Icons.add_shopping_cart,
                  onTap: _addToCartDirectly,
                ),
                SizedBox(height: 6.h),
                _buildActionBtn(
                  context,
                  label: 'Mua',
                  isPrimary: true,
                  icon: Icons.flash_on,
                  onTap: () {
                    _addToCartDirectly();
                    Navigator.pop(context); // Close bottomsheet
                  },
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionBtn(
    BuildContext context, {
    required String label,
    required bool isPrimary,
    required VoidCallback onTap,
    required IconData icon,
    bool isLoading = false,
  }) {
    final colorPrimary = const Color(0xFF00A8E8);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(8.r),
        onTap: isLoading ? null : onTap,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
          width: 80.w,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isPrimary ? colorPrimary : Colors.transparent,
            border: Border.all(color: colorPrimary),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: isLoading
              ? SizedBox(
                  width: 14.sp,
                  height: 14.sp,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation(
                        isPrimary ? Colors.white : colorPrimary),
                  ),
                )
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icon, 
                        color: isPrimary ? Colors.white : colorPrimary, 
                        size: 14.sp),
                    SizedBox(width: 4.w),
                    Text(
                      label,
                      style: TextStyle(
                        color: isPrimary ? Colors.white : colorPrimary,
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
        ),
      ),
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

/// Bottom Sheet chọn phân loại (nhỏ gọn dành riêng cho feed video)
class _VariantSelectionSheet extends StatefulWidget {
  final Product product;

  const _VariantSelectionSheet({required this.product});

  @override
  State<_VariantSelectionSheet> createState() => _VariantSelectionSheetState();
}

class _VariantSelectionSheetState extends State<_VariantSelectionSheet> {
  final Map<String, String> _selectedVariants = {};
  int _quantity = 1;

  @override
  void initState() {
    super.initState();
    // Auto-select first options if none selected
    if (widget.product.variants != null) {
      for (var v in widget.product.variants!) {
        if (v is Map && v['value'] != null && v['options'] is List) {
          List opts = v['options'] as List;
          if (opts.isNotEmpty) {
            _selectedVariants[v['value']] = opts.first.toString();
          }
        }
      }
    }
  }

  SKU? _getSelectedSku() {
    if (widget.product.skus.isEmpty) return null;
    if (widget.product.variants == null || widget.product.variants!.isEmpty) {
      return widget.product.skus.first;
    }
    List<String> orderedOptions = [];
    for (var v in widget.product.variants!) {
      if (v is Map) {
        String name = v['value'];
        List opts = v['options'] as List? ?? [];
        if (opts.isNotEmpty) {
          if (!_selectedVariants.containsKey(name)) return null;
          orderedOptions.add(_selectedVariants[name]!);
        }
      }
    }
    try {
      return widget.product.skus.firstWhere((sku) {
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

  void _submit() {
    final sku = _getSelectedSku();
    if (sku == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn loại sản phẩm khả dụng')),
      );
      return;
    }
    if (sku.stock < _quantity) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sản phẩm đã hết hàng hoặc không đủ số lượng')),
      );
      return;
    }
    context.read<CartBloc>().add(
          CartItemAdded(skuId: sku.id, quantity: _quantity),
        );
    Navigator.pop(context); // Close variant sheet
  }

  @override
  Widget build(BuildContext context) {
    final selectedSku = _getSelectedSku();
    final displayPrice = selectedSku?.price ?? widget.product.basePrice;
    final maxStock = selectedSku?.stock ?? 0;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
      ),
      padding: EdgeInsets.only(
        left: 16.w,
        right: 16.w,
        top: 16.h,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16.h,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header info
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8.r),
                child: CachedNetworkImage(
                  imageUrl: widget.product.images.isNotEmpty
                      ? widget.product.images.first.replaceFirst('url: ', '').trim()
                      : '',
                  width: 80.w,
                  height: 80.w,
                  fit: BoxFit.cover,
                  errorWidget: (_, __, ___) => Container(
                    color: Colors.grey[200],
                    width: 80.w,
                    height: 80.w,
                    child: const Icon(Icons.image),
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 10.h),
                    Text(
                      'đ${displayPrice.toStringAsFixed(0)}',
                      style: TextStyle(
                        color: const Color(0xFF00A8E8),
                        fontSize: 20.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      'Kho: $maxStock',
                      style: TextStyle(color: Colors.grey[600], fontSize: 13.sp),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          Divider(height: 32.h),

          // Variants Config
          Flexible(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (widget.product.variants != null)
                    ...widget.product.variants!.map((v) {
                      if (v is! Map) return const SizedBox.shrink();
                      String name = v['value'];
                      List options = v['options'] as List? ?? [];
                      return Padding(
                        padding: EdgeInsets.only(bottom: 16.h),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(name, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp)),
                            SizedBox(height: 8.h),
                            Wrap(
                              spacing: 8.w,
                              runSpacing: 8.h,
                              children: options.map((opt) {
                                bool isSelected = _selectedVariants[name] == opt.toString();
                                return ChoiceChip(
                                  label: Text(opt.toString()),
                                  selected: isSelected,
                                  onSelected: (selected) {
                                    setState(() {
                                      _selectedVariants[name] = opt.toString();
                                    });
                                  },
                                  selectedColor: const Color(0xFFE1F5FE), // DS Light Primary
                                  backgroundColor: Colors.grey[100],
                                  labelStyle: TextStyle(
                                    color: isSelected ? const Color(0xFF00A8E8) : Colors.black87,
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8.r),
                                    side: BorderSide(color: isSelected ? const Color(0xFF00A8E8) : Colors.transparent),
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      );
                    }),
                  
                  // Quantity
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Số lượng", style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold)),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove_circle_outline),
                            onPressed: _quantity > 1 ? () => setState(() => _quantity--) : null,
                            color: _quantity > 1 ? Colors.black87 : Colors.grey,
                          ),
                          Text('$_quantity', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold)),
                          IconButton(
                            icon: const Icon(Icons.add_circle_outline),
                            onPressed: _quantity < maxStock ? () => setState(() => _quantity++) : null,
                            color: _quantity < maxStock ? Colors.black87 : Colors.grey,
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          SizedBox(height: 16.h),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: maxStock > 0 ? _submit : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00A8E8), // DS Primary
                padding: EdgeInsets.symmetric(vertical: 14.h),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
              ),
              child: Text(
                'Xác nhận vào giỏ',
                style: TextStyle(fontSize: 16.sp, color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
