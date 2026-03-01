import 'package:app_fe_ecomerce/features/cart/domain/entities/cart_entity.dart';
import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';

abstract class CartRepository {
  // Lấy giỏ hàng (Hỗ trợ phân trang)
  Future<Either<Failure, List<CartEntity>>> getCart({int? page, int? limit});

  // Thêm giỏ hàng
  Future<Either<Failure, CartEntity>> addToCart({
    required int skuId,
    required int quantity,
  });

  // Xóa sản phẩm khỏi giỏ hàng (1 hoặc nhiều sản phẩm)
  Future<Either<Failure, void>> removeCartItems({
    required List<int> cartItemIds,
  });

  // Cập nhật giỏ hàng
  Future<Either<Failure, void>> updateCart({
    required int id,
    required int quantity,
  });
}
