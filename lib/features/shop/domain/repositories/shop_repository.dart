import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../entities/shop_entity.dart';
import '../entities/shop_statistics.dart';

abstract class ShopRepository {
  Future<Either<Failure, void>> registerShop({
    required String name,
    required String description,
    required String phoneNumber,
    required String address,
    required String email,
  });

  Future<Either<Failure, ShopEntity?>> getMyShop();

  Future<Either<Failure, ShopStatistics>> getShopStatistics();
}
