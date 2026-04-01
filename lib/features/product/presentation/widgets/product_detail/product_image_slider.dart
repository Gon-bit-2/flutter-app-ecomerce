import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:app_fe_ecomerce/core/common/widgets/app_network_image.dart';
import 'package:app_fe_ecomerce/features/product/domain/entities/product.dart';

class ProductImageSlider extends StatefulWidget {
  final Product product;

  const ProductImageSlider({super.key, required this.product});

  @override
  State<ProductImageSlider> createState() => _ProductImageSliderState();
}

class _ProductImageSliderState extends State<ProductImageSlider> {
  int _currentImageIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        PageView.builder(
          physics: const ClampingScrollPhysics(),
          onPageChanged: (index) {
            setState(() {
              _currentImageIndex = index;
            });
          },
          itemCount: widget.product.images.isNotEmpty ? widget.product.images.length : 1,
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
              child: AppNetworkImage(
                imageUrl: url,
                fit: BoxFit.contain,
                width: double.infinity,
                height: double.infinity,
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
              "${_currentImageIndex + 1}/${widget.product.images.isNotEmpty ? widget.product.images.length : 1}",
              style: TextStyle(color: Colors.white, fontSize: 12.sp),
            ),
          ),
        ),
      ],
    );
  }
}
