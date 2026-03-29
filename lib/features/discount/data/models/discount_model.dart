import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/discount.dart';

part 'discount_model.g.dart';

@JsonSerializable(explicitToJson: true)
class DiscountModel extends Discount {
  const DiscountModel({
    required super.id,
    super.shopId,
    super.productIds,
    super.categoryIds,
    required super.name,
    required super.value,
    super.maxDiscountValue,
    required super.type,
    required super.scope,
    required super.code,
    super.description,
    required super.maxTotalUses,
    required super.applyTo,
    required super.maxUsesPerUser,
    required super.minOrderValue,
    required super.isActive,
    required super.startDate,
    required super.endDate,
    super.userUsage,
    super.isSaved,
    super.isUsed,
  });

  factory DiscountModel.fromJson(Map<String, dynamic> json) =>
      _$DiscountModelFromJson(json);

  Map<String, dynamic> toJson() => _$DiscountModelToJson(this);
}
