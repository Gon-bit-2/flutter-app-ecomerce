import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/product.dart';
import '../../domain/entities/sku.dart';

import '../../domain/repositories/product_repository.dart';
import '../../../cart/presentation/pages/cart_page.dart';
import '../../../cart/presentation/bloc/cart/cart_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../injection_container.dart';
import '../../../auth/presentation/pages/login_page.dart';
import '../../../auth/presentation/bloc/auth/auth_bloc.dart';
import '../../../review/presentation/widgets/review_list_widget.dart';
import 'package:app_fe_ecomerce/features/cart/domain/entities/cart_entity.dart'
    as app_fe_ecomerce_cart;
import 'package:app_fe_ecomerce/features/order/presentation/pages/checkout_page.dart' as app_fe_ecomerce_order;
import 'package:app_fe_ecomerce/core/common/widgets/app_network_image.dart';
import 'package:app_fe_ecomerce/core/styles/app_colors.dart';

// Import extracted widgets
import '../widgets/product_detail/product_image_slider.dart';
import '../widgets/product_detail/product_price_info.dart';
import '../widgets/product_detail/product_shop_info.dart';
import '../widgets/product_detail/product_bottom_action_bar.dart';
import '../widgets/product_detail/product_variant_bottom_sheet.dart';

class ProductDetailPage extends StatefulWidget {
  final Product product;

  const ProductDetailPage({super.key, required this.product});

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  final Map<String, String> _selectedVariants = {};
  int _quantity = 1;
  bool _isBuyNow = false;
  bool _isDescriptionExpanded = false;
  List<Product> _recommendations = [];
  bool _isLoadingRecommendations = true;

  Product? _productDetails;

  Product get _currentProduct => _productDetails ?? widget.product;

