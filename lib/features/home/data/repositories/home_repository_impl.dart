import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/banner_entity.dart';
import '../../domain/entities/flash_sale_entity.dart';
import '../../domain/repositories/home_repository.dart';
import '../datasources/home_local_datasource.dart';

@LazySingleton(as: HomeRepository)
class HomeRepositoryImpl implements HomeRepository {
  final HomeLocalDataSource localDataSource;

  HomeRepositoryImpl(this.localDataSource);

  // Helper method for error handling not technically needed for local mock, but good practice if we add remote later
  ServerFailure _handleError(dynamic e) {
    return ServerFailure(e.toString());
  }

  @override
  Future<Either<Failure, List<BannerEntity>>> getBanners() async {
    try {
      final banners = await localDataSource.getBanners();
      return Right(banners);
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  @override
  Future<Either<Failure, FlashSaleEntity>> getFlashSale() async {
    try {
      final flashSale = await localDataSource.getFlashSale();
      return Right(flashSale);
    } catch (e) {
      return Left(_handleError(e));
    }
  }
}
