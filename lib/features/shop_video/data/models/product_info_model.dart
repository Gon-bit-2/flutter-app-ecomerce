import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/product_info.dart';

part 'product_info_model.g.dart';

@JsonSerializable()
class ProductInfoModel extends ProductInfo {
  const ProductInfoModel({
    required super.id,
    required super.name,
    required super.basePrice,
    super.virtualPrice,
    super.images = const [],
    super.defaultSkuId,
    super.hasVariants = false,
  });

  factory ProductInfoModel.fromJson(Map<String, dynamic> json) =>
      _$ProductInfoModelFromJson(json);

  Map<String, dynamic> toJson() => _$ProductInfoModelToJson(this);
}
