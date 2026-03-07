import 'package:app_fe_ecomerce/core/error/failures.dart';
import 'package:app_fe_ecomerce/features/payment/data/datasources/payment_remote_datasource.dart';
import 'package:app_fe_ecomerce/features/payment/data/models/payment_config_model.dart';
import 'package:app_fe_ecomerce/features/payment/data/repositories/payment_repository_impl.dart';
import 'package:app_fe_ecomerce/features/payment/domain/entities/payment_config_entity.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'payment_repository_impl_test.mocks.dart';

@GenerateMocks([PaymentRemoteDataSource])
void main() {
  late PaymentRepositoryImpl repository;
  late MockPaymentRemoteDataSource mockRemoteDataSource;

  setUp(() {
    mockRemoteDataSource = MockPaymentRemoteDataSource();
    repository = PaymentRepositoryImpl(mockRemoteDataSource);
  });

  group('getPaymentConfig', () {
    const tPaymentConfigModel = PaymentConfigModel(
      accountNumber: '123456789',
      bankCode: 'MB',
      prefix: 'SEPAY',
    );

    const PaymentConfigEntity tPaymentConfigEntity = tPaymentConfigModel;

    test(
      'should return remote data when the call to remote data source is successful',
      () async {
        // arrange
        when(
          mockRemoteDataSource.getPaymentConfig(),
        ).thenAnswer((_) async => tPaymentConfigModel);
        // act
        final result = await repository.getPaymentConfig();
        // assert
        verify(mockRemoteDataSource.getPaymentConfig());
        expect(result, equals(const Right(tPaymentConfigEntity)));
      },
    );

    test(
      'should return server failure when the call to remote data source is unsuccessful with DioException',
      () async {
        // arrange
        when(mockRemoteDataSource.getPaymentConfig()).thenThrow(
          DioException(
            requestOptions: RequestOptions(path: ''),
            response: Response(
              statusCode: 404,
              requestOptions: RequestOptions(path: ''),
              data: {'message': 'Not found'},
            ),
          ),
        );
        // act
        final result = await repository.getPaymentConfig();
        // assert
        verify(mockRemoteDataSource.getPaymentConfig());
        expect(result, equals(const Left(ServerFailure('Not found'))));
      },
    );

    test(
      'should return server failure when there is a connection error',
      () async {
        // arrange
        when(mockRemoteDataSource.getPaymentConfig()).thenThrow(
          DioException(
            requestOptions: RequestOptions(path: ''),
            error: 'Connection timeout',
          ),
        );
        // act
        final result = await repository.getPaymentConfig();
        // assert
        verify(mockRemoteDataSource.getPaymentConfig());
        expect(
          result,
          equals(const Left(ServerFailure('Network connection error'))),
        );
      },
    );

    test(
      'should catch native exception and return string message string',
      () async {
        // arrange
        when(
          mockRemoteDataSource.getPaymentConfig(),
        ).thenThrow(Exception('Unknown Error'));
        // act
        final result = await repository.getPaymentConfig();
        // assert
        verify(mockRemoteDataSource.getPaymentConfig());
        expect(
          result,
          equals(const Left(ServerFailure('Exception: Unknown Error'))),
        );
      },
    );
  });
}
