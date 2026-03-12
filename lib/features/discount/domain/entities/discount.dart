import 'package:equatable/equatable.dart';

enum DiscountType { FIXED_AMOUNT, PERCENTAGE, SHIPPING }

enum DiscountScope { PLATFORM, SHOP }

enum DiscountApplyTo { ALL, SPECIFIC }

class Discount extends Equatable {
  final int id;
  final int? shopId;
  final List<int>? productIds;
  final List<int>? categoryIds;
  final String name;
  final double value;
  final double? maxDiscountValue;
  final DiscountType type;
  final DiscountScope scope;
  final String code;
  final String? description;
  final int maxTotalUses;
  final DiscountApplyTo applyTo;
  final int maxUsesPerUser;
  final double minOrderValue;
  final bool isActive;
  final DateTime startDate;
  final DateTime endDate;

  const Discount({
    required this.id,
    this.shopId,
    this.productIds,
    this.categoryIds,
    required this.name,
    required this.value,
    this.maxDiscountValue,
    required this.type,
    required this.scope,
    required this.code,
    this.description,
    required this.maxTotalUses,
    required this.applyTo,
    required this.maxUsesPerUser,
    required this.minOrderValue,
    required this.isActive,
    required this.startDate,
    required this.endDate,
  });

  @override
  List<Object?> get props => [
    id,
    shopId,
    productIds,
    categoryIds,
    name,
    value,
    maxDiscountValue,
    type,
    scope,
    code,
    description,
    maxTotalUses,
    applyTo,
    maxUsesPerUser,
    minOrderValue,
    isActive,
    startDate,
    endDate,
  ];
}
