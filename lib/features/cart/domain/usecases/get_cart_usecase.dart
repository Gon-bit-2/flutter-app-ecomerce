import 'package:app_fe_ecomerce/core/usecase/usecase.dart';
import 'package:app_fe_ecomerce/features/cart/domain/repositories/cart_repository.dart';
import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';

import '../entities/cart_entity.dart';

class GetCartUseCase implements UseCase<CartEntity, NoParams> {
  final CartRepository _repository;

  GetCartUseCase(this._repository);

  // Ví dụ hàm gọi Lấy danh sách Giỏ hàng
  @override
  Future<Either<Failure, CartEntity>> call(NoParams params) async {
    return await _repository.getCart();
  }
}
