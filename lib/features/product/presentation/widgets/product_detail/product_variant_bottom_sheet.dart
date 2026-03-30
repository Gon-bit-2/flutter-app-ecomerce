import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:app_fe_ecomerce/core/styles/app_colors.dart';
import 'package:app_fe_ecomerce/core/common/widgets/app_network_image.dart';
import 'package:app_fe_ecomerce/features/product/domain/entities/product.dart';
import 'package:app_fe_ecomerce/features/product/domain/entities/sku.dart';
import 'product_price_info.dart';

class ProductVariantBottomSheet extends StatefulWidget {
  final Product product;
  final Map<String, String> initialSelectedVariants;
  final int initialQuantity;
  final bool isBuyNow;
  final void Function(Map<String, String> newVariants, int newQuantity, bool isBuyNow) onConfirm;

  const ProductVariantBottomSheet({
    super.key,
    required this.product,
    required this.initialSelectedVariants,
    required this.initialQuantity,
    required this.isBuyNow,
    required this.onConfirm,
  });

  @override
  State<ProductVariantBottomSheet> createState() => _ProductVariantBottomSheetState();
}

class _ProductVariantBottomSheetState extends State<ProductVariantBottomSheet> {
  late Map<String, String> _selectedVariants;
  late int _quantity;

  @override
  void initState() {
    super.initState();
    _selectedVariants = Map<String, String>.from(widget.initialSelectedVariants);
    _quantity = widget.initialQuantity;
  }

  SKU? _getSelectedSku() {
    if (widget.product.skus.isEmpty) return null;
    if (widget.product.variants == null || widget.product.variants!.isEmpty) {
      return widget.product.skus.first;
    }
    
    for (var v in widget.product.variants!) {
      if (v is Map) {
        String name = v['value'];
        List opts = v['options'] as List? ?? [];
        if (opts.isNotEmpty && !_selectedVariants.containsKey(name)) {
          return null;
        }
      }
    }
    
    List<String> orderedOptions = [];
    for (var v in widget.product.variants!) {
      if (v is Map) {
        String name = v['value'];
        List opts = v['options'] as List? ?? [];
        if (opts.isNotEmpty) {
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

  int _getMaxStock() {
    final selectedSku = _getSelectedSku();
    if (selectedSku != null) return selectedSku.stock;
    if (widget.product.skus.isEmpty) return 999;
    return widget.product.skus.fold(0, (sum, sku) => sum + sku.stock);
  }

  Widget _buildQuantityButton({
    required IconData icon,
    required VoidCallback onPressed,
    required bool isEnabled,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(4.r),
        color: isEnabled ? Colors.white : Colors.grey[100],
      ),
      child: IconButton(
        icon: Icon(
          icon,
          size: 16.sp,
          color: isEnabled ? Colors.black : Colors.grey,
        ),
        onPressed: isEnabled ? onPressed : null,
        constraints: BoxConstraints.tightFor(width: 32.w, height: 32.w),
        padding: EdgeInsets.zero,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 16.w,
        right: 16.w,
        top: 16.h,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16.h,
      ),
      height: MediaQuery.of(context).size.height * 0.8,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8.r),
                child: AppNetworkImage(
                  imageUrl: widget.product.images.isNotEmpty
                      ? widget.product.images[0].replaceFirst('url: ', '').trim()
                      : '',
                  width: 80.w,
                  height: 80.w,
                  fit: BoxFit.cover,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 20.h),
                    ProductPriceInfo(product: widget.product, selectedSku: _getSelectedSku()),
                    SizedBox(height: 4.h),
                    Text(
                      "Kho: ${widget.product.skus.fold(0, (sum, sku) => sum + sku.stock)}",
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12.sp,
                      ),
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
          const Divider(height: 32),

          // Variants List
          Expanded(
            child: ListView(
              children: [
                if (widget.product.variants != null)
                  ...widget.product.variants!.map((variant) {
                    if (variant is! Map) return const SizedBox.shrink();
                    String name = variant['value'] ?? '';
                    List options = variant['options'] as List? ?? [];

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Wrap(
                          spacing: 8.w,
                          runSpacing: 8.h,
                          children: options.map((opt) {
                            bool isSelected = _selectedVariants[name] == opt;
                            return ChoiceChip(
                              label: Text(opt.toString()),
                              selected: isSelected,
                              onSelected: (selected) {
                                setState(() {
                                  _selectedVariants[name] = opt.toString();
                                });
                              },
                              selectedColor: AppColors.secondary,
                              labelStyle: TextStyle(
                                color: isSelected ? AppColors.primaryBlue : Colors.black87,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              ),
                              backgroundColor: Colors.grey[100],
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4.r),
                                side: BorderSide(
                                  color: isSelected ? AppColors.primaryBlue : Colors.transparent,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        SizedBox(height: 16.h),
                      ],
                    );
                  }),

                // Quantity selector
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Số lượng",
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Row(
                      children: [
                        _buildQuantityButton(
                          icon: Icons.remove,
                          onPressed: () {
                            if (_quantity > 1) {
                              setState(() => _quantity--);
                            }
                          },
                          isEnabled: _quantity > 1,
                        ),
                        Container(
                          width: 40.w,
                          alignment: Alignment.center,
                          child: Text(
                            "$_quantity",
                            style: TextStyle(fontSize: 16.sp),
                          ),
                        ),
                        _buildQuantityButton(
                          icon: Icons.add,
                          onPressed: () {
                            final maxStock = _getMaxStock();
                            if (_quantity < maxStock) {
                              setState(() => _quantity++);
                            }
                          },
                          isEnabled: _quantity < _getMaxStock(),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Action Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                widget.onConfirm(_selectedVariants, _quantity, widget.isBuyNow);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                padding: EdgeInsets.symmetric(vertical: 14.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4.r),
                ),
              ),
              child: Text(
                widget.isBuyNow ? "Mua ngay" : "Thêm vào giỏ hàng",
                style: TextStyle(
                  fontSize: 16.sp,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Function helper để gọi bottom sheet
void showProductVariantBottomSheet({
  required BuildContext context,
  required Product product,
  required Map<String, String> initialSelectedVariants,
  required int initialQuantity,
  required bool isBuyNow,
  required void Function(Map<String, String>, int, bool) onConfirm,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
    ),
    builder: (_) => ProductVariantBottomSheet(
      product: product,
      initialSelectedVariants: initialSelectedVariants,
      initialQuantity: initialQuantity,
      isBuyNow: isBuyNow,
      onConfirm: onConfirm,
    ),
  );
}
