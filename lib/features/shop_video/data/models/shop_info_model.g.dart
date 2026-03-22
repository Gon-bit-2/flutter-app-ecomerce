// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shop_info_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ShopInfoModel _$ShopInfoModelFromJson(Map<String, dynamic> json) =>
    ShopInfoModel(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      avatar: json['avatar'] as String?,
    );

Map<String, dynamic> _$ShopInfoModelToJson(ShopInfoModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'avatar': instance.avatar,
    };
