import 'dart:io';
import 'package:equatable/equatable.dart';

abstract class SellerVideoEvent extends Equatable {
  const SellerVideoEvent();

  @override
  List<Object?> get props => [];
}

class LoadMyVideosEvent extends SellerVideoEvent {
  final int shopId;
  final bool isRefresh;

  const LoadMyVideosEvent({required this.shopId, this.isRefresh = false});

  @override
  List<Object?> get props => [shopId, isRefresh];
}

class LoadMoreMyVideosEvent extends SellerVideoEvent {}

class CreateSellerVideoEvent extends SellerVideoEvent {
  final File video;
  final String? caption;
  final String? thumbnailUrl;
  final List<int>? productIds;

  const CreateSellerVideoEvent({
    required this.video,
    this.caption,
    this.thumbnailUrl,
    this.productIds,
  });

  @override
  List<Object?> get props => [video, caption, thumbnailUrl, productIds];
}

class UpdateSellerVideoEvent extends SellerVideoEvent {
  final int id;
  final Map<String, dynamic> data;

  const UpdateSellerVideoEvent(this.id, this.data);

  @override
  List<Object?> get props => [id, data];
}

class DeleteSellerVideoEvent extends SellerVideoEvent {
  final int id;

  const DeleteSellerVideoEvent(this.id);

  @override
  List<Object?> get props => [id];
}
