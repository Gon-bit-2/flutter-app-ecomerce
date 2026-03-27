import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../../utils/cloudinary_helper.dart';

class AppNetworkImage extends StatelessWidget {
  /// URL ảnh gốc (từ Cloudinary, Network, hoặc Avatar).
  final String imageUrl;

  /// Width của Box chứa ảnh trên màn hình.
  /// Quan trọng: Nên cung cấp để Cloudinary tự cắt ảnh nhỏ lại, tiết kiệm băng thông.
  final double? width;

  /// Height của Box chứa ảnh trên màn hình.
  /// Quan trọng: Nên cung cấp để Cloudinary tự cắt ảnh nhỏ lại, tiết kiệm băng thông.
  final double? height;

  /// Thuộc tính fit của khung ảnh. Mặc định là cover.
  final BoxFit fit;

  /// Bọc ảnh tròn hoặc custom BorderRadius
  final BorderRadiusGeometry? borderRadius;

  /// Cách crop của Cloudinary: 'fill', 'fit', 'scale', 'thumb', 'pad'.
  /// Mặc định: 'fill' (giữ khung, lấp đầy giống cover).
  final String? cloudinaryCropMode;

  /// Ép bộ nhớ RAM của Flutter (memCache) chỉ load tối đa bao nhiêu pixel chiều rộng.
  /// (Rất quan trọng trong GridView/ListView để chống Over Out Of Memory).
  final int? memCacheWidth;

  /// Ép bộ nhớ RAM của Flutter (memCache) chỉ load tối đa bao nhiêu pixel chiều cao.
  final int? memCacheHeight;

  const AppNetworkImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.cloudinaryCropMode = 'fill',
    this.memCacheWidth,
    this.memCacheHeight,
  });

  @override
  Widget build(BuildContext context) {
    if (imageUrl.isEmpty) {
      return _buildErrorWidget();
    }

    // Tự động tối ưu hoá URL qua Cloudinary (nếu url của Cloudinary)
    // Lấy device pixel ratio để nhân lên cho sắc nét trên màn hình Retina/OLED
    final pixelRatio = MediaQuery.of(context).devicePixelRatio;

    // Cloudinary yêu cầu int params
    int? cloudinaryWidth;
    int? cloudinaryHeight;

    if (width != null && width != double.infinity) {
      cloudinaryWidth = (width! * pixelRatio).toInt();
    }
    if (height != null && height != double.infinity) {
      cloudinaryHeight = (height! * pixelRatio).toInt();
    }

    final String optimizedUrl = CloudinaryHelper.optimizeUrl(
      imageUrl,
      width: cloudinaryWidth,
      height: cloudinaryHeight,
      cropMode: cloudinaryCropMode,
    );

    // Xử lý mem cache engine: Ngăn Flutter nuốt RAM khi list dài
    // Mặc định, nếu dev không truyền, ta tự ép memCache = box constraints * pixelRatio
    int? cacheWidth = memCacheWidth ?? cloudinaryWidth;
    int? cacheHeight = memCacheHeight ?? cloudinaryHeight;

    // Flutter cache key cho memory
    Widget imageWidget = CachedNetworkImage(
      imageUrl: optimizedUrl,
      width: width,
      height: height,
      fit: fit,
      memCacheWidth: cacheWidth,
      memCacheHeight: cacheHeight,
      placeholder: (context, url) => _buildShimmerPlaceholder(),
      errorWidget: (context, url, error) => _buildErrorWidget(),
    );

    if (borderRadius != null) {
      return ClipRRect(borderRadius: borderRadius!, child: imageWidget);
    }

    return imageWidget;
  }

  Widget _buildShimmerPlaceholder() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        width: width ?? double.infinity,
        height: height ?? double.infinity,
        color: Colors.white,
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: borderRadius ?? BorderRadius.zero,
      ),
      child: const Center(
        child: Icon(Icons.broken_image_rounded, color: Colors.grey, size: 24),
      ),
    );
  }
}
