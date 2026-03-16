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
        // Với COD: tự động chuyển trạng thái sang READY_TO_SHIP
        // Nếu BE từ chối thì seller sẽ xác nhận thủ công từ trang quản lý đơn hàng
        for (final order in orderResult.orders) {
          final updateResult = await repository.updateOrderStatus(order.id, 'READY_TO_SHIP');
          // Bỏ qua lỗi - seller có thể update thủ công nếu cần
          updateResult.fold(
            (failure) => null, // ignore error, seller will update manually
            (_) => null,
          );
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
