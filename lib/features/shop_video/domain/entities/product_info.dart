import 'package:equatable/equatable.dart';

class ProductInfo extends Equatable {
  final int id;
  final String name;
  final num basePrice;
  final num? virtualPrice;
  final List<String> images;

  const ProductInfo({
    required this.id,
    required this.name,
    required this.basePrice,
    this.virtualPrice,
    this.images = const [],
  });

  @override
  List<Object?> get props => [id, name, basePrice, virtualPrice, images];
}
