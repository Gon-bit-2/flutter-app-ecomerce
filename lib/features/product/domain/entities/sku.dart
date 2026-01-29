import 'package:equatable/equatable.dart';

class SKU extends Equatable {
  final int id;
  final String value;
  final double price;
  final int stock;
  final String image;
  final int productId;

  const SKU({
    required this.id,
    required this.value,
    required this.price,
    required this.stock,
    required this.image,
    required this.productId,
  });

  @override
  List<Object?> get props => [id, value, price, stock, image, productId];
}
