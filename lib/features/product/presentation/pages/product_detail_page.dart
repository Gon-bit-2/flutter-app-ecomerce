import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/product.dart';

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

  // Calculate price to show. Range if multiple SKUs, or single price.
  // For now, simple logic.

  @override
  void initState() {
    super.initState();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
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
                      IconButton(
                        icon: const CircleAvatar(
                          backgroundColor: Colors.black26,
                          child: Icon(Icons.shopping_cart, color: Colors.white),
                        ),
                        onPressed: () {},
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
                            widget.product.name,
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
                          const Divider(thickness: 1, color: Color(0xFFEEEEEE)),
                          _buildShippingSection(),
                          const Divider(thickness: 1, color: Color(0xFFEEEEEE)),
                          _buildVariantSelector(),
                          const Divider(thickness: 1, color: Color(0xFFEEEEEE)),
                          _buildQuantitySelector(),
                          const Divider(thickness: 1, color: Color(0xFFEEEEEE)),
                          _buildSpecifications(),
                          const Divider(thickness: 1, color: Color(0xFFEEEEEE)),
                          _buildDescription(),
                          const Divider(thickness: 1, color: Color(0xFFEEEEEE)),
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
      bottomSheet: _buildBottomBar(),
    );
  }

  Widget _buildImageSlider() {
    return Stack(
      children: [
        PageView.builder(
          onPageChanged: (index) {
            setState(() {
              _currentImageIndex = index;
            });
          },
          itemCount: widget.product.images.isNotEmpty
              ? widget.product.images.length
              : 1,
          itemBuilder: (context, index) {
            final images = widget.product.images;
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
                        "Image Empty\nLength: ${images.length}",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 12.sp, color: Colors.red),
                      ),
                    ],
                  ),
                ),
              );
            }
            final url = images[index];
            return Stack(
              children: [
                CachedNetworkImage(
                  imageUrl: url,
                  fit: BoxFit.cover,
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
                              "Load Error: $error\nURL: $url",
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
                // Debug overlay to verify URL
                Positioned(
                  top: 10,
                  left: 10,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    color: Colors.black54,
                    child: Text(
                      url,
                      style: const TextStyle(color: Colors.white, fontSize: 10),
                    ),
                  ),
                ),
              ],
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
              "${_currentImageIndex + 1}/${widget.product.images.length}",
              style: TextStyle(color: Colors.white, fontSize: 12.sp),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPriceSection() {
    final formatCurrency = NumberFormat("#,##0", "vi_VN");
    double discount = 0;
    if (widget.product.virtualPrice != null &&
        widget.product.virtualPrice! > widget.product.basePrice) {
      discount =
          ((widget.product.virtualPrice! - widget.product.basePrice) /
              widget.product.virtualPrice!) *
          100;
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          'đ${formatCurrency.format(widget.product.basePrice)}',
          style: TextStyle(
            color: Theme.of(context).primaryColor,
            fontSize: 24.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        if (widget.product.virtualPrice != null &&
            widget.product.virtualPrice! > widget.product.basePrice) ...[
          SizedBox(width: 8.w),
          Text(
            'đ${formatCurrency.format(widget.product.virtualPrice)}',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 14.sp,
              decoration: TextDecoration.lineThrough,
            ),
          ),
          SizedBox(width: 8.w),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
            color: Colors.amber[100],
            child: Text(
              "-${discount.toStringAsFixed(0)}%",
              style: TextStyle(
                color: Colors.amber[900],
                fontSize: 10.sp,
                fontWeight: FontWeight.bold,
              ),
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
          "${widget.product.rating ?? 4.9}",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp),
        ),
        SizedBox(width: 8.w),
        Container(height: 12.h, width: 1, color: Colors.grey),
        SizedBox(width: 8.w),
        Text(
          "${widget.product.sold ?? 100} Sold",
          style: TextStyle(color: Colors.grey[600], fontSize: 14.sp),
        ),
        const Spacer(),
        Text(
          "See all reviews >",
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
          Icon(
            Icons.local_shipping_outlined,
            color: Colors.blue[700],
            size: 20.sp,
          ),
          SizedBox(width: 12.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Free Shipping",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp),
              ),
              Text(
                "Delivery to New York",
                style: TextStyle(color: Colors.grey[600], fontSize: 12.sp),
              ),
            ],
          ),
          const Spacer(),
          Icon(Icons.chevron_right, color: Colors.grey),
        ],
      ),
    );
  }

  Widget _buildVariantSelector() {
    if (widget.product.variants == null || widget.product.variants!.isEmpty) {
      return const SizedBox.shrink();
    }

    // variants structure: [{"value": "Color", "options": ["Red", "Blue"]}]
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 8.h),
        ...widget.product.variants!.map((variant) {
          if (variant is! Map) return const SizedBox.shrink();
          String name = variant['value'] ?? '';
          List options = variant['options'] as List? ?? [];

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Select $name",
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (options.isNotEmpty && _selectedVariants[name] != null)
                    Text(
                      "${_selectedVariants[name]}",
                      style: TextStyle(color: Colors.grey, fontSize: 12.sp),
                    ),
                ],
              ),
              SizedBox(height: 8.h),
              Wrap(
                spacing: 8.w,
                children: options.map((opt) {
                  bool isSelected = _selectedVariants[name] == opt;
                  return ChoiceChip(
                    label: Text(opt.toString()),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _selectedVariants[name] = opt.toString();
                        } else {
                          _selectedVariants.remove(name);
                        }
                      });
                    },
                    selectedColor: Theme.of(
                      context,
                    ).primaryColor.withOpacity(0.1),
                    labelStyle: TextStyle(
                      color: isSelected
                          ? Theme.of(context).primaryColor
                          : Colors.black87,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4.r),
                      side: BorderSide(
                        color: isSelected
                            ? Theme.of(context).primaryColor
                            : Colors.grey[300]!,
                      ),
                    ),
                  );
                }).toList(),
              ),
              SizedBox(height: 12.h),
            ],
          );
        }),
      ],
    );
  }

  Widget _buildQuantitySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 12.h),
        Text(
          "Quantity",
          style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
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
                setState(() => _quantity++);
              },
              isEnabled: true,
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
    // Hardcoded for demo/preview based on image
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 12.h),
        Text(
          "Product Specifications",
          style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 12.h),
        _buildSpecRow("Connectivity", "Bluetooth / Wireless"),
        _buildSpecRow("Warranty", "12 Months"),
        _buildSpecRow("Battery Life", "70 Days"),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 12.h),
        Text(
          "Product Description",
          style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8.h),
        Text(
          widget.product.description ?? "No description available.",
          style: TextStyle(
            fontSize: 14.sp,
            color: Colors.grey[800],
            height: 1.5,
          ),
          maxLines: 4,
          overflow: TextOverflow.ellipsis,
        ),
        SizedBox(height: 4.h),
        Center(
          child: TextButton(onPressed: () {}, child: const Text("Show More")),
        ),
      ],
    );
  }

  Widget _buildReviews() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Product Ratings",
              style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
            ),
            Text(
              "See All",
              style: TextStyle(
                color: Theme.of(context).primaryColor,
                fontSize: 14.sp,
              ),
            ),
          ],
        ),
        // Mock review
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const CircleAvatar(
            backgroundImage: NetworkImage('https://i.pravatar.cc/100?img=1'),
          ),
          title: const Text("alexander_w"),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: List.generate(
                  5,
                  (index) => Icon(Icons.star, size: 12.sp, color: Colors.amber),
                ),
              ),
              Text(
                "Variation: Graphite",
                style: TextStyle(fontSize: 12.sp, color: Colors.grey),
              ),
              SizedBox(height: 4.h),
              const Text(
                "The mouse is absolutely amazing! Quiet clicks are a game changer.",
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRecommendations() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "You may also like",
          style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 12.h),
        // Horizontal list or grid? Image shows grid underneath.
        // For simple preview, maybe horizontal
        SizedBox(
          height: 220.h,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: 4,
            separatorBuilder: (c, i) => SizedBox(width: 12.w),
            itemBuilder: (c, i) {
              return Container(
                width: 150.w,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 120.h,
                      color: Colors.grey[200],
                      child: const Center(child: Icon(Icons.image)),
                    ),
                    Padding(
                      padding: EdgeInsets.all(8.w),
                      child: const Text("Product Name", maxLines: 2),
                    ),
                  ],
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
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, -2),
            blurRadius: 10,
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.chat_bubble_outline, color: Colors.grey[700]),
                Text(
                  "Chat",
                  style: TextStyle(fontSize: 10.sp, color: Colors.grey[700]),
                ),
              ],
            ),
            SizedBox(width: 16.w),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.add_shopping_cart, color: Colors.grey[700]),
                Text(
                  "Add to Cart",
                  style: TextStyle(fontSize: 10.sp, color: Colors.grey[700]),
                ),
              ],
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                ),
                child: const Text("Buy Now"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
