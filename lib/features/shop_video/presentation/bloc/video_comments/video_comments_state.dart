import 'package:equatable/equatable.dart';
import '../../../domain/entities/shop_video_comment.dart';

abstract class VideoCommentsState extends Equatable {
  const VideoCommentsState();

  @override
  List<Object?> get props => [];
}

class VideoCommentsInitial extends VideoCommentsState {}

class VideoCommentsLoading extends VideoCommentsState {
  final List<ShopVideoComment> oldComments;
  final bool isFirstFetch;

  const VideoCommentsLoading(this.oldComments, {this.isFirstFetch = false});

  @override
  List<Object?> get props => [oldComments, isFirstFetch];
}

class VideoCommentsLoaded extends VideoCommentsState {
  final List<ShopVideoComment> comments;
  final bool hasReachedMax;

  const VideoCommentsLoaded(this.comments, {this.hasReachedMax = false});

  @override
  List<Object?> get props => [comments, hasReachedMax];
}

class AddCommentSuccess extends VideoCommentsState {
  final ShopVideoComment newComment;
  // Giữ lại list cũ để UI tự render mượt mà nếu cần phối hợp với state Loaded trước đó
  final List<ShopVideoComment> comments; 

  const AddCommentSuccess(this.newComment, this.comments);

  @override
  List<Object?> get props => [newComment, comments];
}

class VideoCommentsError extends VideoCommentsState {
  final String message;
  final List<ShopVideoComment>? oldComments;

  const VideoCommentsError(this.message, {this.oldComments});

  @override
  List<Object?> get props => [message, oldComments];
}
