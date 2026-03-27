// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shop_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ShopModel _$ShopModelFromJson(Map<String, dynamic> json) => ShopModel(
  id: (json['id'] as num).toInt(),
  name: json['name'] as String,
  description: json['description'] as String?,
  phoneNumber: json['phoneNumber'] as String?,
  address: json['address'] as String?,
  email: json['email'] as String?,
  avatar: json['avatar'] as String?,
  status: json['status'] as String,
);

Map<String, dynamic> _$ShopModelToJson(ShopModel instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'description': instance.description,
  'phoneNumber': instance.phoneNumber,
  'address': instance.address,
  'email': instance.email,
  'avatar': instance.avatar,
  'status': instance.status,
};