  SKU? _getSelectedSku() {
    if (_currentProduct.skus.isEmpty) return null;
    if (_currentProduct.variants == null || _currentProduct.variants!.isEmpty) {
      return _currentProduct.skus.first;
    }
    for (var v in _currentProduct.variants!) {
      if (v is Map) {
        String name = v['value'];
        List opts = v['options'] as List? ?? [];
        if (opts.isNotEmpty && !_selectedVariants.containsKey(name)) {
          return null;
        }
      }
    }
    List<String> orderedOptions = [];
    for (var v in _currentProduct.variants!) {
      if (v is Map) {
        String name = v['value'];
        List opts = v['options'] as List? ?? [];
        if (opts.isNotEmpty) {
          orderedOptions.add(_selectedVariants[name]!);
        }
      }
    }
    try {
      return _currentProduct.skus.firstWhere((sku) {
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
    if (_currentProduct.skus.isEmpty) return 999;
    return _currentProduct.skus.fold(0, (sum, sku) => sum + sku.stock);
  }

  @override
  void initState() {
    super.initState();
    _fetchProductDetails();
    _fetchRecommendations();
  }

  Future<void> _fetchProductDetails() async {
    try {
      final repository = getIt<ProductRepository>();
      final result = await repository.getProductById(widget.product.id);
      result.fold((_) {}, (product) {
        if (mounted) setState(() => _productDetails = product);
      });
    } catch (_) {}
  }

  Future<void> _fetchRecommendations() async {
    try {
      final repository = getIt<ProductRepository>();
      final result = await repository.getProducts(page: 1, limit: 8);
      result.fold(
        (_) {},
        (products) {
          if (mounted) {
            setState(() {
              _recommendations = products.where((p) => p.id != widget.product.id).take(6).toList();
              _isLoadingRecommendations = false;
            });
          }
        },
      );
    } catch (_) {
      if (mounted) setState(() => _isLoadingRecommendations = false);
    }
  }

  bool get _hasInvalidData {
    return (_currentProduct.variants != null &&
        _currentProduct.variants!.isNotEmpty &&
        _currentProduct.skus.isEmpty);
  }

  int? _getSelectedSkuId() {
    if (_currentProduct.skus.isEmpty) {
      if (_currentProduct.variants == null || _currentProduct.variants!.isEmpty) {
        return -1;
      }
      return null;
    }
    if (_currentProduct.variants == null || _currentProduct.variants!.isEmpty) {
      return _currentProduct.skus.first.id;
    }
    for (var v in _currentProduct.variants!) {
      if (v is Map) {
        String name = v['value'];
        List opts = v['options'] as List? ?? [];
        if (opts.isNotEmpty) {
          if (!_selectedVariants.containsKey(name)) return null;
        }
      }
    }
    List<String> orderedOptions = [];
    for (var v in _currentProduct.variants!) {
      if (v is Map) {
        String name = v['value'];
        List opts = v['options'] as List? ?? [];
        if (opts.isNotEmpty) {
          orderedOptions.add(_selectedVariants[name]!);
        }
      }
    }
    try {
      final matchedSku = _currentProduct.skus.firstWhere((sku) {
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
      return matchedSku.id;
    } catch (_) {
      return null;
    }
  }

  void _showDebugDialog() {
    StringBuffer debugInfo = StringBuffer();
    debugInfo.writeln('=== DEBUG INFO ===\n');
    debugInfo.writeln('Selected: $_selectedVariants\n');
    debugInfo.writeln('Variants:');
    if (_currentProduct.variants != null) {
      for (var v in _currentProduct.variants!) {
        if (v is Map) debugInfo.writeln('  ${v['value']}: ${v['options']}');
      }
    }
    debugInfo.writeln('\nTotal SKUs: ${_currentProduct.skus.length}');
    if (_currentProduct.skus.isEmpty) {
      debugInfo.writeln('⚠️ KHÔNG CÓ SKU NÀO!');
    } else {
      debugInfo.writeln('SKUs:');
      for (var sku in _currentProduct.skus) {
        debugInfo.writeln('  ID ${sku.id}: "${sku.value}"');
      }
    }
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Debug Info'),
        content: SingleChildScrollView(child: Text(debugInfo.toString())),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Đóng')),
        ],
      ),
    );
  }

  void _addToCart({bool buyNow = false}) {
    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthSuccess) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginPage()));
      return;
    }
    if (_hasInvalidData) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('⚠️ Sản phẩm có lỗi dữ liệu. Vui lòng liên hệ admin!', style: TextStyle(color: Colors.white)),
          backgroundColor: AppColors.error,
          duration: Duration(seconds: 3),
        ),
      );
      _showDebugDialog();
      return;
    }
    final skuId = _getSelectedSkuId();
    if (skuId == null) {
      List<String> missingVariants = [];
      if (_currentProduct.variants != null) {
        for (var v in _currentProduct.variants!) {
          if (v is Map) {
            String name = v['value'];
            List opts = v['options'] as List? ?? [];
            if (opts.isNotEmpty && !_selectedVariants.containsKey(name)) {
              missingVariants.add(name);
            }
          }
        }
      }
      String errorMessage = missingVariants.isEmpty ? 'Vui lòng chọn đầy đủ phân loại sản phẩm' : 'Vui lòng chọn: ${missingVariants.join(", ")}';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage, style: const TextStyle(color: Colors.white)), backgroundColor: AppColors.error, duration: const Duration(seconds: 2)),
      );
      _showDebugDialog();
      return;
    }
    if (buyNow) setState(() => _isBuyNow = true);
    context.read<CartBloc>().add(CartItemAdded(skuId: skuId, quantity: _quantity));
  }

  void _onVariantAction(bool isBuyNow) {
    showProductVariantBottomSheet(
      context: context,
      product: _currentProduct,
      initialSelectedVariants: _selectedVariants,
      initialQuantity: _quantity,
      isBuyNow: isBuyNow,
      onConfirm: (variants, qty, confirmedBuyNow) {
        Navigator.pop(context);
        setState(() {
          _selectedVariants.clear();
          _selectedVariants.addAll(variants);
          _quantity = qty;
        });
        _addToCart(buyNow: confirmedBuyNow);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface, // Trắng xám làm nền để nổi các Card Trắng
      body: BlocListener<CartBloc, CartState>(
        listener: (context, state) {
          if (state is CartOperationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message, style: const TextStyle(color: Colors.white)), backgroundColor: AppColors.success, duration: const Duration(seconds: 1)),
            );
          } else if (state is CartLoaded) {
            if (_isBuyNow) {
              setState(() => _isBuyNow = false);
              final skuId = _getSelectedSkuId();
              app_fe_ecomerce_cart.CartEntity? matchingCartItem;
              if (skuId != null) {
                try {
                  matchingCartItem = state.items.firstWhere((item) => item.skuId == skuId);
                } catch (_) {}
              }
              if (matchingCartItem != null) {
                Navigator.push(context, MaterialPageRoute(builder: (_) => app_fe_ecomerce_order.CheckoutPage(
                  selectedItems: [matchingCartItem!],
                  totalPrice: (matchingCartItem.price ?? 0) * matchingCartItem.quantity,
                )));
              }
            }
          } else if (state is CartFailure) {
            setState(() => _isBuyNow = false);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message, style: const TextStyle(color: Colors.white)), backgroundColor: AppColors.error),
            );
          } else if (state is CartUnauthenticated) {
            setState(() => _isBuyNow = false);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Vui lòng đăng nhập để tiếp tục", style: TextStyle(color: Colors.white)), backgroundColor: Color(0xFFFF9800)),
            );
            Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginPage()));
          }
        },
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              Expanded(
                child: CustomScrollView(
                  slivers: [
                    SliverAppBar(
                      pinned: true,
                      floating: true,
                      backgroundColor: Colors.white,
                      elevation: 0,
                      leading: Padding(
                        padding: EdgeInsets.all(8.w),
                        child: CircleAvatar(
                          backgroundColor: Colors.black.withOpacity(0.4),
                          child: IconButton(
                            icon: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ),
                      ),
                      actions: [
                        Padding(
                          padding: EdgeInsets.all(8.w),
                          child: CircleAvatar(
                            backgroundColor: Colors.black.withOpacity(0.4),
                            child: IconButton(
                              icon: const Icon(Icons.share, color: Colors.white, size: 20),
                              onPressed: () {},
                            ),
                          ),
                        ),
                        BlocBuilder<CartBloc, CartState>(
                          builder: (context, state) {
                            int count = state is CartLoaded ? state.items.length : 0;
                            return Stack(
                              clipBehavior: Clip.none,
                              alignment: Alignment.center,
                              children: [
                                Padding(
                                  padding: EdgeInsets.all(8.w),
                                  child: CircleAvatar(
                                    backgroundColor: Colors.black.withOpacity(0.4),
                                    child: IconButton(
                                      icon: const Icon(Icons.shopping_cart_outlined, color: Colors.white, size: 20),
                                      onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CartPage())),
                                    ),
                                  ),
                                ),
                                if (count > 0)
                                  Positioned(
                                    top: 4, right: 4,
                                    child: Container(
                                      padding: EdgeInsets.all(4.w),
                                      decoration: BoxDecoration(
                                        color: AppColors.error, 
                                        shape: BoxShape.circle,
                                        border: Border.all(color: Colors.white, width: 1),
                                      ),
                                      constraints: BoxConstraints(minWidth: 18.w, minHeight: 18.w),
                                      child: Center(child: Text('$count', style: TextStyle(color: Colors.white, fontSize: 10.sp, fontWeight: FontWeight.bold))),
                                    ),
                                  ),
                              ],
                            );
                          },
                        ),
                        SizedBox(width: 8.w),
                      ],
                      expandedHeight: 350.h,
                      flexibleSpace: FlexibleSpaceBar(
                        background: ProductImageSlider(product: _currentProduct),
                      ),
                    ),
                    SliverList(
                      delegate: SliverChildListDelegate([
                        // Block 1: Thông tin cơ bản
                        Container(
                          color: Colors.white,
                          padding: EdgeInsets.all(16.w),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ProductPriceInfo(product: _currentProduct, selectedSku: _getSelectedSku()),
                              SizedBox(height: 12.h),
                              Text(
                                _currentProduct.name,
                                style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: AppColors.textPrimary, height: 1.3),
                                maxLines: 3, overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(height: 12.h),
                              _buildRatingSection(),
                            ],
                          ),
                        ),
                        SizedBox(height: 8.h),

                        // Block 2: Vận chuyển
                        Container(
                          color: Colors.white,
                          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                          child: _buildShippingSection(),
                        ),
                        SizedBox(height: 8.h),

                        // Block 3: Phân loại, số lượng
                        Container(
                          color: Colors.white,
                          padding: EdgeInsets.symmetric(horizontal: 16.w),
                          child: Column(
                            children: [
                              _buildVariantSelector(),
                              const Divider(thickness: 1, color: AppColors.border, height: 1),
                              _buildQuantitySelector(),
                            ],
                          ),
                        ),
                        SizedBox(height: 8.h),

                        // Block 4: Thông tin shop
                        Container(
                          color: Colors.white,
                          padding: EdgeInsets.symmetric(horizontal: 16.w),
                          child: ProductShopInfo(product: _currentProduct),
                        ),
                        SizedBox(height: 8.h),

                        // Block 5: Chi tiết & Mô tả
                        Container(
                          color: Colors.white,
                          padding: EdgeInsets.all(16.w),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildSpecifications(),
                              SizedBox(height: 16.h),
                              _buildDescription(),
                            ],
                          ),
                        ),
                        SizedBox(height: 8.h),

                        // Block 6: Đánh giá
                        Container(
                          color: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 16.h),
                          child: _buildReviews(),
                        ),
                        SizedBox(height: 8.h),

                        // Block 7: Gợi ý
                        Container(
                          color: Colors.white,
                          padding: EdgeInsets.all(16.w),
                          child: _buildRecommendations(),
                        ),
                        SizedBox(height: 40.h), // Spacing for Bottom Action Bar
                      ]),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomSheet: ProductBottomActionBar(
        product: _currentProduct,
        onAddToCart: () => _onVariantAction(false),
        onBuyNow: () => _onVariantAction(true),
      ),
    );
  }

  Widget _buildRatingSection() {
    return Row(
      children: [
        Icon(Icons.star, color: const Color(0xFFFFC107), size: 18.sp),
        SizedBox(width: 4.w),
        Text("${_currentProduct.rating ?? 0.0}", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp)),
        SizedBox(width: 12.w),
        Container(height: 14.h, width: 1, color: AppColors.border),
        SizedBox(width: 12.w),
        Text("${_currentProduct.sold ?? 0} Đã bán", style: TextStyle(color: AppColors.textSecondary, fontSize: 14.sp)),
        const Spacer(),
        Row(
          children: [
            Text("Xem đánh giá", style: TextStyle(color: AppColors.primaryBlue, fontSize: 13.sp, fontWeight: FontWeight.w500)),
            Icon(Icons.chevron_right, color: AppColors.primaryBlue, size: 18.sp),
          ],
        )
      ],
    );
  }

  Widget _buildShippingSection() {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(8.w),
          decoration: BoxDecoration(color: AppColors.success.withOpacity(0.1), borderRadius: BorderRadius.circular(8.r)),
          child: Icon(Icons.local_shipping_outlined, color: AppColors.success, size: 20.sp),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                    decoration: BoxDecoration(
                      color: AppColors.success.withOpacity(0.1), 
                      borderRadius: BorderRadius.circular(4.r), 
                      border: Border.all(color: AppColors.success.withOpacity(0.3))
                    ),
                    child: Text("Miễn phí", style: TextStyle(color: AppColors.success, fontSize: 10.sp, fontWeight: FontWeight.bold)),
                  ),
                  SizedBox(width: 8.w),
                  Text("Vận chuyển tiêu chuẩn", style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500, color: AppColors.textPrimary)),
                ],
              ),
              SizedBox(height: 4.h),
              Text("Nhận hàng dự kiến 3-5 ngày", style: TextStyle(color: AppColors.textSecondary, fontSize: 12.sp)),
            ],
          ),
        ),
        Icon(Icons.chevron_right, color: AppColors.textSecondary, size: 24.sp),
      ],
    );
  }

  Widget _buildVariantSelector() {
    if (_currentProduct.variants == null || _currentProduct.variants!.isEmpty) {
      return const SizedBox.shrink();
    }
    String summary = "Chọn phân loại";
    if (_selectedVariants.isNotEmpty) {
      summary = _selectedVariants.values.join(", ");
    }
    return InkWell(
      onTap: () => _onVariantAction(false),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 16.h),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Phân loại", style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
            Row(
              children: [
                Text(summary, style: TextStyle(color: _selectedVariants.isEmpty ? AppColors.textSecondary : AppColors.primaryBlue, fontSize: 14.sp, fontWeight: _selectedVariants.isEmpty ? FontWeight.normal : FontWeight.w500)),
                SizedBox(width: 8.w),
                Icon(Icons.chevron_right, color: AppColors.textSecondary, size: 20.sp),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuantitySelector() {
    final maxStock = _getMaxStock();
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 16.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Text("Số lượng", style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
              SizedBox(width: 8.w),
              Text("(Còn $maxStock)", style: TextStyle(fontSize: 12.sp, color: AppColors.textSecondary)),
            ],
          ),
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.border),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Row(
              children: [
                _buildQuantityButton(
                  icon: Icons.remove,
                  onPressed: () { if (_quantity > 1) setState(() => _quantity--); },
                  isEnabled: _quantity > 1,
                ),
                Container(
                  width: 40.w,
                  alignment: Alignment.center,
                  child: Text("$_quantity", style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold)),
                ),
                _buildQuantityButton(
                  icon: Icons.add,
                  onPressed: () { if (_quantity < maxStock) setState(() => _quantity++); },
                  isEnabled: _quantity < maxStock,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuantityButton({required IconData icon, required VoidCallback onPressed, required bool isEnabled}) {
    return InkWell(
      onTap: isEnabled ? onPressed : null,
      borderRadius: BorderRadius.circular(8.r),
      child: Container(
        padding: EdgeInsets.all(8.w),
        decoration: BoxDecoration(
          color: isEnabled ? Colors.white : AppColors.surface,
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Icon(icon, size: 18.sp, color: isEnabled ? AppColors.textPrimary : AppColors.textSecondary),
      ),
    );
  }

  Widget _buildSpecifications() {
    final specs = <MapEntry<String, String>>[];
    specs.add(MapEntry('Thương hiệu', 'ID: ${_currentProduct.brandId}'));
    if (_currentProduct.skus.isNotEmpty) {
      specs.add(MapEntry('Phân loại', '${_currentProduct.skus.length} loại'));
    }
    if (_currentProduct.skus.length > 1) {
      final formatCurrency = NumberFormat("#,##0", "vi_VN");
      final prices = _currentProduct.skus.map((s) => s.price).toList()..sort();
      specs.add(MapEntry('Khoảng giá', 'đ${formatCurrency.format(prices.first)} - đ${formatCurrency.format(prices.last)}'));
    }
    final totalStock = _currentProduct.skus.fold(0, (sum, sku) => sum + sku.stock);
    specs.add(MapEntry('Kho hàng', '$totalStock sản phẩm'));

    if (_currentProduct.variants != null) {
      for (var v in _currentProduct.variants!) {
        if (v is Map && v['value'] != null && v['options'] is List) {
          final options = (v['options'] as List);
          specs.add(MapEntry(v['value'], options.join(', ')));
        }
      }
    }
    if (specs.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Chi tiết sản phẩm", style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
        SizedBox(height: 16.h),
        ...specs.map((entry) => Padding(
          padding: EdgeInsets.only(bottom: 12.h),
          child: Row(
            children: [
              SizedBox(width: 120.w, child: Text(entry.key, style: TextStyle(color: AppColors.textSecondary, fontSize: 14.sp))),
              Expanded(child: Text(entry.value, style: TextStyle(fontSize: 14.sp, color: AppColors.textPrimary, fontWeight: FontWeight.w500))),
            ],
          ),
        )),
      ],
    );
  }

  Widget _buildDescription() {
    final description = _currentProduct.description ?? "Chưa có mô tả.";
    final isLong = description.length > 200;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(thickness: 1, color: AppColors.border, height: 32),
        Text("Mô tả sản phẩm", style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
        SizedBox(height: 12.h),
        AnimatedCrossFade(
          firstChild: Text(description, style: TextStyle(fontSize: 15.sp, color: AppColors.textPrimary, height: 1.6), maxLines: 5, overflow: TextOverflow.ellipsis),
          secondChild: Text(description, style: TextStyle(fontSize: 15.sp, color: AppColors.textPrimary, height: 1.6)),
          crossFadeState: _isDescriptionExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 300),
        ),
        if (isLong) ...[
          SizedBox(height: 16.h),
          Center(
            child: OutlinedButton.icon(
              onPressed: () => setState(() => _isDescriptionExpanded = !_isDescriptionExpanded),
              icon: Icon(_isDescriptionExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down, size: 18.sp, color: AppColors.primaryBlue),
              label: Text(_isDescriptionExpanded ? "Thu gọn" : "Xem thêm", style: TextStyle(color: AppColors.primaryBlue)),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: AppColors.primaryBlue.withOpacity(0.5)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 8.h),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildReviews() {
    return Padding(padding: EdgeInsets.symmetric(horizontal: 16.w), child: ReviewListWidget(productId: widget.product.id));
  }

  Widget _buildRecommendations() {
    final formatCurrency = NumberFormat("#,##0", "vi_VN");
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Gợi ý cho bạn", style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
        SizedBox(height: 16.h),
        if (_isLoadingRecommendations)
          SizedBox(height: 220.h, child: const Center(child: CircularProgressIndicator(color: AppColors.primaryBlue)))
        else if (_recommendations.isEmpty)
          SizedBox(height: 100.h, child: Center(child: Text('Chưa có sản phẩm gợi ý', style: TextStyle(color: AppColors.textSecondary, fontSize: 14.sp))))
        else
          SizedBox(
            height: 240.h,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: _recommendations.length,
              separatorBuilder: (c, i) => SizedBox(width: 12.w),
              itemBuilder: (c, i) {
                final product = _recommendations[i];
                final imageUrl = product.images.isNotEmpty ? product.images[0].replaceFirst('url: ', '').trim() : '';
                return GestureDetector(
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ProductDetailPage(product: product))),
                  child: Container(
                    width: 150.w,
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12.r), border: Border.all(color: AppColors.border), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 4, offset: const Offset(0, 2))]),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.vertical(top: Radius.circular(12.r)),
                          child: imageUrl.isNotEmpty
                              ? AppNetworkImage(imageUrl: imageUrl, height: 140.h, width: 150.w, fit: BoxFit.cover)
                              : Container(height: 140.h, color: AppColors.surface, child: const Center(child: Icon(Icons.image_outlined, color: Colors.grey))),
                        ),
                        Padding(
                          padding: EdgeInsets.all(10.w),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(product.name, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 13.sp, color: AppColors.textPrimary, height: 1.3)),
                              SizedBox(height: 8.h),
                              Text('đ${formatCurrency.format(product.basePrice)}', style: TextStyle(color: AppColors.primaryBlue, fontSize: 15.sp, fontWeight: FontWeight.bold)),
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
    );
  }
}
