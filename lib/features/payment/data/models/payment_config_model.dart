import 'package:json_annotation/json_annotation.dart';
import 'package:app_fe_ecomerce/features/payment/domain/entities/payment_config_entity.dart';

part 'payment_config_model.g.dart';

@JsonSerializable()
class PaymentConfigModel extends PaymentConfigEntity {
  const PaymentConfigModel({
    required super.accountNumber,
    required super.bankCode,
    required super.prefix,
  });

  factory PaymentConfigModel.fromJson(Map<String, dynamic> json) =>
      _$PaymentConfigModelFromJson(json);

  Map<String, dynamic> toJson() => _$PaymentConfigModelToJson(this);
}
