import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

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
          create: (context) => GetIt.I<VideoFeedBloc>()..add(const LoadVideoFeedEvent(isRefresh: true)),
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
          // Lắng nghe CartState để hiển thị SnackBar
          BlocListener<CartBloc, CartState>(
            listener: (context, state) {
              if (state is CartOperationSuccess) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        const Icon(Icons.check_circle, color: Colors.white, size: 20),
                        const SizedBox(width: 8),
                        Text(state.message),
                      ],
                    ),
                    backgroundColor: const Color(0xFF4CAF50), // DS Thành công
                    behavior: SnackBarBehavior.floating,
                    duration: const Duration(seconds: 2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                );
              } else if (state is CartFailure) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        const Icon(Icons.error_outline, color: Colors.white, size: 20),
                        const SizedBox(width: 8),
                        Expanded(child: Text(state.message)),
                      ],
                    ),
                    backgroundColor: const Color(0xFFF44336), // DS Lỗi
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                );
              } else if (state is CartUnauthenticated) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Row(
                      children: [
                        Icon(Icons.login, color: Colors.white, size: 20),
                        SizedBox(width: 8),
                        Text('Vui lòng đăng nhập để mua hàng'),
                      ],
                    ),
                    backgroundColor: const Color(0xFFFF9800), // DS Cảnh báo
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                );
              }
            },
            child: BlocBuilder<VideoFeedBloc, VideoFeedState>(
              builder: (context, state) {
                if (state is VideoFeedLoading && state.isFirstFetch) {
                  return const Center(child: CircularProgressIndicator(
                    color: Color(0xFF00A8E8), // DS Primary
                  ));
                }

                if (state is VideoFeedError && (state.oldVideos == null || state.oldVideos!.isEmpty)) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(state.message, style: const TextStyle(color: Colors.white)),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF00A8E8), // DS Primary
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: () {
                            context.read<VideoFeedBloc>().add(const LoadVideoFeedEvent(isRefresh: true));
                          },
                          child: const Text('Thử lại'),
                        )
                      ],
                    ),
                  );
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
                  return const Center(
                    child: Text('Chưa có video nào.', style: TextStyle(color: Colors.white)),
                  );
                }

                return PageView.builder(
                  controller: _pageController,
                  scrollDirection: Axis.vertical,
                  itemCount: videos.length,
                  onPageChanged: (index) {
                    if (index >= videos.length - 2) {
                      context.read<VideoFeedBloc>().add(LoadMoreVideoFeedEvent());
                    }
                  },
                  itemBuilder: (context, index) {
                    final video = videos[index];
                    return Stack(
                      fit: StackFit.expand,
                      children: [
                        // Video Player
                        VideoPlayerWidget(
                          videoUrl: video.videoUrl,
                          thumbnailUrl: video.thumbnailUrl,
                        ),
                        
                        // Gradient Overlay for texts and buttons
                        Positioned.fill(
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.transparent,
                                  Colors.black.withOpacity(0.6),
                                ],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                stops: const [0.5, 1.0],
                              ),
                            ),
                          ),
                        ),

                        // User Info & Caption (Bottom Left)
                        Positioned(
                          left: 16,
                          bottom: video.products.isNotEmpty ? 100 : 80,
                          right: 80,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '@${video.shop?.name ?? 'Người dùng'}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  shadows: [Shadow(color: Colors.black, blurRadius: 4)],
                                ),
                              ),
                              const SizedBox(height: 8),
                              if (video.caption != null && video.caption!.isNotEmpty)
                                Text(
                                  video.caption!,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    shadows: [Shadow(color: Colors.black, blurRadius: 4)],
                                  ),
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                ),
                            ],
                          ),
                        ),

                        // Product tag (Bottom) - Truyền allProducts
                        if (video.products.isNotEmpty)
                          Positioned(
                            left: 16,
                            bottom: 16,
                            right: 80,
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
                        
                        // Back button
                        Positioned(
                          top: 48,
                          left: 16,
                          child: IconButton(
                            icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                            onPressed: () => Navigator.pop(context),
                          ),
                        )
                      ],
                    );
                  },
                );
              },
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            right: 16,
            child: IconButton(
              icon: const Icon(Icons.camera_alt, color: Colors.white, size: 30, shadows: [Shadow(color: Colors.black54, blurRadius: 4)]),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CreateVideoPage()),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
