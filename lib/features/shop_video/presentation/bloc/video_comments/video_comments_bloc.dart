import 'package:bloc/bloc.dart';
import 'package:injectable/injectable.dart';
import '../../../domain/entities/shop_video_comment.dart';
import '../../../domain/usecases/get_video_comments_use_case.dart';
import '../../../domain/usecases/add_video_comment_use_case.dart';

import 'video_comments_event.dart';
import 'video_comments_state.dart';

@injectable
class VideoCommentsBloc extends Bloc<VideoCommentsEvent, VideoCommentsState> {
  final GetVideoCommentsUseCase getVideoCommentsUseCase;
  final AddVideoCommentUseCase addVideoCommentUseCase;

  int _currentPage = 1;
  static const int _limit = 20;
  int _currentVideoId = -1;

  VideoCommentsBloc(this.getVideoCommentsUseCase, this.addVideoCommentUseCase)
      : super(VideoCommentsInitial()) {
    on<LoadVideoCommentsEvent>(_onLoadVideoComments);
    on<LoadMoreVideoCommentsEvent>(_onLoadMoreVideoComments);
    on<AddVideoCommentEvent>(_onAddVideoComment);
  }

  Future<void> _onLoadVideoComments(
    LoadVideoCommentsEvent event,
    Emitter<VideoCommentsState> emit,
  ) async {
    _currentVideoId = event.videoId;
    if (event.isRefresh) {
      _currentPage = 1;
    }

    emit(const VideoCommentsLoading([], isFirstFetch: true));

    final result = await getVideoCommentsUseCase.call(
      _currentVideoId,
      page: _currentPage,
      limit: _limit,
    );

    result.fold(
      (failure) => emit(VideoCommentsError(failure.message)),
      (comments) {
        bool hasReachedMax = comments.length < _limit;
        emit(VideoCommentsLoaded(comments, hasReachedMax: hasReachedMax));
      },
    );
  }

  Future<void> _onLoadMoreVideoComments(
    LoadMoreVideoCommentsEvent event,
    Emitter<VideoCommentsState> emit,
  ) async {
    if (state is VideoCommentsLoaded) {
      final currentState = state as VideoCommentsLoaded;
      if (currentState.hasReachedMax) return;

      emit(VideoCommentsLoading(currentState.comments));
      _currentPage++;

      final result = await getVideoCommentsUseCase.call(
        _currentVideoId,
        page: _currentPage,
        limit: _limit,
      );

      result.fold(
        (failure) {
          emit(VideoCommentsError(failure.message, oldComments: currentState.comments));
        },
        (comments) {
          bool hasReachedMax = comments.length < _limit;
          emit(VideoCommentsLoaded(
            [...currentState.comments, ...comments],
            hasReachedMax: hasReachedMax,
          ));
        },
      );
    }
  }

  Future<void> _onAddVideoComment(
    AddVideoCommentEvent event,
    Emitter<VideoCommentsState> emit,
  ) async {
    // Lưu lại comments hiện tại
    List<ShopVideoComment> currentComments = [];
    if (state is VideoCommentsLoaded) {
      currentComments = (state as VideoCommentsLoaded).comments;
    } else if (state is AddCommentSuccess) {
      currentComments = (state as AddCommentSuccess).comments;
    }

    // Hiển thị loading nhẹ hoặc giữ nguyên state (thường không cần loading để UX tốt hơn, hoặc show loading text input)
    
    final result = await addVideoCommentUseCase.call(
      _currentVideoId,
      content: event.content,
      parentId: event.parentId,
    );

    result.fold(
      (failure) {
        emit(VideoCommentsError(failure.message, oldComments: currentComments));
        // Reset về loaded
        emit(VideoCommentsLoaded(currentComments)); 
      },
      (newComment) {
        // Cập nhật list local
        // Nếu là comment gốc (không có parentId) thì chèn lên đầu
        // Nếu là reply (có parentId) thì chèn vào danh sách replies của parent tương ứng.
        final List<ShopVideoComment> updatedComments = List.from(currentComments);
        
        if (event.parentId == null) {
          updatedComments.insert(0, newComment);
        } else {
          // Tìm parent và thêm vào replies (đây là mảng phẳng hoặc lồng tùy giao diện, tạm lồng dựa theo schema API)
          final parentIndex = updatedComments.indexWhere((c) => c.id == event.parentId);
          if (parentIndex != -1) {
             // Entity gốc các list đang immutable (ví dụ dùng [] chứ ko phải List.of)
             // Tùy cách triển khai mà sẽ tạo Entity mới. 
             final parent = updatedComments[parentIndex];
             updatedComments[parentIndex] = ShopVideoComment(
               id: parent.id,
               content: parent.content,
               createdAt: parent.createdAt,
               user: parent.user,
               parentId: parent.parentId,
               replies: [newComment, ...parent.replies],
             );
          }
        }

        emit(AddCommentSuccess(newComment, updatedComments));
        // Quay lại trạng thái Loaded
        bool hasReachedMax = false;
        if (state is VideoCommentsLoaded) {
           hasReachedMax = (state as VideoCommentsLoaded).hasReachedMax;
        }
        emit(VideoCommentsLoaded(updatedComments, hasReachedMax: hasReachedMax));
      },
    );
  }
}
