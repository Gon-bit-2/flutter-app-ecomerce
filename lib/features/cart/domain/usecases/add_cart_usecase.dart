import 'package:app_fe_ecomerce/core/usecase/usecase.dart';
import 'package:app_fe_ecomerce/features/cart/domain/repositories/cart_repository.dart';
import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';

import '../entities/cart_entity.dart';

class AddCartUseCase implements UseCase<CartEntity, AddToCartParams> {
  final CartRepository _repository;

  AddCartUseCase(this._repository);

  // Ví dụ hàm gọi Lấy danh sách Giỏ hàng
  @override
  Future<Either<Failure, CartEntity>> call(AddToCartParams params) async {
    return await _repository.addToCart(
      quantity: params.quantity,
      skuId: params.skuId,
    );
  }
}

class AddToCartParams {
  final int skuId;
  final int quantity;

  AddToCartParams({required this.skuId, required this.quantity});
}
