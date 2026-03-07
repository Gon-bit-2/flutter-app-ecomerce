import 'package:flutter_test/flutter_test.dart';
import 'package:app_fe_ecomerce/features/payment/data/models/payment_config_model.dart';
import 'package:app_fe_ecomerce/features/payment/domain/entities/payment_config_entity.dart';

void main() {
  const tPaymentConfigModel = PaymentConfigModel(
    accountNumber: '123456789',
    bankCode: 'MB',
    prefix: 'SEPAY',
  );

  test('should be a subclass of PaymentConfigEntity', () async {
    // assert
    expect(tPaymentConfigModel, isA<PaymentConfigEntity>());
  });

  group('fromJson', () {
    test('should return a valid model when JSON is provided', () async {
      // arrange
      final Map<String, dynamic> jsonMap = {
        "accountNumber": "123456789",
        "bankCode": "MB",
        "prefix": "SEPAY",
      };
      // act
      final result = PaymentConfigModel.fromJson(jsonMap);
      // assert
      expect(result, equals(tPaymentConfigModel));
    });
  });

  group('toJson', () {
    test('should return a JSON map containing the proper data', () async {
      // act
      final result = tPaymentConfigModel.toJson();
      // assert
      final expectedMap = {
        "accountNumber": "123456789",
        "bankCode": "MB",
        "prefix": "SEPAY",
      };
      expect(result, equals(expectedMap));
    });
  });
}
