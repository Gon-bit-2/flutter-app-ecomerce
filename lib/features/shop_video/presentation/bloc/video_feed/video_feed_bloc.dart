import 'package:bloc/bloc.dart';
import 'package:injectable/injectable.dart';
import '../../../domain/usecases/get_shop_videos_use_case.dart';
import '../../../domain/usecases/toggle_like_use_case.dart';
import '../../../domain/entities/shop_video.dart';

import 'video_feed_event.dart';
import 'video_feed_state.dart';

@injectable
class VideoFeedBloc extends Bloc<VideoFeedEvent, VideoFeedState> {
  final GetShopVideosUseCase getShopVideosUseCase;
  final ToggleLikeUseCase toggleLikeUseCase;

  int _currentPage = 1;
  static const int _limit = 10;
  int? _currentShopId;

  VideoFeedBloc(this.getShopVideosUseCase, this.toggleLikeUseCase) : super(VideoFeedInitial()) {
    on<LoadVideoFeedEvent>(_onLoadVideoFeed);
    on<LoadMoreVideoFeedEvent>(_onLoadMoreVideoFeed);
    on<ToggleLikeVideoEvent>(_onToggleLikeVideo);
  }

  Future<void> _onLoadVideoFeed(
    LoadVideoFeedEvent event,
    Emitter<VideoFeedState> emit,
  ) async {
    _currentShopId = event.shopId;
    if (event.isRefresh) {
      _currentPage = 1;
    }

    emit(const VideoFeedLoading([], isFirstFetch: true));

    final result = await getShopVideosUseCase.call(
      page: _currentPage,
      limit: _limit,
      shopId: _currentShopId,
    );

    result.fold(
      (failure) => emit(VideoFeedError(failure.message)),
      (videos) {
        bool hasReachedMax = videos.length < _limit;
        emit(VideoFeedLoaded(videos, hasReachedMax: hasReachedMax));
      },
    );
  }

  Future<void> _onLoadMoreVideoFeed(
    LoadMoreVideoFeedEvent event,
    Emitter<VideoFeedState> emit,
  ) async {
    if (state is VideoFeedLoaded) {
      final currentState = state as VideoFeedLoaded;
      if (currentState.hasReachedMax) return;

      emit(VideoFeedLoading(currentState.videos));
      _currentPage++;

      final result = await getShopVideosUseCase.call(
        page: _currentPage,
        limit: _limit,
        shopId: _currentShopId,
      );

      result.fold(
        (failure) {
          emit(VideoFeedError(failure.message, oldVideos: currentState.videos));
        },
        (videos) {
          bool hasReachedMax = videos.length < _limit;
          emit(VideoFeedLoaded(
            [...currentState.videos, ...videos],
            hasReachedMax: hasReachedMax,
          ));
        },
      );
    }
  }

  Future<void> _onToggleLikeVideo(
    ToggleLikeVideoEvent event,
    Emitter<VideoFeedState> emit,
  ) async {
    if (state is VideoFeedLoaded) {
      final currentState = state as VideoFeedLoaded;
      final videos = List<ShopVideo>.from(currentState.videos);
      
      final index = videos.indexWhere((v) => v.id == event.videoId);
      if (index == -1) return;

      final currentVideo = videos[index];
      
      // Optimistic update
      final isLikedNow = !currentVideo.isLiked;
      final newLikeCount = isLikedNow ? currentVideo.likeCount + 1 : currentVideo.likeCount - 1;
      
      videos[index] = ShopVideo(
        id: currentVideo.id,
        caption: currentVideo.caption,
        videoUrl: currentVideo.videoUrl,
        thumbnailUrl: currentVideo.thumbnailUrl,
        status: currentVideo.status,
        shopId: currentVideo.shopId,
        likeCount: newLikeCount < 0 ? 0 : newLikeCount,
        commentCount: currentVideo.commentCount,
        isLiked: isLikedNow,
        createdAt: currentVideo.createdAt,
        shop: currentVideo.shop,
        products: currentVideo.products,
      );
      
      emit(VideoFeedLoaded(videos, hasReachedMax: currentState.hasReachedMax));

      // Call API
      final result = await toggleLikeUseCase.call(event.videoId);

      // Revert if error
      result.fold(
        (failure) {
          videos[index] = currentVideo; // Revert to old state
          emit(VideoFeedLoaded(videos, hasReachedMax: currentState.hasReachedMax));
          // Có thể emit thêm lỗi để UI show snackbar ở đây nếu cần, nhưng thường Like toggle silent fail là ổn nhất.
        },
        (_) {}, // Success -> Keep optimistic state
      );
    }
  }
}
