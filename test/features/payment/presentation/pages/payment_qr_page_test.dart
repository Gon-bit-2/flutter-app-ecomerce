import 'package:app_fe_ecomerce/features/payment/domain/entities/payment_config_entity.dart';
import 'package:app_fe_ecomerce/features/payment/domain/usecases/get_payment_config_usecase.dart';
import 'package:app_fe_ecomerce/features/payment/presentation/pages/payment_qr_page.dart';
import 'package:app_fe_ecomerce/core/error/failures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:get_it/get_it.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:network_image_mock/network_image_mock.dart';

import 'payment_qr_page_test.mocks.dart';

@GenerateMocks([GetPaymentConfigUseCase])
void main() {
  late MockGetPaymentConfigUseCase mockUseCase;

  setUpAll(() {
    provideDummy<Either<Failure, PaymentConfigEntity>>(
      const Right(
        PaymentConfigEntity(accountNumber: '1', bankCode: '1', prefix: '1'),
      ),
    );
  });

  setUp(() {
    mockUseCase = MockGetPaymentConfigUseCase();

    // Reset GetIt if it's already registered to avoid errors in multiple tests
    if (GetIt.I.isRegistered<GetPaymentConfigUseCase>()) {
      GetIt.I.unregister<GetPaymentConfigUseCase>();
    }
    GetIt.I.registerSingleton<GetPaymentConfigUseCase>(mockUseCase);
  });

  Widget createWidgetUnderTest() {
    return ScreenUtilInit(
      designSize: const Size(1080, 1920),
      builder: (context, child) => MaterialApp(
        home: PaymentQRPage(
          paymentId: 100,
          totalAmount: 50000,
          isTestingMode: true,
        ),
      ),
    );
  }

  const tPaymentConfig = PaymentConfigEntity(
    accountNumber: '0123456789',
    bankCode: 'VIETCOMBANK',
    prefix: 'SEPAY',
  );

  testWidgets('should display CircularProgressIndicator when loading', (
    WidgetTester tester,
  ) async {
    // arrange
    when(mockUseCase(any)).thenAnswer((_) async {
      // Add delay to keep it in loading state during render
      await Future.delayed(const Duration(milliseconds: 100));
      return const Right(tPaymentConfig);
    });
    // act
    await tester.pumpWidget(createWidgetUnderTest());
    // assert
    expect(find.byType(CircularProgressIndicator), findsWidgets);
    await tester.pump(const Duration(milliseconds: 200));
  });

  testWidgets('should display error message when usecase returns failure', (
    WidgetTester tester,
  ) async {
    // arrange
    when(
      mockUseCase(any),
    ).thenAnswer((_) async => const Left(ServerFailure('Lỗi mạng')));
    // act
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pump(const Duration(milliseconds: 200));
    // assert
    expect(find.text('Lỗi: Lỗi mạng'), findsOneWidget);
  });

  testWidgets(
    'should display QR Image and information correctly on successful config fetch',
    (WidgetTester tester) async {
      // arrange
      when(
        mockUseCase(any),
      ).thenAnswer((_) async => const Right(tPaymentConfig));

      await mockNetworkImagesFor(() async {
        // act
        await tester.pumpWidget(createWidgetUnderTest());
        await tester.pump(const Duration(milliseconds: 200));

        // assert
        // Màn hình QR Content được hiển thị
        expect(find.text('Quét mã QR để thanh toán'), findsOneWidget);

        // Custom info texts
        expect(find.text('VIETCOMBANK'), findsOneWidget);
        expect(find.text('0123456789'), findsOneWidget);
        expect(find.text('50000 đ'), findsOneWidget);
        expect(find.text('SEPAY100'), findsOneWidget); // prefix + paymentId

        // Verify Image loaded (QR Code) (Dùng icon vì đang isTestingMode)
        final iconFinder = find.byType(Icon);
        expect(iconFinder, findsWidgets);
      });
    },
  );
}
