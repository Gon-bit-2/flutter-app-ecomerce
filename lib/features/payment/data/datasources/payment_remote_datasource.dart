import 'package:app_fe_ecomerce/core/constants/app_constants.dart';
import 'package:app_fe_ecomerce/core/network/dio_client.dart';
import 'package:app_fe_ecomerce/features/payment/data/models/payment_config_model.dart';
import 'package:injectable/injectable.dart';

abstract class PaymentRemoteDataSource {
  Future<PaymentConfigModel> getPaymentConfig();
}

@LazySingleton(as: PaymentRemoteDataSource)
class PaymentRemoteDataSourceImpl implements PaymentRemoteDataSource {
  final DioClient _dioClient;

  PaymentRemoteDataSourceImpl(this._dioClient);

  @override
  Future<PaymentConfigModel> getPaymentConfig() async {
    final response = await _dioClient.get(AppConstants.paymentConfigEndpoint);
    return PaymentConfigModel.fromJson(response.data);
  }
}
