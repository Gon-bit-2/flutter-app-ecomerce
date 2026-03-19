import 'package:cached_network_image/cached_network_image.dart';
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
import 'package:app_fe_ecomerce/features/order/presentation/pages/checkout_page.dart'
    as app_fe_ecomerce_order;

class ProductDetailPage extends StatefulWidget {
  final Product product;

  const ProductDetailPage({super.key, required this.product});

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  int _currentImageIndex = 0;
  // Map to store selected options for each variant type. Key: Variant Name (e.g. "Color"), Value: Selected Option (e.g. "Red")
  final Map<String, String> _selectedVariants = {};
  int _quantity = 1;
  bool _isBuyNow = false;
  bool _isDescriptionExpanded = false;
  List<Product> _recommendations = [];
  bool _isLoadingRecommendations = true;

  // State for fetching full product details
  Product? _productDetails;

  // Calculate price to show. Range if multiple SKUs, or single price.
  // For now, simple logic.

  // Use product details if available, otherwise use the passed product
  Product get _currentProduct => _productDetails ?? widget.product;

  /// Lấy SKU tương ứng với variant đã chọn
  SKU? _getSelectedSku() {
    if (_currentProduct.skus.isEmpty) return null;
    if (_currentProduct.variants == null || _currentProduct.variants!.isEmpty) {
      return _currentProduct.skus.first;
    }
    // Kiểm tra đã chọn đủ variant chưa
    for (var v in _currentProduct.variants!) {
      if (v is Map) {
        String name = v['value'];
        List opts = v['options'] as List? ?? [];
        if (opts.isNotEmpty && !_selectedVariants.containsKey(name)) {
          return null;
        }
      }
    }
    // Ghép theo thứ tự các variant
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

  /// Lấy stock tối đa cho quantity validation
  int _getMaxStock() {
    final selectedSku = _getSelectedSku();
    if (selectedSku != null) return selectedSku.stock;
    // Nếu chưa chọn variant, lấy tổng stock
    if (_currentProduct.skus.isEmpty) return 999;
    return _currentProduct.skus.fold(0, (sum, sku) => sum + sku.stock);
  }

  @override
  void initState() {
    super.initState();
    _fetchProductDetails();
    _fetchRecommendations();
    // Pre-select first options if available? Or leave empty.
    if (widget.product.variants != null) {
      for (var v in widget.product.variants!) {
        if (v is Map &&
            v['value'] != null &&
            v['options'] is List &&
            (v['options'] as List).isNotEmpty) {
          // _selectedVariants[v['value']] = v['options'][0]; // Auto-select first?
        }
      }
    }
  }

  Future<void> _fetchProductDetails() async {
    try {
      final repository = getIt<ProductRepository>();
      final result = await repository.getProductById(widget.product.id);

      result.fold(
        (failure) {
          // Xử lý lỗi nếu cần thiết
        },
        (product) {
          setState(() {
            _productDetails = product;
          });
        },
      );
    } catch (e) {
      // Xử lý exception nếu cần thiết
    }
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
              _recommendations = products
                  .where((p) => p.id != widget.product.id)
                  .take(6)
                  .toList();
              _isLoadingRecommendations = false;
            });
          }
        },
      );
    } catch (_) {
      if (mounted) {
        setState(() => _isLoadingRecommendations = false);
      }
    }
  }

  bool get _hasInvalidData {
    // Kiểm tra xem có variants nhưng không có SKUs không (data lỗi)
    return (_currentProduct.variants != null &&
        _currentProduct.variants!.isNotEmpty &&
        _currentProduct.skus.isEmpty);
  }

  int? _getSelectedSkuId() {
    // Nếu không có SKUs và không có variants, có thể mua trực tiếp (không cần SKU)
    if (_currentProduct.skus.isEmpty) {
      if (_currentProduct.variants == null ||
          _currentProduct.variants!.isEmpty) {
        // Không có variants, không cần SKU - có thể là sản phẩm đơn giản
        return -1; // Dùng -1 để báo hiệu không cần SKU
      }
      // Có variants nhưng không có SKUs - dữ liệu lỗi!
      return null;
    }
    if (_currentProduct.variants == null || _currentProduct.variants!.isEmpty) {
      return _currentProduct.skus.first.id;
    }

    print('DEBUG: === Starting SKU selection ===');
    print('DEBUG: Total variants: ${_currentProduct.variants!.length}');

    // Kiểm tra xem đã chọn đủ các thuộc tính chưa
    for (var v in _currentProduct.variants!) {
      if (v is Map) {
        String name = v['value'];
        List opts = v['options'] as List? ?? [];
        print('DEBUG: Variant "$name" has ${opts.length} options: $opts');
        // Nếu variant này không có option nào thì bỏ qua
        if (opts.isNotEmpty) {
          if (!_selectedVariants.containsKey(name)) {
            print('DEBUG: Thiếu thuộc tính: $name');
            return null;
          }
        }
      }
    }

    // Ghép theo thứ tự các variant (chỉ lấy những cái có options)
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

    print('DEBUG: User selected options in order: $orderedOptions');
    print('DEBUG: Available SKUs:');
    for (var sku in _currentProduct.skus) {
      print('  SKU ID ${sku.id}: "${sku.value}"');
    }

    try {
      final matchedSku = _currentProduct.skus.firstWhere((sku) {
        // SKU value can be in format: "Đen-S" (hyphen) or "Đen, S" (comma)
        // Try comma first, then hyphen
        List<String> skuOptions;
        if (sku.value.contains(',')) {
          skuOptions = sku.value.split(',').map((e) => e.trim()).toList();
        } else if (sku.value.contains('-')) {
          skuOptions = sku.value.split('-').map((e) => e.trim()).toList();
        } else {
          // Single value, no separator
          skuOptions = [sku.value.trim()];
        }

        print(
          'DEBUG: Checking SKU ${sku.id} with options: $skuOptions (count: ${skuOptions.length})',
        );

        // Nếu số lượng option không khớp thì chắc chắn sai
        if (skuOptions.length != orderedOptions.length) {
          print(
            '  -> Length mismatch: ${skuOptions.length} != ${orderedOptions.length}',
          );
          return false;
        }

        // Kiểm tra xem tất cả các lựa chọn của user có nằm trong skuOptions không
        for (var opt in orderedOptions) {
          if (!skuOptions.contains(opt.trim())) {
            print('  -> Missing option: "$opt" not in $skuOptions');
            return false; // Thiếu 1 option
          }
        }
        print('  -> MATCHED!');
        return true; // Khớp tất cả
      });
      print('DEBUG: Final matched SKU ID: ${matchedSku.id}');
      return matchedSku.id;
    } catch (e) {
      print('DEBUG: ERROR - Could not find matching SKU!');
      print('DEBUG: Searched for: $orderedOptions');
      print(
        'DEBUG: Available SKUs: ${_currentProduct.skus.map((e) => '${e.id}:"${e.value}"').toList()}',
      );
      return null;
    }
  }

  void _showDebugDialog() {
    // Thu thập thông tin debug
    StringBuffer debugInfo = StringBuffer();
    debugInfo.writeln('=== DEBUG INFO ===\n');
    debugInfo.writeln('Selected: $_selectedVariants\n');
    debugInfo.writeln('Variants:');
    if (_currentProduct.variants != null) {
      for (var v in _currentProduct.variants!) {
        if (v is Map) {
          debugInfo.writeln('  ${v['value']}: ${v['options']}');
        }
      }
    }
    debugInfo.writeln('\nTotal SKUs: ${_currentProduct.skus.length}');
    if (_currentProduct.skus.isEmpty) {
      debugInfo.writeln('⚠️ KHÔNG CÓ SKU NÀO!');
      debugInfo.writeln('Sản phẩm này chưa có SKUs trong database.');
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
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }

  void _addToCart({bool buyNow = false}) {
    // 1. Kiểm tra session/token trước
    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthSuccess) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
      );
      return;
    }

    // 2. Kiểm tra lỗi data trước
    if (_hasInvalidData) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            '⚠️ Sản phẩm có lỗi dữ liệu. Vui lòng liên hệ admin!',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 3),
        ),
      );
      _showDebugDialog();
      return;
    }

    final skuId = _getSelectedSkuId();
    print('DEBUG: Selected variants: $_selectedVariants');
    print('DEBUG: SKU ID found: $skuId');
    if (skuId == null) {
      // Kiểm tra xem variant nào chưa được chọn
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

      String errorMessage = missingVariants.isEmpty
          ? 'Vui lòng chọn đầy đủ phân loại sản phẩm'
          : 'Vui lòng chọn: ${missingVariants.join(", ")}';

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            errorMessage,
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 2),
        ),
      );

      // Hiển thị debug dialog
      _showDebugDialog();
      return;
    }

    if (buyNow) {
      setState(() {
        _isBuyNow = true;
      });
    }

    context.read<CartBloc>().add(
      CartItemAdded(skuId: skuId, quantity: _quantity),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: BlocListener<CartBloc, CartState>(
        listener: (context, state) {
          if (state is CartOperationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  state.message,
                  style: const TextStyle(color: Colors.white),
                ),
                backgroundColor: Colors.green,
                duration: const Duration(seconds: 1),
              ),
            );
          } else if (state is CartLoaded) {
            if (_isBuyNow) {
              setState(() {
                _isBuyNow = false;
              });

              // Lấy skuId hiện tại
              final skuId = _getSelectedSkuId();

              // Tìm cart item tương ứng
              app_fe_ecomerce_cart.CartEntity? matchingCartItem;
              if (skuId != null) {
                try {
                  matchingCartItem = state.items.firstWhere(
                    (item) => item.skuId == skuId,
                  );
                } catch (_) {}
              }

              if (matchingCartItem != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => app_fe_ecomerce_order.CheckoutPage(
                      selectedItems: [matchingCartItem!],
                      totalPrice: (matchingCartItem.price ?? 0) * matchingCartItem.quantity,
                    ),
                  ),
                );
              }
            }
          } else if (state is CartFailure) {
            setState(() {
              _isBuyNow = false;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  state.message,
                  style: const TextStyle(color: Colors.white),
                ),
                backgroundColor: Colors.red,
              ),
            );
          } else if (state is CartUnauthenticated) {
            setState(() {
              _isBuyNow = false;
            });
            // Show toast first, then navigate
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  "Vui lòng đăng nhập để tiếp tục",
                  style: TextStyle(color: Colors.white),
                ),
                backgroundColor: Colors.orange,
              ),
            );
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const LoginPage()),
            );
          }
        },
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: CustomScrollView(
                  slivers: [
                    // App Bar (Floating over image usually, but here sticky or standard)
                    SliverAppBar(
                      pinned: true,
                      floating: true,
                      backgroundColor: Colors
                          .transparent, // Make it transparent initially? Or white.
                      // For a product detail, usually we have a translucent back button.
                      // Let's stick to standard white app bar for simplicity or "glassmorphism" overlay?
                      // The image suggests a standard header with Back, Share, Cart.
                      leading: IconButton(
                        icon: const CircleAvatar(
                          backgroundColor: Colors.black26,
                          child: Icon(Icons.arrow_back, color: Colors.white),
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                      actions: [
                        IconButton(
                          icon: const CircleAvatar(
                            backgroundColor: Colors.black26,
                            child: Icon(Icons.share, color: Colors.white),
                          ),
                          onPressed: () {},
                        ),
                        BlocBuilder<CartBloc, CartState>(
                          builder: (context, state) {
                            int count = 0;
                            if (state is CartLoaded) count = state.items.length;
                            return Stack(
                              clipBehavior: Clip.none,
                              children: [
                                IconButton(
                                  icon: const CircleAvatar(
                                    backgroundColor: Colors.black26,
                                    child: Icon(
                                      Icons.shopping_cart,
                                      color: Colors.white,
                                    ),
                                  ),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => const CartPage(),
                                      ),
                                    );
                                  },
                                ),
                                if (count > 0)
                                  Positioned(
                                    top: 5,
                                    right: 5,
                                    child: Container(
                                      padding: EdgeInsets.all(4.w),
                                      decoration: const BoxDecoration(
                                        color: Colors.red,
                                        shape: BoxShape.circle,
                                      ),
                                      constraints: BoxConstraints(
                                        minWidth: 16.w,
                                        minHeight: 16.w,
                                      ),
                                      child: Center(
                                        child: Text(
                                          '$count',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 10.sp,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            );
                          },
                        ),
                        SizedBox(width: 8.w),
                      ],
                      expandedHeight: 300.h,
                      flexibleSpace: FlexibleSpaceBar(
                        background: _buildImageSlider(),
                      ),
                    ),

                    SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.all(16.w),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildPriceSection(),
                            SizedBox(height: 8.h),
                            Text(
                              _currentProduct.name,
                              style: TextStyle(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: 8.h),
                            _buildRatingSection(),
                            SizedBox(height: 16.h),
                            const Divider(
                              thickness: 1,
                              color: Color(0xFFEEEEEE),
                            ),
                            _buildShippingSection(),
                            const Divider(
                              thickness: 1,
                              color: Color(0xFFEEEEEE),
                            ),
                            _buildVariantSelector(),
                            const Divider(
                              thickness: 1,
                              color: Color(0xFFEEEEEE),
                            ),
                            _buildQuantitySelector(),
                            const Divider(
                              thickness: 1,
                              color: Color(0xFFEEEEEE),
                            ),
                            _buildSpecifications(),
                            const Divider(
                              thickness: 1,
                              color: Color(0xFFEEEEEE),
                            ),
                            _buildDescription(),
                            const Divider(
                              thickness: 1,
                              color: Color(0xFFEEEEEE),
                            ),
                            _buildReviews(),
                            SizedBox(height: 20.h),
                            _buildRecommendations(),
                            SizedBox(height: 80.h), // Spacing for bottom bar
                          ],
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
      bottomSheet: _buildBottomBar(),
    );
  }

  Widget _buildImageSlider() {
    return Stack(
      children: [
        PageView.builder(
          physics: const ClampingScrollPhysics(),
          onPageChanged: (index) {
            setState(() {
              _currentImageIndex = index;
            });
          },
          itemCount: _currentProduct.images.isNotEmpty
              ? _currentProduct.images.length
              : 1,
          itemBuilder: (context, index) {
            final images = _currentProduct.images;
            if (images.isEmpty || images[index].isEmpty) {
              return Container(
                color: Colors.grey[200],
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.image, size: 50, color: Colors.grey),
                      SizedBox(height: 8.h),
                      Text(
                        "Không có ảnh\nLength: ${images.length}",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 12.sp, color: Colors.red),
                      ),
                    ],
                  ),
                ),
              );
            }
            final rawUrl = images[index];
            final url = rawUrl.startsWith('url: ')
                ? rawUrl.replaceFirst('url: ', '').trim()
                : rawUrl;
            return SizedBox.expand(
              child: CachedNetworkImage(
                imageUrl: url,
                fit: BoxFit.contain,
                width: double.infinity,
                height: double.infinity,
                errorWidget: (context, url, error) => Container(
                  color: Colors.grey[200],
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.broken_image,
                          size: 50,
                          color: Colors.red,
                        ),
                        SizedBox(height: 8.h),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8.w),
                          child: Text(
                            "Lỗi tải ảnh: $error\nURL: $url",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 10.sp,
                              color: Colors.black,
                            ),
                            maxLines: 4,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                placeholder: (_, __) =>
                    const Center(child: CircularProgressIndicator()),
              ),
            );
          },
        ),
        Positioned(
          bottom: 16.h,
          right: 16.w,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: Colors.black45,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Text(
              "${_currentImageIndex + 1}/${_currentProduct.images.length}",
              style: TextStyle(color: Colors.white, fontSize: 12.sp),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPriceSection() {
    final formatCurrency = NumberFormat("#,##0", "vi_VN");
    
    // Ưu tiên giá SKU đã chọn, fallback về giá base
    final selectedSku = _getSelectedSku();
    final displayPrice = selectedSku?.price ?? _currentProduct.basePrice;
    final originalPrice = _currentProduct.virtualPrice;
    
    double discount = 0;
    if (originalPrice != null && originalPrice > displayPrice) {
      discount = ((originalPrice - displayPrice) / originalPrice) * 100;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              'đ${formatCurrency.format(displayPrice)}',
              style: TextStyle(
                color: const Color(0xFFEE4D2D),
                fontSize: 24.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (originalPrice != null && originalPrice > displayPrice) ...[
              SizedBox(width: 8.w),
              Text(
                'đ${formatCurrency.format(originalPrice)}',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 14.sp,
                  decoration: TextDecoration.lineThrough,
                ),
              ),
              SizedBox(width: 8.w),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFEAE6),
                  borderRadius: BorderRadius.circular(2.r),
                ),
                child: Text(
                  "-${discount.toStringAsFixed(0)}%",
                  style: TextStyle(
                    color: const Color(0xFFEE4D2D),
                    fontSize: 10.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
        // Hiển thị stock SKU đã chọn
        if (selectedSku != null) ...[
          SizedBox(height: 4.h),
          Text(
            selectedSku.stock > 0
                ? 'Còn ${selectedSku.stock} sản phẩm'
                : 'Hết hàng',
            style: TextStyle(
              color: selectedSku.stock > 0 ? Colors.grey[600] : Colors.red,
              fontSize: 12.sp,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildRatingSection() {
    return Row(
      children: [
        Icon(Icons.star, color: Colors.amber, size: 16.sp),
        SizedBox(width: 4.w),
        Text(
          "${_currentProduct.rating ?? 4.9}",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp),
        ),
        SizedBox(width: 8.w),
        Container(height: 12.h, width: 1, color: Colors.grey),
        SizedBox(width: 8.w),
        Text(
          "${_currentProduct.sold ?? 100} Đã bán",
          style: TextStyle(color: Colors.grey[600], fontSize: 14.sp),
        ),
        const Spacer(),
        Text(
          "Xem tất cả đánh giá >",
          style: TextStyle(
            color: Theme.of(context).primaryColor,
            fontSize: 14.sp,
          ),
        ),
      ],
    );
  }

  Widget _buildShippingSection() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(6.w),
            decoration: BoxDecoration(
              color: Colors.green[50],
              borderRadius: BorderRadius.circular(4.r),
            ),
            child: Icon(
              Icons.local_shipping_outlined,
              color: Colors.green[700],
              size: 18.sp,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
                      decoration: BoxDecoration(
                        color: Colors.green[50],
                        borderRadius: BorderRadius.circular(2.r),
                        border: Border.all(color: Colors.green[300]!),
                      ),
                      child: Text(
                        "Miễn phí",
                        style: TextStyle(
                          color: Colors.green[700],
                          fontSize: 10.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(width: 6.w),
                    Text(
                      "Vận chuyển tiêu chuẩn",
                      style: TextStyle(fontSize: 13.sp),
                    ),
                  ],
                ),
                SizedBox(height: 2.h),
                Text(
                  "Nhận hàng dự kiến 3-5 ngày",
                  style: TextStyle(color: Colors.grey[500], fontSize: 11.sp),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right, color: Colors.grey[400], size: 20.sp),
        ],
      ),
    );
  }

  Widget _buildVariantSelector() {
    if (_currentProduct.variants == null || _currentProduct.variants!.isEmpty) {
      return const SizedBox.shrink();
    }

    // Tóm tắt lựa chọn hiện tại nếu có
    String summary = "Chọn phân loại";
    if (_selectedVariants.isNotEmpty) {
      summary = _selectedVariants.values.join(", ");
    }

    return InkWell(
      onTap: () => _showVariantBottomSheet(buyNow: false),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 12.h),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Phân loại",
              style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
            ),
            Row(
              children: [
                Text(
                  summary,
                  style: TextStyle(color: Colors.grey[600], fontSize: 14.sp),
                ),
                SizedBox(width: 8.w),
                Icon(Icons.chevron_right, color: Colors.grey[600]),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showVariantBottomSheet({required bool buyNow}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
      ),
      builder: (BottomSheetContext) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Container(
              padding: EdgeInsets.only(
                left: 16.w,
                right: 16.w,
                top: 16.h,
                bottom: MediaQuery.of(context).viewInsets.bottom + 16.h,
              ),
              height:
                  MediaQuery.of(context).size.height *
                  0.8, // Increased height to prevent overflow
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product info header
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8.r),
                        child: CachedNetworkImage(
                          imageUrl: _currentProduct.images.isNotEmpty
                              ? _currentProduct.images[0]
                                    .replaceFirst('url: ', '')
                                    .trim()
                              : '',
                          width: 80.w,
                          height: 80.w,
                          fit: BoxFit.cover,
                          errorWidget: (context, url, err) => Container(
                            color: Colors.grey[200],
                            child: const Icon(Icons.image),
                          ),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 20.h),
                            _buildPriceSection(),
                            SizedBox(height: 4.h),
                            Text(
                              "Kho: ${_currentProduct.skus.fold(0, (sum, sku) => sum + sku.stock)}",
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
                        if (_currentProduct.variants != null)
                          ..._currentProduct.variants!.map((variant) {
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
                                    bool isSelected =
                                        _selectedVariants[name] == opt;
                                    return ChoiceChip(
                                      label: Text(opt.toString()),
                                      selected: isSelected,
                                      onSelected: (selected) {
                                        setModalState(() {
                                          _selectedVariants[name] = opt
                                              .toString();
                                        });
                                        // Đồng bộ với page widget chính
                                        setState(() {});
                                      },
                                      selectedColor: const Color(
                                        0xFFFFEAE6,
                                      ), // Cam nhạt
                                      labelStyle: TextStyle(
                                        color: isSelected
                                            ? const Color(0xFFEE4D2D)
                                            : Colors.black87,
                                        fontWeight: isSelected
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                      ),
                                      backgroundColor: Colors.grey[100],
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                          4.r,
                                        ),
                                        side: BorderSide(
                                          color: isSelected
                                              ? const Color(0xFFEE4D2D)
                                              : Colors.transparent,
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
                                      setModalState(() => _quantity--);
                                      setState(() {});
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
                                      setModalState(() => _quantity++);
                                      setState(() {});
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
                        Navigator.pop(context);
                        _addToCart(buyNow: buyNow);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(
                          0xFFEE4D2D,
                        ), // Shopee orange
                        padding: EdgeInsets.symmetric(vertical: 14.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                      ),
                      child: Text(
                        buyNow ? "Mua ngay" : "Thêm vào giỏ hàng",
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
          },
        );
      },
    );
  }

  Widget _buildQuantitySelector() {
    final maxStock = _getMaxStock();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 12.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Số lượng",
              style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
            ),
            Text(
              "Còn $maxStock sản phẩm",
              style: TextStyle(fontSize: 12.sp, color: Colors.grey[500]),
            ),
          ],
        ),
        SizedBox(height: 12.h),
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
            SizedBox(width: 20.w),
            Text(
              "$_quantity",
              style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
            ),
            SizedBox(width: 20.w),
            _buildQuantityButton(
              icon: Icons.add,
              onPressed: () {
                if (_quantity < maxStock) {
                  setState(() => _quantity++);
                }
              },
              isEnabled: _quantity < maxStock,
            ),
          ],
        ),
        SizedBox(height: 12.h),
      ],
    );
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

  Widget _buildSpecifications() {
    // Hiển thị thông tin cơ bản từ dữ liệu sản phẩm
    final specs = <MapEntry<String, String>>[];
    
    // Thêm brand ID
    specs.add(MapEntry('Thương hiệu', 'ID: ${_currentProduct.brandId}'));
    
    // Thêm số SKU variants
    if (_currentProduct.skus.isNotEmpty) {
      specs.add(MapEntry('Phân loại', '${_currentProduct.skus.length} loại'));
    }
    
    // Thêm khoảng giá
    if (_currentProduct.skus.length > 1) {
      final formatCurrency = NumberFormat("#,##0", "vi_VN");
      final prices = _currentProduct.skus.map((s) => s.price).toList();
      prices.sort();
      specs.add(MapEntry(
        'Khoảng giá',
        'đ${formatCurrency.format(prices.first)} - đ${formatCurrency.format(prices.last)}',
      ));
    }
    
    // Tổng stock
    final totalStock = _currentProduct.skus.fold(0, (sum, sku) => sum + sku.stock);
    specs.add(MapEntry('Kho hàng', '$totalStock sản phẩm'));
    
    // Variants info
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
        SizedBox(height: 12.h),
        Text(
          "Thông tin sản phẩm",
          style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 12.h),
        ...specs.map((entry) => _buildSpecRow(entry.key, entry.value)),
        SizedBox(height: 12.h),
      ],
    );
  }

  Widget _buildSpecRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Row(
        children: [
          SizedBox(
            width: 120.w,
            child: Text(
              label,
              style: TextStyle(color: Colors.grey[600], fontSize: 14.sp),
            ),
          ),
          Expanded(
            child: Text(value, style: TextStyle(fontSize: 14.sp)),
          ),
        ],
      ),
    );
  }

  Widget _buildDescription() {
    final description = _currentProduct.description ?? "Chưa có mô tả.";
    final isLong = description.length > 200;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 12.h),
        Text(
          "Mô tả sản phẩm",
          style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8.h),
        AnimatedCrossFade(
          firstChild: Text(
            description,
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey[800],
              height: 1.5,
            ),
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
          ),
          secondChild: Text(
            description,
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey[800],
              height: 1.5,
            ),
          ),
          crossFadeState: _isDescriptionExpanded
              ? CrossFadeState.showSecond
              : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 300),
        ),
        if (isLong) ...[
          SizedBox(height: 4.h),
          Center(
            child: TextButton.icon(
              onPressed: () {
                setState(() {
                  _isDescriptionExpanded = !_isDescriptionExpanded;
                });
              },
              icon: Icon(
                _isDescriptionExpanded
                    ? Icons.keyboard_arrow_up
                    : Icons.keyboard_arrow_down,
                size: 18.sp,
              ),
              label: Text(
                _isDescriptionExpanded ? "Thu gọn" : "Xem thêm",
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildReviews() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: ReviewListWidget(productId: widget.product.id),
    );
  }

  Widget _buildRecommendations() {
    final formatCurrency = NumberFormat("#,##0", "vi_VN");
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Có thể bạn cũng thích",
          style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 12.h),
        if (_isLoadingRecommendations)
          SizedBox(
            height: 220.h,
            child: const Center(child: CircularProgressIndicator()),
          )
        else if (_recommendations.isEmpty)
          SizedBox(
            height: 100.h,
            child: Center(
              child: Text(
                'Chưa có sản phẩm gợi ý',
                style: TextStyle(color: Colors.grey[500], fontSize: 14.sp),
              ),
            ),
          )
        else
          SizedBox(
            height: 230.h,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _recommendations.length,
              separatorBuilder: (c, i) => SizedBox(width: 10.w),
              itemBuilder: (c, i) {
                final product = _recommendations[i];
                final imageUrl = product.images.isNotEmpty
                    ? product.images[0]
                        .replaceFirst('url: ', '')
                        .trim()
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
                    width: 150.w,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8.r),
                      border: Border.all(color: Colors.grey[200]!),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(8.r),
                          ),
                          child: imageUrl.isNotEmpty
                              ? CachedNetworkImage(
                                  imageUrl: imageUrl,
                                  height: 130.h,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                  errorWidget: (_, __, ___) => Container(
                                    height: 130.h,
                                    color: Colors.grey[200],
                                    child: const Center(
                                      child: Icon(Icons.image, color: Colors.grey),
                                    ),
                                  ),
                                  placeholder: (_, __) => Container(
                                    height: 130.h,
                                    color: Colors.grey[100],
                                    child: const Center(
                                      child: CircularProgressIndicator(strokeWidth: 2),
                                    ),
                                  ),
                                )
                              : Container(
                                  height: 130.h,
                                  color: Colors.grey[200],
                                  child: const Center(
                                    child: Icon(Icons.image, color: Colors.grey),
                                  ),
                                ),
                        ),
                        Padding(
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
                              SizedBox(height: 4.h),
                              Text(
                                'đ${formatCurrency.format(product.basePrice)}',
                                style: TextStyle(
                                  color: const Color(0xFFEE4D2D),
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.bold,
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
    );
  }

  Widget _buildBottomBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
      ),
      child: SafeArea(
        child: Row(
          children: [
            // Nút xem shop
            Expanded(
              flex: 2,
              child: InkWell(
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Tính năng xem shop đang phát triển'),
                      duration: Duration(seconds: 1),
                    ),
                  );
                },
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.h),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.store_outlined,
                        color: const Color(0xFFEE4D2D),
                        size: 20.sp,
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        "Xem Shop",
                        style: TextStyle(
                          fontSize: 10.sp,
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Container(width: 1, height: 30.h, color: Colors.grey.shade300),
            // Thêm vào giỏ
            Expanded(
              flex: 3,
              child: InkWell(
                onTap: () => _showVariantBottomSheet(buyNow: false),
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 14.h),
                  color: const Color(0xFFFFEAE6), // Cam nhạt
                  child: Text(
                    "Thêm vào giỏ hàng",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: const Color(0xFFEE4D2D),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
            // Mua ngay
            Expanded(
              flex: 3,
              child: InkWell(
                onTap: () => _showVariantBottomSheet(buyNow: true),
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 14.h),
                  color: const Color(0xFFEE4D2D), // Shopee orange
                  child: Text(
                    "Mua ngay",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
