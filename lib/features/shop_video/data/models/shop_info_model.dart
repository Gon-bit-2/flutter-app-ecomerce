import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/shop_info.dart';

part 'shop_info_model.g.dart';

@JsonSerializable()
class ShopInfoModel extends ShopInfo {
  const ShopInfoModel({
    required super.id,
    required super.name,
    super.avatar,
  });

  factory ShopInfoModel.fromJson(Map<String, dynamic> json) =>
      _$ShopInfoModelFromJson(json);

  Map<String, dynamic> toJson() => _$ShopInfoModelToJson(this);
}
