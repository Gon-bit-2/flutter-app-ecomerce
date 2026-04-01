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
  @JsonKey(defaultValue: [])
  final List<ProductInfoModel> products;

  @override
  @JsonKey(defaultValue: 0)
  final int likeCount;

  @override
  @JsonKey(defaultValue: 0)
  final int commentCount;

  @override
  @JsonKey(defaultValue: false)
  final bool isLiked;

  const ShopVideoModel({
    required super.id,
    super.caption,
    required super.videoUrl,
    super.thumbnailUrl,
    required super.status,
    required super.shopId,
    this.likeCount = 0,
    this.commentCount = 0,
    this.isLiked = false,
    required super.createdAt,
    this.shop,
    this.products = const [],
  }) : super(
          shop: shop,
          products: products,
          likeCount: likeCount,
          commentCount: commentCount,
          isLiked: isLiked,
        );

  factory ShopVideoModel.fromJson(Map<String, dynamic> json) {
    // Xử lý an toàn cho response từ API khi tạo video mới
    // Backend có thể trả về thiếu một số trường trong response tạo mới
    final safeJson = <String, dynamic>{
      ...json,
      'likeCount': json['likeCount'] ?? 0,
      'commentCount': json['commentCount'] ?? 0,
      'isLiked': json['isLiked'] ?? false,
      'products': json['products'] ?? [],
    };
    return _$ShopVideoModelFromJson(safeJson);
  }

  Map<String, dynamic> toJson() => _$ShopVideoModelToJson(this);
}
