import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/shop_entity.dart';

part 'shop_model.g.dart';

@JsonSerializable()
class ShopModel extends ShopEntity {
  const ShopModel({
    required super.id,
    required super.name,
    super.description,
    super.phoneNumber,
    super.address,
    super.email,
    super.avatar,
    required super.status,
  });

  factory ShopModel.fromJson(Map<String, dynamic> json) =>
      _$ShopModelFromJson(json);

  Map<String, dynamic> toJson() => _$ShopModelToJson(this);
}
