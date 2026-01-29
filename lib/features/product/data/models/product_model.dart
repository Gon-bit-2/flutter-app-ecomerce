import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/product.dart';
import 'sku_model.dart';

part 'product_model.g.dart';

@JsonSerializable(explicitToJson: true)
class ProductModel extends Product {
  @override
  final List<SKUModel> skus;

  const ProductModel({
    required super.id,
    required super.name,
    required super.basePrice,
    super.virtualPrice,
    required super.images,
    required super.brandId,
    super.publishedAt,
    this.skus = const [],
    super.variants,
    super.description,
    super.rating,
    super.sold,
    super.isMall,
    super.isPreferred,
  }) : super(skus: skus);

  factory ProductModel.fromJson(Map<String, dynamic> json) =>
      _$ProductModelFromJson(json);

  Map<String, dynamic> toJson() => _$ProductModelToJson(this);
}
