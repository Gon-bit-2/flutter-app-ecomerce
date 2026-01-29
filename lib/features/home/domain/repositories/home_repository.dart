import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../entities/banner_entity.dart';
import '../entities/flash_sale_entity.dart';

abstract class HomeRepository {
  Future<Either<Failure, List<BannerEntity>>> getBanners();
  Future<Either<Failure, FlashSaleEntity>> getFlashSale();
}
