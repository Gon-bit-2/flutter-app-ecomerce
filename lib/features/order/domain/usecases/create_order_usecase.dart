import 'package:app_fe_ecomerce/core/error/failures.dart';
import 'package:app_fe_ecomerce/core/usecase/usecase.dart';
import 'package:app_fe_ecomerce/features/order/domain/entities/order_creation_result_entity.dart';
import 'package:app_fe_ecomerce/features/order/domain/repositories/order_repository.dart';
import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';

@injectable
class CreateOrderUseCase
    implements UseCase<OrderCreationResultEntity, CreateOrderParams> {
  final OrderRepository repository;

  CreateOrderUseCase(this.repository);

  @override
  Future<Either<Failure, OrderCreationResultEntity>> call(
    CreateOrderParams params,
  ) {
    return repository.createOrder(orders: params.orders);
  }
}

class CreateOrderParams {
  final List<ShopOrderParams> orders;

  const CreateOrderParams({required this.orders});
}

class ShopOrderParams {
  final int shopId;
  final ReceiverInfoParams receiver;
  final List<int> cartItemIds;

  const ShopOrderParams({
    required this.shopId,
    required this.receiver,
    required this.cartItemIds,
  });

  Map<String, dynamic> toJson() {
    return {
      'shopId': shopId,
      'receiver': {
        'name': receiver.name,
        'phone': receiver.phone,
        'address': receiver.address,
      },
      'cartItemIds': cartItemIds,
    };
  }
}

class ReceiverInfoParams {
  final String name;
  final String phone;
  final String address;

  const ReceiverInfoParams({
    required this.name,
    required this.phone,
    required this.address,
  });
}
