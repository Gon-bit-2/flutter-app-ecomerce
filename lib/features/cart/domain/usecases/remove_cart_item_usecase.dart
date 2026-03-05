import 'package:app_fe_ecomerce/core/usecase/usecase.dart';
import 'package:app_fe_ecomerce/features/cart/domain/repositories/cart_repository.dart';
import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';

@injectable
class RemoveCartItemUseCase implements UseCase<void, RemoveCartItemParams> {
  final CartRepository _repository;

  RemoveCartItemUseCase(this._repository);

  @override
  Future<Either<Failure, void>> call(RemoveCartItemParams params) async {
    return await _repository.removeCartItems(cartItemIds: params.cartItemIds);
  }
}

class RemoveCartItemParams {
  final List<int> cartItemIds;

  RemoveCartItemParams({required this.cartItemIds});
}
