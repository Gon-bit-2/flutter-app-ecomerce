import 'package:app_fe_ecomerce/core/error/failures.dart';
import 'package:app_fe_ecomerce/core/usecase/usecase.dart';
import 'package:app_fe_ecomerce/features/order/domain/entities/order_entity.dart';
import 'package:app_fe_ecomerce/features/order/domain/repositories/order_repository.dart';
import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';

@injectable
class GetOrdersUseCase implements UseCase<List<OrderEntity>, GetOrdersParams> {
  final OrderRepository repository;

  GetOrdersUseCase(this.repository);

  @override
  Future<Either<Failure, List<OrderEntity>>> call(GetOrdersParams params) {
    return repository.getOrders(
      page: params.page,
      limit: params.limit,
      status: params.status,
    );
  }
}

class GetOrdersParams {
  final int page;
  final int limit;
  final String? status;

  const GetOrdersParams({this.page = 1, this.limit = 10, this.status});
}
