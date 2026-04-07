import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get_it/get_it.dart';
import 'dart:ui';

import '../../../cart/presentation/bloc/cart/cart_bloc.dart';
import '../bloc/video_feed/video_feed_bloc.dart';
import '../bloc/video_feed/video_feed_event.dart';
import '../bloc/video_feed/video_feed_state.dart';
import '../widgets/video_player_widget.dart';
import '../widgets/video_action_buttons.dart';
import '../widgets/video_product_card.dart';
import 'create_video_page.dart';

class VideoFeedPage extends StatelessWidget {
  const VideoFeedPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<VideoFeedBloc>(
          create: (context) =>
              GetIt.I<VideoFeedBloc>()..add(const LoadVideoFeedEvent(isRefresh: true)),
        ),
        BlocProvider<CartBloc>(
          create: (context) => GetIt.I<CartBloc>(),
        ),
      ],
      child: const VideoFeedView(),
    );
  }
}

class VideoFeedView extends StatefulWidget {
  const VideoFeedView({super.key});

  @override
  State<VideoFeedView> createState() => _VideoFeedViewState();
}

class _VideoFeedViewState extends State<VideoFeedView> {
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Cart listener cho SnackBar
          BlocListener<CartBloc, CartState>(
            listener: (context, state) {
              if (state is CartOperationSuccess) {
                _showSnackBar(
                  context,
                  state.message,
                  Icons.check_circle_rounded,
                  const Color(0xFF4CAF50),
                );
              } else if (state is CartFailure) {
                _showSnackBar(
                  context,
                  state.message,
                  Icons.error_outline_rounded,
                  const Color(0xFFF44336),
                );
              } else if (state is CartUnauthenticated) {
                _showSnackBar(
                  context,
                  'Vui lòng đăng nhập để mua hàng',
                  Icons.login_rounded,
                  const Color(0xFFFF9800),
                );
              }
            },
            child: BlocBuilder<VideoFeedBloc, VideoFeedState>(
              builder: (context, state) {
                if (state is VideoFeedLoading && state.isFirstFetch) {
                  return _buildLoadingState();
                }

                if (state is VideoFeedError &&
                    (state.oldVideos == null || state.oldVideos!.isEmpty)) {
                  return _buildErrorState(context, state.message);
                }

                List videos = [];
                if (state is VideoFeedLoaded) {
                  videos = state.videos;
                } else if (state is VideoFeedLoading) {
                  videos = state.oldVideos;
                } else if (state is VideoFeedError) {
                  videos = state.oldVideos ?? [];
                }

                if (videos.isEmpty) {
                  return _buildEmptyState();
                }

                return PageView.builder(
                  controller: _pageController,
                  scrollDirection: Axis.vertical,
                  itemCount: videos.length,
                  onPageChanged: (index) {
                    final currentState = context.read<VideoFeedBloc>().state;
                    final hasReachedMax =
                        currentState is VideoFeedLoaded && currentState.hasReachedMax;
                    if (!hasReachedMax &&
                        videos.length > 1 &&
                        index >= videos.length - 2) {
                      context.read<VideoFeedBloc>().add(LoadMoreVideoFeedEvent());
                    }
                  },
                  itemBuilder: (context, index) {
                    final video = videos[index];
                    return _buildVideoPage(context, video);
                  },
                );
              },
            ),
          ),

