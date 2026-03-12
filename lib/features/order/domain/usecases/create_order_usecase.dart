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
  ) async {
    final result = await repository.createOrder(orders: params.orders);

    if (result.isRight()) {
      final orderResult = result.getOrElse((l) => throw Exception());
      final isCod = params.orders.any((o) => o.paymentMethod == 'COD');
      
      if (isCod) {
        for (final order in orderResult.orders) {
          await repository.updateOrderStatus(order.id, 'PENDING_PICKUP');
        }
      }
      return right(orderResult);
    }

    return result;
  }
}

class CreateOrderParams {
  final List<ShopOrderParams> orders;

  const CreateOrderParams({required this.orders});
}

class ShopOrderParams {
  final int shopId;
  final ReceiverInfoParams? receiver;
  final int? userAddressId;
  final List<int> cartItemIds;
  final String? paymentMethod;

  const ShopOrderParams({
    required this.shopId,
    this.receiver,
    this.userAddressId,
    required this.cartItemIds,
    this.paymentMethod,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'shopId': shopId,
      'cartItemIds': cartItemIds,
    };

    if (userAddressId != null) {
      data['userAddressId'] = userAddressId;
    } else if (receiver != null) {
      data['receiver'] = {
        'name': receiver!.name,
        'phone': receiver!.phone,
        'address': receiver!.address,
      };
    }

    if (paymentMethod != null) {
      data['paymentMethod'] = paymentMethod;
    }

    return data;
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
