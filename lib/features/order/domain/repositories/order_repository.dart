import 'package:app_fe_ecomerce/core/error/failures.dart';
import 'package:app_fe_ecomerce/features/order/domain/entities/order_creation_result_entity.dart';
import 'package:app_fe_ecomerce/features/order/domain/entities/order_entity.dart';
import 'package:app_fe_ecomerce/features/order/domain/usecases/create_order_usecase.dart';
import 'package:fpdart/fpdart.dart';

abstract class OrderRepository {
  Future<Either<Failure, List<OrderEntity>>> getOrders({
    int page = 1,
    int limit = 10,
    String? status,
  });

  Future<Either<Failure, OrderEntity>> getOrderDetail(int id);

  Future<Either<Failure, OrderCreationResultEntity>> createOrder({
    required List<ShopOrderParams> orders,
  });

  Future<Either<Failure, void>> cancelOrder(int id);
}
