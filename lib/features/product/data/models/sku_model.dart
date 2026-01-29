import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/sku.dart';

part 'sku_model.g.dart';

@JsonSerializable()
class SKUModel extends SKU {
  const SKUModel({
    required super.id,
    required super.value,
    required super.price,
    required super.stock,
    required super.image,
    required super.productId,
  });

  factory SKUModel.fromJson(Map<String, dynamic> json) =>
      _$SKUModelFromJson(json);

  Map<String, dynamic> toJson() => _$SKUModelToJson(this);
}
