import 'package:equatable/equatable.dart';

abstract class VideoCommentsEvent extends Equatable {
  const VideoCommentsEvent();

  @override
  List<Object?> get props => [];
}

class LoadVideoCommentsEvent extends VideoCommentsEvent {
  final int videoId;
  final bool isRefresh;

  const LoadVideoCommentsEvent(this.videoId, {this.isRefresh = false});

  @override
  List<Object?> get props => [videoId, isRefresh];
}

class LoadMoreVideoCommentsEvent extends VideoCommentsEvent {}

class AddVideoCommentEvent extends VideoCommentsEvent {
  final String content;
  final int? parentId;

  const AddVideoCommentEvent({required this.content, this.parentId});

  @override
  List<Object?> get props => [content, parentId];
}
