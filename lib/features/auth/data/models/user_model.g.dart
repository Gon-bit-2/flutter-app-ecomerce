// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserModel _$UserModelFromJson(Map<String, dynamic> json) => UserModel(
  id: (json['id'] as num).toInt(),
  email: json['email'] as String,
  name: json['name'] as String,
  phoneNumber: json['phoneNumber'] as String?,
  avatar: json['avatar'] as String?,
  roleId: (json['roleId'] as num?)?.toInt(),
  totpSecret: json['totpSecret'] as String?,
);

Map<String, dynamic> _$UserModelToJson(UserModel instance) => <String, dynamic>{
  'id': instance.id,
  'email': instance.email,
  'name': instance.name,
  'phoneNumber': instance.phoneNumber,
  'avatar': instance.avatar,
  'roleId': instance.roleId,
  'totpSecret': instance.totpSecret,
};
