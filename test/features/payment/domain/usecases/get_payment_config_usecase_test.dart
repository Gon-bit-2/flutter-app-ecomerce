import 'package:app_fe_ecomerce/core/error/failures.dart';
import 'package:app_fe_ecomerce/core/usecase/usecase.dart';
import 'package:app_fe_ecomerce/features/payment/domain/entities/payment_config_entity.dart';
import 'package:app_fe_ecomerce/features/payment/domain/repositories/payment_repository.dart';
import 'package:app_fe_ecomerce/features/payment/domain/usecases/get_payment_config_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'get_payment_config_usecase_test.mocks.dart';

@GenerateMocks([PaymentRepository])
void main() {
  late GetPaymentConfigUseCase usecase;
  late MockPaymentRepository mockPaymentRepository;

  setUpAll(() {
    provideDummy<Either<Failure, PaymentConfigEntity>>(
      const Right(
        PaymentConfigEntity(accountNumber: '1', bankCode: '1', prefix: '1'),
      ),
    );
  });

  setUp(() {
    mockPaymentRepository = MockPaymentRepository();
    usecase = GetPaymentConfigUseCase(mockPaymentRepository);
  });

  const tPaymentConfig = PaymentConfigEntity(
    accountNumber: '123456789',
    bankCode: 'MB',
    prefix: 'SEPAY',
  );

  test('should get payment config from the repository', () async {
    // arrange
    when(
      mockPaymentRepository.getPaymentConfig(),
    ).thenAnswer((_) async => const Right(tPaymentConfig));
    // act
    final result = await usecase(NoParams());
    // assert
    expect(result, const Right(tPaymentConfig));
    verify(mockPaymentRepository.getPaymentConfig());
    verifyNoMoreInteractions(mockPaymentRepository);
  });

  test('should return a failure when getting payment config fails', () async {
    // arrange
    when(
      mockPaymentRepository.getPaymentConfig(),
    ).thenAnswer((_) async => const Left(ServerFailure('Lỗi')));
    // act
    final result = await usecase(NoParams());
    // assert
    expect(result, const Left(ServerFailure('Lỗi')));
    verify(mockPaymentRepository.getPaymentConfig());
    verifyNoMoreInteractions(mockPaymentRepository);
  });
}
