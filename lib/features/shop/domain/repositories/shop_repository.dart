import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/shop_entity.dart';

abstract class ShopRepository {
  Future<Either<Failure, void>> registerShop({
    required String name,
    required String description,
    required String phoneNumber,
    required String address,
    required String email,
  });

  Future<Either<Failure, ShopEntity?>> getMyShop();
}
