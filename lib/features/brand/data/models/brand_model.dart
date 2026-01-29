import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/brand.dart';

part 'brand_model.g.dart';

@JsonSerializable()
class BrandModel extends Brand {
  const BrandModel({
    required super.id,
    required super.name,
    required super.logo,
  });

  factory BrandModel.fromJson(Map<String, dynamic> json) =>
      _$BrandModelFromJson(json);

  Map<String, dynamic> toJson() => _$BrandModelToJson(this);
}
