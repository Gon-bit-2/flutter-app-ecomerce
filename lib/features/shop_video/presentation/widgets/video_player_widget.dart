import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:app_fe_ecomerce/core/common/widgets/app_network_image.dart';
import 'package:chewie/chewie.dart';
import 'package:visibility_detector/visibility_detector.dart';

class VideoPlayerWidget extends StatefulWidget {
  final String videoUrl;
  final String? thumbnailUrl;

  const VideoPlayerWidget({
    super.key,
    required this.videoUrl,
    this.thumbnailUrl,
  });

  @override
  State<VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  late VideoPlayerController _videoPlayerController;
  ChewieController? _chewieController;
  bool _isInitialized = false;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    try {
      print('VideoPlayer initialized with URL: ${widget.videoUrl}');
      _videoPlayerController =
          VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl));

      await _videoPlayerController.initialize();

      _chewieController = ChewieController(
        videoPlayerController: _videoPlayerController,
        autoPlay: false,
        looping: true,
        showControls: false, // We'll handle tap to pause/play
        aspectRatio: _videoPlayerController.value.aspectRatio,
        errorBuilder: (context, errorMessage) {
          return Center(
            child: Text(
              errorMessage,
              style: const TextStyle(color: Colors.white),
            ),
          );
        },
      );

      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _hasError = true;
        });
      }
    }
  }

  @override
  void dispose() {
    _videoPlayerController.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  void _onVisibilityChanged(VisibilityInfo info) {
    if (!_isInitialized || _chewieController == null) return;

    if (info.visibleFraction > 0.7) {
      if (!_videoPlayerController.value.isPlaying) {
        _chewieController!.play();
      }
    } else {
      if (_videoPlayerController.value.isPlaying) {
        _chewieController!.pause();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: Key('${widget.videoUrl}_${widget.hashCode}'),
      onVisibilityChanged: _onVisibilityChanged,
      child: GestureDetector(
        onTap: () {
          if (!_isInitialized || _chewieController == null) return;
          if (_videoPlayerController.value.isPlaying) {
            _chewieController!.pause();
          } else {
            _chewieController!.play();
          }
        },
        child: Container(
          color: Colors.black,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Show thumbnail while loading if available
              if (!_isInitialized && widget.thumbnailUrl != null)
                AppNetworkImage(
                  imageUrl: widget.thumbnailUrl!,
                  fit: BoxFit.cover,
                ),
              if (_hasError)
                const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.error_outline, color: Colors.white54, size: 40),
                      SizedBox(height: 8),
                      Text(
                        'Video bị lỗi hoặc không tồn tại',
                        style: TextStyle(color: Colors.white54, fontSize: 13),
                      ),
                    ],
                  ),
                )
              else if (_isInitialized && _chewieController != null)
                Chewie(controller: _chewieController!)
              else
                const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
