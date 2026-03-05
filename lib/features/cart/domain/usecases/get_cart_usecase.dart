import 'package:app_fe_ecomerce/core/usecase/usecase.dart';
import 'package:app_fe_ecomerce/features/cart/domain/repositories/cart_repository.dart';
import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';

import '../entities/cart_entity.dart';

@injectable
class GetCartUseCase implements UseCase<List<CartEntity>, GetCartParams> {
  final CartRepository _repository;

  GetCartUseCase(this._repository);

  // Lấy danh sách Giỏ hàng
  @override
  Future<Either<Failure, List<CartEntity>>> call(GetCartParams params) async {
    return await _repository.getCart(page: params.page, limit: params.limit);
  }
}

class GetCartParams {
  final int? page;
  final int? limit;

  GetCartParams({this.page, this.limit});
}
