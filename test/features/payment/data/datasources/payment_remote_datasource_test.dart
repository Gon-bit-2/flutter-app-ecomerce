import 'dart:convert';
import 'package:app_fe_ecomerce/core/constants/app_constants.dart';
import 'package:app_fe_ecomerce/core/network/dio_client.dart';
import 'package:app_fe_ecomerce/features/payment/data/datasources/payment_remote_datasource.dart';
import 'package:app_fe_ecomerce/features/payment/data/models/payment_config_model.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'payment_remote_datasource_test.mocks.dart';

@GenerateMocks([DioClient])
void main() {
  late PaymentRemoteDataSourceImpl dataSource;
  late MockDioClient mockDioClient;

  setUp(() {
    mockDioClient = MockDioClient();
    dataSource = PaymentRemoteDataSourceImpl(mockDioClient);
  });

  group('getPaymentConfig', () {
    final tPaymentConfigModel = const PaymentConfigModel(
      accountNumber: '123456789',
      bankCode: 'MB',
      prefix: 'SEPAY',
    );

    final tJsonResponseStr = '''
      {
        "accountNumber": "123456789",
        "bankCode": "MB",
        "prefix": "SEPAY"
      }
    ''';
    final tJsonResponseMap = jsonDecode(tJsonResponseStr);

    test(
      'should perform a GET request on a URL with payment config endpoint',
      () async {
        // arrange
        when(mockDioClient.get(any)).thenAnswer(
          (_) async => Response(
            data: tJsonResponseMap,
            statusCode: 200,
            requestOptions: RequestOptions(path: ''),
          ),
        );
        // act
        dataSource.getPaymentConfig();
        // assert
        verify(mockDioClient.get(AppConstants.paymentConfigEndpoint));
      },
    );

    test(
      'should return PaymentConfigModel when the response code is 200',
      () async {
        // arrange
        when(mockDioClient.get(any)).thenAnswer(
          (_) async => Response(
            data: tJsonResponseMap,
            statusCode: 200,
            requestOptions: RequestOptions(path: ''),
          ),
        );
        // act
        final result = await dataSource.getPaymentConfig();
        // assert
        expect(result, equals(tPaymentConfigModel));
      },
    );

    test(
      'should throw a DioException when the response code is not 200',
      () async {
        // arrange
        when(mockDioClient.get(any)).thenThrow(
          DioException(
            requestOptions: RequestOptions(path: ''),
            error: 'Server Error',
            response: Response(
              statusCode: 404,
              requestOptions: RequestOptions(path: ''),
            ),
          ),
        );
        // act
        final call = dataSource.getPaymentConfig();
        // assert
        expect(() => call, throwsA(isA<DioException>()));
      },
    );
  });
}
