import 'package:app_fe_ecomerce/features/cart/domain/entities/cart_entity.dart';
import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';

abstract class CartRepository {
  // Lấy giỏ hàng
  Future<Either<Failure, CartEntity>> getCart();

  // Thêm giỏ hàng
  Future<Either<Failure, CartEntity>> addToCart({
    required int skuId,
    required int quantity,
  });

  // Xóa giỏ hàng
  Future<Either<Failure, void>> removeFromCart({required int id});

  // Cập nhật giỏ hàng
  Future<Either<Failure, void>> updateCart({
    required int id,
    required int quantity,
  });
}
