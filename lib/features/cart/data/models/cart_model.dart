import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/cart_entity.dart';

part 'cart_model.g.dart';

@JsonSerializable()
class CartModel extends CartEntity {
  const CartModel({
    required super.id,
    required super.skuId,
    required super.quantity,
    super.productId,
    super.productName,
    super.image,
    super.skuValue,
    super.price,
    super.shopId,
  });

  // Lưu ý: Nếu API giỏ hàng trả về cấu trúc lồng nhau (nested JSON, ví dụ có object "sku" chứa "price"),
  // Bạn có thể cần custom lại hàm fromJson này thay vì dùng auto-generate của build_runner.
  factory CartModel.fromJson(Map<String, dynamic> json) =>
      _$CartModelFromJson(json);

  Map<String, dynamic> toJson() => _$CartModelToJson(this);
}
