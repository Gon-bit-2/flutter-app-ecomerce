import 'package:equatable/equatable.dart';

abstract class VideoFeedEvent extends Equatable {
  const VideoFeedEvent();

  @override
  List<Object?> get props => [];
}

class LoadVideoFeedEvent extends VideoFeedEvent {
  final bool isRefresh;
  final int? shopId;

  const LoadVideoFeedEvent({this.isRefresh = false, this.shopId});

  @override
  List<Object?> get props => [isRefresh, shopId];
}

class LoadMoreVideoFeedEvent extends VideoFeedEvent {}

class ToggleLikeVideoEvent extends VideoFeedEvent {
  final int videoId;

  const ToggleLikeVideoEvent(this.videoId);

  @override
  List<Object?> get props => [videoId];
}
