import 'package:equatable/equatable.dart';

class CartEntity extends Equatable {
  final int id; // ID của item trong giỏ hàng (Để gọi API xóa / cập nhật)
  final int skuId; // ID của phân loại sản phẩm
  final int quantity; // Số lượng

  // Các trường bổ sung thường được API join từ bảng Product/SKU để hiển thị
  final int? productId;
  final String? productName;
  final String? image;
  final String? skuValue; // Ví dụ: Màu Đỏ - Size M
  final num? price;
  final int? shopId; // ID của shop sở hữu sản phẩm
  final int? availableStock; // Tồn kho hiện tại của SKU

  const CartEntity({
    required this.id,
    required this.skuId,
    required this.quantity,
    this.productId,
    this.productName,
    this.image,
    this.skuValue,
    this.price,
    this.shopId,
    this.availableStock,
  });

  @override
  List<Object?> get props => [
    id,
    skuId,
    quantity,
    productId,
    productName,
    image,
    skuValue,
    price,
    shopId,
    availableStock,
  ];

  CartEntity copyWith({
    int? id,
    int? skuId,
    int? quantity,
    int? productId,
    String? productName,
    String? image,
    String? skuValue,
    num? price,
    int? shopId,
    int? availableStock,
  }) {
    return CartEntity(
      id: id ?? this.id,
      skuId: skuId ?? this.skuId,
      quantity: quantity ?? this.quantity,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      image: image ?? this.image,
      skuValue: skuValue ?? this.skuValue,
      price: price ?? this.price,
      shopId: shopId ?? this.shopId,
      availableStock: availableStock ?? this.availableStock,
    );
  }
}
