import 'package:app_fe_ecomerce/core/error/failures.dart';
import 'package:app_fe_ecomerce/features/payment/domain/entities/payment_config_entity.dart';
import 'package:fpdart/fpdart.dart';

abstract class PaymentRepository {
  Future<Either<Failure, PaymentConfigEntity>> getPaymentConfig();
}
