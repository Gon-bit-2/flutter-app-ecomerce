// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'discount_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DiscountModel _$DiscountModelFromJson(Map<String, dynamic> json) =>
    DiscountModel(
      id: (json['id'] as num).toInt(),
      shopId: (json['shopId'] as num?)?.toInt(),
      productIds: (json['productIds'] as List<dynamic>?)
          ?.map((e) => (e as num).toInt())
          .toList(),
      categoryIds: (json['categoryIds'] as List<dynamic>?)
          ?.map((e) => (e as num).toInt())
          .toList(),
      name: json['name'] as String,
      value: (json['value'] as num).toDouble(),
      maxDiscountValue: (json['maxDiscountValue'] as num?)?.toDouble(),
      type: $enumDecode(_$DiscountTypeEnumMap, json['type']),
      scope: $enumDecode(_$DiscountScopeEnumMap, json['scope']),
      code: json['code'] as String,
      description: json['description'] as String?,
      maxTotalUses: (json['maxTotalUses'] as num).toInt(),
      applyTo: $enumDecode(_$DiscountApplyToEnumMap, json['applyTo']),
      maxUsesPerUser: (json['maxUsesPerUser'] as num).toInt(),
      minOrderValue: (json['minOrderValue'] as num).toDouble(),
      isActive: json['isActive'] as bool,
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
    );

Map<String, dynamic> _$DiscountModelToJson(DiscountModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'shopId': instance.shopId,
      'productIds': instance.productIds,
      'categoryIds': instance.categoryIds,
      'name': instance.name,
      'value': instance.value,
      'maxDiscountValue': instance.maxDiscountValue,
      'type': _$DiscountTypeEnumMap[instance.type]!,
      'scope': _$DiscountScopeEnumMap[instance.scope]!,
      'code': instance.code,
      'description': instance.description,
      'maxTotalUses': instance.maxTotalUses,
      'applyTo': _$DiscountApplyToEnumMap[instance.applyTo]!,
      'maxUsesPerUser': instance.maxUsesPerUser,
      'minOrderValue': instance.minOrderValue,
      'isActive': instance.isActive,
      'startDate': instance.startDate.toIso8601String(),
      'endDate': instance.endDate.toIso8601String(),
    };

const _$DiscountTypeEnumMap = {
  DiscountType.FIXED_AMOUNT: 'FIXED_AMOUNT',
  DiscountType.PERCENTAGE: 'PERCENTAGE',
  DiscountType.SHIPPING: 'SHIPPING',
};

const _$DiscountScopeEnumMap = {
  DiscountScope.PLATFORM: 'PLATFORM',
  DiscountScope.SHOP: 'SHOP',
};

const _$DiscountApplyToEnumMap = {
  DiscountApplyTo.ALL: 'ALL',
  DiscountApplyTo.SPECIFIC: 'SPECIFIC',
};
