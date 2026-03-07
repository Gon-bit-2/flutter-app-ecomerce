// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment_config_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PaymentConfigModel _$PaymentConfigModelFromJson(Map<String, dynamic> json) =>
    PaymentConfigModel(
      accountNumber: json['accountNumber'] as String,
      bankCode: json['bankCode'] as String,
      prefix: json['prefix'] as String,
    );

Map<String, dynamic> _$PaymentConfigModelToJson(PaymentConfigModel instance) =>
    <String, dynamic>{
      'accountNumber': instance.accountNumber,
      'bankCode': instance.bankCode,
      'prefix': instance.prefix,
    };
