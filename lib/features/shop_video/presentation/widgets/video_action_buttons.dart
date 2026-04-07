import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:ui';
import '../../domain/entities/shop_video.dart';
import 'video_comments_bottom_sheet.dart';
import 'video_products_bottom_sheet.dart';
import '../../../shop/presentation/pages/shop_profile_page.dart';

class VideoActionButtons extends StatefulWidget {
  final ShopVideo video;
  final VoidCallback onLikeToggle;

  const VideoActionButtons({
    super.key,
    required this.video,
    required this.onLikeToggle,
  });

  @override
  State<VideoActionButtons> createState() => _VideoActionButtonsState();
}

class _VideoActionButtonsState extends State<VideoActionButtons>
    with TickerProviderStateMixin {
  late AnimationController _likeAnimController;
  late Animation<double> _likeScaleAnimation;

  @override
  void initState() {
    super.initState();
    _likeAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _likeScaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.4), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.4, end: 1.0), weight: 50),
    ]).animate(CurvedAnimation(
      parent: _likeAnimController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _likeAnimController.dispose();
    super.dispose();
  }

  void _handleLike() {
    HapticFeedback.lightImpact();
    _likeAnimController.forward(from: 0);
    widget.onLikeToggle();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Shop Avatar với viền gradient
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ShopProfilePage(
                  shopId: widget.video.shopId,
                  shopName: widget.video.shop?.name,
                  shopAvatar: widget.video.shop?.avatar,
                ),
              ),
            );
          },
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // Avatar với viền gradient
              Container(
                padding: const EdgeInsets.all(2),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [Color(0xFF00A8E8), Color(0xFF2196F3), Color(0xFF0D47A1)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Container(
                  width: 46.w,
                  height: 46.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 1.5),
                    image: DecorationImage(
                      image: NetworkImage(
                        widget.video.shop?.avatar ??
                            'https://ui-avatars.com/api/?name=${widget.video.shop?.name ?? "S"}&background=random',
                      ),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              // Nút "+" follow giống TikTok
              Positioned(
                bottom: -6,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    width: 20.w,
                    height: 20.w,
                    decoration: const BoxDecoration(
                      color: Color(0xFF00A8E8),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(Icons.add, color: Colors.white, size: 14.sp),
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 22.h),

        // Like Button với bounce animation
        AnimatedBuilder(
          animation: _likeScaleAnimation,
          builder: (context, child) => Transform.scale(
            scale: _likeScaleAnimation.value,
            child: child,
          ),
          child: _buildActionButton(
            icon: widget.video.isLiked ? Icons.favorite : Icons.favorite_border,
            color: widget.video.isLiked ? const Color(0xFFF44336) : Colors.white,
            label: _formatCount(widget.video.likeCount),
            onTap: _handleLike,
          ),
        ),
        SizedBox(height: 18.h),

        // Comment Button
        _buildActionButton(
          icon: Icons.chat_bubble_rounded,
          color: Colors.white,
          label: _formatCount(widget.video.commentCount),
          onTap: () {
            VideoCommentsBottomSheet.show(context, widget.video.id);
          },
        ),
        SizedBox(height: 18.h),

        // Nút Giỏ hàng / Sản phẩm
        if (widget.video.products.isNotEmpty) ...[
          _buildActionButton(
            icon: Icons.shopping_bag_rounded,
            color: const Color(0xFF00A8E8),
            label: 'Mua sắm',
            onTap: () {
              VideoProductsBottomSheet.show(context, widget.video.products);
            },
          ),
          SizedBox(height: 18.h),
        ],

        // Share Button
        _buildActionButton(
          icon: Icons.reply_rounded,
          color: Colors.white,
          label: 'Chia sẻ',
          onTap: () {
            // TODO: Share logic
          },
          rotateIcon: true,
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required String label,
    required VoidCallback onTap,
    bool rotateIcon = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Nền blur glassmorphism cho icon
          ClipOval(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
              child: Container(
                width: 46.w,
                height: 46.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.12),
                ),
                child: Center(
                  child: Transform(
                    alignment: Alignment.center,
                    transform: rotateIcon
                        ? (Matrix4.identity()..scale(-1.0, 1.0))
                        : Matrix4.identity(),
                    child: Icon(icon, color: color, size: 28.sp),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            label,
            style: TextStyle(
              color: Colors.white,
              fontSize: 11.sp,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.2,
              shadows: const [
                Shadow(
                  color: Colors.black54,
                  offset: Offset(0, 1),
                  blurRadius: 3,
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
