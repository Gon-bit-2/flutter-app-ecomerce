import 'package:equatable/equatable.dart';
import 'sku.dart';

class Product extends Equatable {
  final int id;
  final String name;
  final double basePrice;
  final double? virtualPrice; // For "Original Price" strike-through
  final List<String> images;
  final int brandId;
  final String? brandName;
  final List<int>? categoryIds;
  final DateTime? publishedAt;
  final List<SKU> skus;
  final List<dynamic>? variants; // Json type
  final String? description;

  // UI Calculated fields (Keep these as they are useful for frontend but maybe nullable if not provided)
  final double? rating;
  final int? sold;
  final bool isMall;
  final bool isPreferred;

  const Product({
    required this.id,
    required this.name,
    required this.basePrice,
    this.virtualPrice,
    required this.images,
    required this.brandId,
    this.brandName,
    this.categoryIds,
    this.publishedAt,
    this.skus = const [],
    this.variants,
    this.description,
    this.rating,
    this.sold,
    this.isMall = false,
    this.isPreferred = false,
  });

  @override
  List<Object?> get props => [
    id,
    name,
    basePrice,
    virtualPrice,
    images,
    brandId,
    brandName,
    categoryIds,
    publishedAt,
    skus,
    variants,
    description,
    rating,
    sold,
    isMall,
    isPreferred,
  ];
}
