import 'package:app_fe_ecomerce/core/error/failures.dart';
import 'package:app_fe_ecomerce/core/usecase/usecase.dart';
import 'package:app_fe_ecomerce/features/payment/domain/entities/payment_config_entity.dart';
import 'package:app_fe_ecomerce/features/payment/domain/repositories/payment_repository.dart';
import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';

@injectable
class GetPaymentConfigUseCase
    implements UseCase<PaymentConfigEntity, NoParams> {
  final PaymentRepository repository;

  GetPaymentConfigUseCase(this.repository);

  @override
  Future<Either<Failure, PaymentConfigEntity>> call(NoParams params) {
    return repository.getPaymentConfig();
  }
}