          // Top bar: back + camera
          _buildTopBar(context),
        ],
      ),
    );
  }

  // ───── Video Page Item ─────
  Widget _buildVideoPage(BuildContext context, dynamic video) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Video Player
        VideoPlayerWidget(
          videoUrl: video.videoUrl,
          thumbnailUrl: video.thumbnailUrl,
        ),

        // Gradient Overlay (3 điểm dừng mượt hơn)
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.black.withOpacity(0.15),
                  Colors.transparent,
                  Colors.transparent,
                  Colors.black.withOpacity(0.7),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: const [0.0, 0.2, 0.55, 1.0],
              ),
            ),
          ),
        ),

        // User Info & Caption (Bottom Left)
        Positioned(
          left: 16,
          bottom: video.products.isNotEmpty ? 100 : 70,
          right: 76,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Username
              Row(
                children: [
                  Text(
                    '@${video.shop?.name ?? 'Người dùng'}',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.3,
                      shadows: const [
                        Shadow(color: Colors.black54, blurRadius: 6),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8.h),
              // Caption (expandable)
              if (video.caption != null && video.caption!.isNotEmpty)
                _ExpandableCaption(caption: video.caption!),
            ],
          ),
        ),

        // Product tag (Bottom)
        if (video.products.isNotEmpty)
          Positioned(
            left: 16,
            bottom: 16,
            right: 76,
            child: VideoProductCard(
              product: video.products.first,
              allProducts: video.products,
            ),
          ),

        // Action Buttons (Right)
        Positioned(
          right: 8,
          bottom: 32,
          child: VideoActionButtons(
            video: video,
            onLikeToggle: () {
              context.read<VideoFeedBloc>().add(ToggleLikeVideoEvent(video.id));
            },
          ),
        ),
      ],
    );
  }

  // ───── Top Bar ─────
  Widget _buildTopBar(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 8,
      left: 12,
      right: 12,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Back button
          if (Navigator.canPop(context))
            _buildBlurButton(
              icon: Icons.arrow_back_ios_new_rounded,
              onTap: () => Navigator.pop(context),
            ),
          if (!Navigator.canPop(context)) const SizedBox(),
          // Camera button
          _buildBlurButton(
            icon: Icons.videocam_rounded,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CreateVideoPage()),
              );
            },
          ),
        ],
      ),
    );
  }

  // ───── Blur Button Helper ─────
  Widget _buildBlurButton({required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: ClipOval(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: Container(
            width: 40.w,
            height: 40.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.15),
            ),
            child: Icon(icon, color: Colors.white, size: 22.sp),
          ),
        ),
      ),
    );
  }

  // ───── Loading State ─────
  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 32.w,
            height: 32.w,
            child: const CircularProgressIndicator(
              strokeWidth: 2.5,
              color: Color(0xFF00A8E8),
            ),
          ),
          SizedBox(height: 16.h),
          Text(
            'Đang tải video...',
            style: TextStyle(
              color: Colors.white60,
              fontSize: 14.sp,
            ),
          ),
        ],
      ),
    );
  }

  // ───── Error State ─────
  Widget _buildErrorState(BuildContext context, String message) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 40.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.wifi_off_rounded, color: Colors.white38, size: 48.sp),
            SizedBox(height: 16.h),
            Text(
              message,
              style: const TextStyle(color: Colors.white70, fontSize: 14),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20.h),
            GestureDetector(
              onTap: () {
                context.read<VideoFeedBloc>().add(const LoadVideoFeedEvent(isRefresh: true));
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 28.w, vertical: 12.h),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF00A8E8), Color(0xFF2196F3)],
                  ),
                  borderRadius: BorderRadius.circular(24.r),
                ),
                child: Text(
                  'Thử lại',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ───── Empty State ─────
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.play_circle_outline_rounded, color: Colors.white24, size: 64.sp),
          SizedBox(height: 12.h),
          Text(
            'Chưa có video nào',
            style: TextStyle(color: Colors.white60, fontSize: 16.sp),
          ),
        ],
      ),
    );
  }

  // ───── SnackBar Helper ─────
  void _showSnackBar(BuildContext context, String msg, IconData icon, Color bg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Expanded(child: Text(msg)),
          ],
        ),
        backgroundColor: bg,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      ),
    );
  }
}

// ───── Expandable Caption Widget ─────
class _ExpandableCaption extends StatefulWidget {
  final String caption;

  const _ExpandableCaption({required this.caption});

  @override
  State<_ExpandableCaption> createState() => _ExpandableCaptionState();
}

class _ExpandableCaptionState extends State<_ExpandableCaption> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => setState(() => _expanded = !_expanded),
      child: AnimatedCrossFade(
        firstChild: Row(
          children: [
            Expanded(
              child: Text(
                widget.caption,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 13.sp,
                  height: 1.35,
                  shadows: const [Shadow(color: Colors.black54, blurRadius: 4)],
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (widget.caption.length > 60)
              Padding(
                padding: EdgeInsets.only(left: 4.w),
                child: Text(
                  'thêm',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
        secondChild: Text(
          widget.caption,
          style: TextStyle(
            color: Colors.white,
            fontSize: 13.sp,
            height: 1.35,
            shadows: const [Shadow(color: Colors.black54, blurRadius: 4)],
          ),
        ),
        crossFadeState:
            _expanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
        duration: const Duration(milliseconds: 200),
      ),
    );
  }
}
