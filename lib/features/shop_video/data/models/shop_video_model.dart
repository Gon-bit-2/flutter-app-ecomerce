import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/shop_video.dart';
import 'shop_info_model.dart';
import 'product_info_model.dart';

part 'shop_video_model.g.dart';

@JsonSerializable(explicitToJson: true)
class ShopVideoModel extends ShopVideo {
  @override
  final ShopInfoModel? shop;

  @override
  final List<ProductInfoModel> products;

  const ShopVideoModel({
    required super.id,
    super.caption,
    required super.videoUrl,
    super.thumbnailUrl,
    required super.status,
    required super.shopId,
    super.likeCount = 0,
    super.commentCount = 0,
    super.isLiked = false,
    required super.createdAt,
    this.shop,
    this.products = const [],
  }) : super(shop: shop, products: products);

  factory ShopVideoModel.fromJson(Map<String, dynamic> json) =>
      _$ShopVideoModelFromJson(json);

  Map<String, dynamic> toJson() => _$ShopVideoModelToJson(this);
}
