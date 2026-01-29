import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/brand.dart';
import '../../domain/repositories/brand_repository.dart';
import '../datasources/brand_remote_datasource.dart';

@LazySingleton(as: BrandRepository)
class BrandRepositoryImpl implements BrandRepository {
  final BrandRemoteDataSource remoteDataSource;

  BrandRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, List<Brand>>> getBrands() async {
    try {
      final brands = await remoteDataSource.getBrands();
      return Right(brands);
    } on DioException catch (e) {
      // Basic error handling similar to other repos
      return Left(ServerFailure(e.message ?? "Unknown Error"));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
