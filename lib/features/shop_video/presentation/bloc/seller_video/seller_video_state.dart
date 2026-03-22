import 'package:equatable/equatable.dart';
import '../../../domain/entities/shop_video.dart';

abstract class SellerVideoState extends Equatable {
  const SellerVideoState();

  @override
  List<Object?> get props => [];
}

class SellerVideoInitial extends SellerVideoState {}

class SellerVideosLoading extends SellerVideoState {
  final List<ShopVideo> oldVideos;
  final bool isFirstFetch;

  const SellerVideosLoading({this.oldVideos = const [], this.isFirstFetch = false});

  @override
  List<Object?> get props => [oldVideos, isFirstFetch];
}

class SellerVideosLoaded extends SellerVideoState {
  final List<ShopVideo> videos;
  final bool hasReachedMax;

  const SellerVideosLoaded(this.videos, {this.hasReachedMax = false});

  @override
  List<Object?> get props => [videos, hasReachedMax];
}

class SellerVideoActionLoading extends SellerVideoState {}

class CreateSellerVideoSuccess extends SellerVideoState {
  final ShopVideo video;

  const CreateSellerVideoSuccess(this.video);

  @override
  List<Object?> get props => [video];
}

class UpdateSellerVideoSuccess extends SellerVideoState {
  final ShopVideo video;

  const UpdateSellerVideoSuccess(this.video);

  @override
  List<Object?> get props => [video];
}

class DeleteSellerVideoSuccess extends SellerVideoState {
  final int videoId;

  const DeleteSellerVideoSuccess(this.videoId);

  @override
  List<Object?> get props => [videoId];
}

class SellerVideoError extends SellerVideoState {
  final String message;
  final List<ShopVideo>? oldVideos;

  const SellerVideoError(this.message, {this.oldVideos});

  @override
  List<Object?> get props => [message, oldVideos];
}
