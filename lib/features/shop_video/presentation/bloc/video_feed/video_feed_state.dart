import 'package:equatable/equatable.dart';
import '../../../domain/entities/shop_video.dart';

abstract class VideoFeedState extends Equatable {
  const VideoFeedState();

  @override
  List<Object?> get props => [];
}

class VideoFeedInitial extends VideoFeedState {}

class VideoFeedLoading extends VideoFeedState {
  final List<ShopVideo> oldVideos;
  final bool isFirstFetch;

  const VideoFeedLoading(this.oldVideos, {this.isFirstFetch = false});

  @override
  List<Object?> get props => [oldVideos, isFirstFetch];
}

class VideoFeedLoaded extends VideoFeedState {
  final List<ShopVideo> videos;
  final bool hasReachedMax;

  const VideoFeedLoaded(this.videos, {this.hasReachedMax = false});

  @override
  List<Object?> get props => [videos, hasReachedMax];
}

class VideoFeedError extends VideoFeedState {
  final String message;
  final List<ShopVideo>? oldVideos;

  const VideoFeedError(this.message, {this.oldVideos});

  @override
  List<Object?> get props => [message, oldVideos];
}
