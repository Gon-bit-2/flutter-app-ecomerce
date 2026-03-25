import 'package:equatable/equatable.dart';

class ProductInfo extends Equatable {
  final int id;
  final String name;
  final num basePrice;
  final num? virtualPrice;
  final List<String> images;
  final int? defaultSkuId;
  final bool hasVariants;

  const ProductInfo({
    required this.id,
    required this.name,
    required this.basePrice,
    this.virtualPrice,
    this.images = const [],
    this.defaultSkuId,
    this.hasVariants = false,
  });

  @override
  List<Object?> get props => [id, name, basePrice, virtualPrice, images, defaultSkuId, hasVariants];
}
