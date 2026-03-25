import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../domain/entities/shop_video.dart';
import 'video_comments_bottom_sheet.dart';
import 'video_products_bottom_sheet.dart';

class VideoActionButtons extends StatelessWidget {
  final ShopVideo video;
  final VoidCallback onLikeToggle;

  const VideoActionButtons({
    super.key,
    required this.video,
    required this.onLikeToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Shop Avatar (có thể bấm vào shop)
        GestureDetector(
          onTap: () {
            // Navigator.pushNamed(context, RouteName.shopDetail, arguments: video.shopId);
          },
          child: Container(
            width: 48.w,
            height: 48.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
              image: DecorationImage(
                image: NetworkImage(
                  video.shop?.avatar ??
                      'https://ui-avatars.com/api/?name=${video.shop?.name ?? "S"}&background=random',
                ),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
        SizedBox(height: 20.h),
        // Like Button
        _buildActionButton(
          icon: video.isLiked ? Icons.favorite : Icons.favorite_border,
          color: video.isLiked ? const Color(0xFFF44336) : Colors.white, // DS Lỗi/Đỏ cho like
          label: _formatCount(video.likeCount),
          onTap: onLikeToggle,
        ),
        SizedBox(height: 20.h),
        // Comment Button
        _buildActionButton(
          icon: Icons.comment_rounded,
          color: Colors.white,
          label: _formatCount(video.commentCount),
          onTap: () {
            VideoCommentsBottomSheet.show(context, video.id);
          },
        ),
        SizedBox(height: 20.h),
        // Nút Giỏ hàng / Sản phẩm - chỉ hiện khi video có sản phẩm
        if (video.products.isNotEmpty)
          _buildActionButton(
            icon: Icons.shopping_bag_outlined,
            color: const Color(0xFF00A8E8), // DS Primary - nổi bật hơn
            label: 'Mua sắm',
            onTap: () {
              VideoProductsBottomSheet.show(context, video.products);
            },
          ),
        if (video.products.isNotEmpty)
          SizedBox(height: 20.h),
        // Share Button
        _buildActionButton(
          icon: Icons.share_rounded,
          color: Colors.white,
          label: 'Chia sẻ',
          onTap: () {
            // TODO: Khai báo share logic
          },
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 36.sp),
          SizedBox(height: 4.h),
          Text(
            label,
            style: TextStyle(
              color: Colors.white,
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              shadows: const [
                Shadow(
                  color: Colors.black54,
                  offset: Offset(0, 1),
                  blurRadius: 2,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatCount(int count) {
    if (count >= 1000000) {
      return '${(count / 1000000).toStringAsFixed(1)}M';
    } else if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}K';
    }
    return count.toString();
  }
}
