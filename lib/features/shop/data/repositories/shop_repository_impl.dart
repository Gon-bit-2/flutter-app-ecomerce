import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/shop_entity.dart';
import '../../domain/repositories/shop_repository.dart';
import '../datasources/shop_remote_datasource.dart';

@LazySingleton(as: ShopRepository)
class ShopRepositoryImpl implements ShopRepository {
  final ShopRemoteDataSource remoteDataSource;

  ShopRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, void>> registerShop({
    required String name,
    required String description,
    required String phoneNumber,
    required String address,
    required String email,
  }) async {
    try {
      await remoteDataSource.registerShop(
        name: name,
        description: description,
        phoneNumber: phoneNumber,
        address: address,
        email: email,
      );
      return const Right(null);
    } on DioException catch (e) {
      if (e.response != null) {
        return Left(
          ServerFailure(
            e.response?.data['message'] ?? 'Lỗi khi đăng ký shop',
          ),
        );
      } else {
        return Left(ServerFailure(e.message ?? 'Lỗi kết nối máy chủ'));
      }
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, ShopEntity?>> getMyShop() async {
    try {
      final shopData = await remoteDataSource.getMyShop();
      return Right(shopData);
    } on DioException catch (e) {
      if (e.response != null) {
        return Left(
          ServerFailure(
            e.response?.data['message'] ?? 'Lỗi khi lấy thông tin shop',
          ),
        );
      } else {
        return Left(ServerFailure(e.message ?? 'Lỗi kết nối máy chủ'));
      }
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
