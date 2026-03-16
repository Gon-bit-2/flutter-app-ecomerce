import 'package:app_fe_ecomerce/core/error/failures.dart';
import 'package:app_fe_ecomerce/core/usecase/usecase.dart';
import 'package:app_fe_ecomerce/features/order/domain/repositories/order_repository.dart';
import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';

@injectable
class UpdateOrderStatusUseCase implements UseCase<void, UpdateOrderStatusParams> {
  final OrderRepository repository;

  UpdateOrderStatusUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(UpdateOrderStatusParams params) async {
    return await repository.updateOrderStatus(params.orderId, params.status);
  }
}

class UpdateOrderStatusParams {
  final int orderId;
  final String status;

  const UpdateOrderStatusParams({required this.orderId, required this.status});
}
