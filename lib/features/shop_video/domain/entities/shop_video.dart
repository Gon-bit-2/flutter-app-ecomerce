import 'package:equatable/equatable.dart';
import 'product_info.dart';
import 'shop_info.dart';

enum ShopVideoStatus { ACTIVE, INACTIVE }

class ShopVideo extends Equatable {
  final int id;
  final String? caption;
  final String videoUrl;
  final String? thumbnailUrl;
  final ShopVideoStatus status;
  final int shopId;
  final int likeCount;
  final int commentCount;
  final bool isLiked;
  final DateTime createdAt;
  final ShopInfo? shop;
  final List<ProductInfo> products;

  const ShopVideo({
    required this.id,
    this.caption,
    required this.videoUrl,
    this.thumbnailUrl,
    required this.status,
    required this.shopId,
    this.likeCount = 0,
    this.commentCount = 0,
    this.isLiked = false,
    required this.createdAt,
    this.shop,
    this.products = const [],
  });

  @override
  List<Object?> get props => [
        id,
        caption,
        videoUrl,
        thumbnailUrl,
        status,
        shopId,
        likeCount,
        commentCount,
        isLiked,
        createdAt,
        shop,
        products,
      ];
}
