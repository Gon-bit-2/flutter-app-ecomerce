import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/shop_statistics.dart';
import '../repositories/shop_repository.dart';

@lazySingleton
class GetShopStatistics implements UseCase<ShopStatistics, NoParams> {
  final ShopRepository repository;

  GetShopStatistics(this.repository);

  @override
  Future<Either<Failure, ShopStatistics>> call(NoParams params) async {
    return await repository.getShopStatistics();
  }
}
