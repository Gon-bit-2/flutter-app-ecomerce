import 'package:app_fe_ecomerce/core/usecase/usecase.dart';
import 'package:app_fe_ecomerce/features/cart/domain/repositories/cart_repository.dart';
import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';

@injectable
class UpdateCartUseCase implements UseCase<void, UpdateCartParams> {
  final CartRepository _repository;

  UpdateCartUseCase(this._repository);

  // Ví dụ hàm gọi Lấy danh sách Giỏ hàng
  @override
  Future<Either<Failure, void>> call(UpdateCartParams params) async {
    return await _repository.updateCart(
      id: params.id,
      quantity: params.quantity,
    );
  }
}

class UpdateCartParams {
  final int id;
  final int quantity;

  UpdateCartParams({required this.id, required this.quantity});
}
