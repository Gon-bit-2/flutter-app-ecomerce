import 'package:app_fe_ecomerce/core/error/failures.dart';
import 'package:app_fe_ecomerce/features/payment/data/datasources/payment_remote_datasource.dart';
import 'package:app_fe_ecomerce/features/payment/domain/entities/payment_config_entity.dart';
import 'package:app_fe_ecomerce/features/payment/domain/repositories/payment_repository.dart';
import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: PaymentRepository)
class PaymentRepositoryImpl implements PaymentRepository {
  final PaymentRemoteDataSource remoteDataSource;

  PaymentRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, PaymentConfigEntity>> getPaymentConfig() async {
    try {
      final config = await remoteDataSource.getPaymentConfig();
      return right(config);
    } on DioException catch (e) {
      if (e.response != null) {
        return left(
          ServerFailure(
            e.response?.data['message'] ?? 'Unable to get payment config',
          ),
        );
      }
      return left(const ServerFailure('Network connection error'));
    } catch (e) {
      return left(ServerFailure(e.toString()));
    }
  }
}
