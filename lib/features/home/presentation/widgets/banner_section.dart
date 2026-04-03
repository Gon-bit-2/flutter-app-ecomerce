import 'package:app_fe_ecomerce/core/styles/app_colors.dart';
import 'package:app_fe_ecomerce/core/common/widgets/app_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../domain/entities/banner_entity.dart';

class BannerSection extends StatefulWidget {
  final List<BannerEntity> banners;

  const BannerSection({super.key, required this.banners});

  @override
  State<BannerSection> createState() => _BannerSectionState();
}

class _BannerSectionState extends State<BannerSection> {
  int _current = 0;

  @override
  Widget build(BuildContext context) {
    if (widget.banners.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 16.h),
      child: Column(
        children: [
          CarouselSlider(
            options: CarouselOptions(
              aspectRatio: 2.2, // Tỉ lệ khung hình rộng hơn một chút cho banner hiện đại
              viewportFraction: 0.9, // Cho phép nhìn thấy mép của banner tiếp theo
              enlargeCenterPage: true, // Phóng to banner ở giữa
              enlargeFactor: 0.15, // Mức độ phóng to
              autoPlay: true,
              autoPlayInterval: const Duration(seconds: 4),
              autoPlayAnimationDuration: const Duration(milliseconds: 800),
              autoPlayCurve: Curves.fastOutSlowIn,
              onPageChanged: (index, reason) {
                setState(() {
                  _current = index;
                });
              },
            ),
            items: widget.banners.map((banner) {
              return Builder(
                builder: (BuildContext context) {
                  return Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16.r),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16.r),
                      child: AppNetworkImage(
                        imageUrl: banner.imageUrl,
                        fit: BoxFit.cover, // Cover để ảnh lấp đầy khung
                        width: double.infinity,
                      ),
                    ),
                  );
                },
              );
            }).toList(),
          ),
          SizedBox(height: 12.h),
          // Animated Indicators
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: widget.banners.asMap().entries.map((entry) {
              final isSelected = _current == entry.key;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: isSelected ? 24.w : 8.w,
                height: 8.h,
                margin: EdgeInsets.symmetric(horizontal: 4.w),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4.r),
                  color: isSelected
                      ? AppColors.primaryBlue
                      : AppColors.primaryBlue.withOpacity(0.2),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
