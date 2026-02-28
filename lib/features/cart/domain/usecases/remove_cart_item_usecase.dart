import 'package:app_fe_ecomerce/core/usecase/usecase.dart';
import 'package:app_fe_ecomerce/features/cart/domain/repositories/cart_repository.dart';
import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';

class RemoveCartItemUseCase implements UseCase<void, RemoveCartItemParams> {
  final CartRepository _repository;

  RemoveCartItemUseCase(this._repository);

  @override
  Future<Either<Failure, void>> call(RemoveCartItemParams params) async {
    return await _repository.removeFromCart(id: params.id);
  }
}

class RemoveCartItemParams {
  final int id;

  RemoveCartItemParams({required this.id});
}
