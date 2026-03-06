import 'package:app_fe_ecomerce/core/error/failures.dart';
import 'package:app_fe_ecomerce/core/usecase/usecase.dart';
import 'package:app_fe_ecomerce/features/order/domain/entities/order_entity.dart';
import 'package:app_fe_ecomerce/features/order/domain/repositories/order_repository.dart';
import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';

@injectable
class GetOrderDetailUseCase implements UseCase<OrderEntity, int> {
  final OrderRepository repository;

  GetOrderDetailUseCase(this.repository);

  @override
  Future<Either<Failure, OrderEntity>> call(int id) {
    return repository.getOrderDetail(id);
  }
}
