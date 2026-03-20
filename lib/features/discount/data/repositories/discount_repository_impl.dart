import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/discount.dart';
import '../../domain/repositories/discount_repository.dart';
import '../datasources/discount_remote_datasource.dart';

@LazySingleton(as: DiscountRepository)
class DiscountRepositoryImpl implements DiscountRepository {
  final DiscountRemoteDataSource remoteDataSource;

  DiscountRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<Discount>>> getMyVouchers({
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final models = await remoteDataSource.getMyVouchers(
        page: page,
        limit: limit,
      );
      return Right(models);
    } on DioException catch (e) {
      return Left(
        ServerFailure(
          _parseErrorMessage(e.response?.data['message']) ??
              e.message ??
              'An error occurred fetching user vouchers',
        ),
      );
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Discount>>> getAvailableDiscounts({
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final models = await remoteDataSource.getAvailableDiscounts(
        page: page,
        limit: limit,
      );
      return Right(models);
    } on DioException catch (e) {
      return Left(
        ServerFailure(
          _parseErrorMessage(e.response?.data['message']) ??
              e.message ??
              'An error occurred fetching available vouchers',
        ),
      );
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> previewDiscount({
    required String code,
    required double orderValue,
    double shippingFee = 0,
    required int userId,
    required int shopId,
    required List<Map<String, dynamic>> items,
  }) async {
    try {
      final result = await remoteDataSource.previewDiscount(
        code: code,
        orderValue: orderValue,
        shippingFee: shippingFee,
        userId: userId,
        shopId: shopId,
        items: items,
      );
      return Right(result);
    } on DioException catch (e) {
      return Left(
        ServerFailure(
          _parseErrorMessage(e.response?.data['message']) ??
              e.message ??
              'An error occurred during discount preview',
        ),
      );
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Discount>>> getDiscountsByAdmin({
    int page = 1,
    int limit = 10,
    int? shopId,
    String? type,
    String? scope,
    bool? isActive,
    String? search,
  }) async {
    try {
      final models = await remoteDataSource.getDiscountsByAdmin(
        page: page,
        limit: limit,
        shopId: shopId,
        type: type,
        scope: scope,
        isActive: isActive,
        search: search,
      );
      return Right(models);
    } on DioException catch (e) {
      return Left(
        ServerFailure(
          _parseErrorMessage(e.response?.data['message']) ??
              e.message ??
              'An error occurred getting admin discounts',
        ),
      );
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Discount>> getDiscountDetail(int discountId) async {
    try {
      final model = await remoteDataSource.getDiscountDetail(discountId);
      return Right(model);
    } on DioException catch (e) {
      return Left(
        ServerFailure(
          _parseErrorMessage(e.response?.data['message']) ??
              e.message ??
              'An error occurred getting discount detail',
        ),
      );
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Discount>> createDiscount(
    Map<String, dynamic> data,
  ) async {
    try {
      final model = await remoteDataSource.createDiscount(data);
      return Right(model);
    } on DioException catch (e) {
      return Left(
        ServerFailure(
          _parseErrorMessage(e.response?.data['message']) ??
              e.message ??
              'An error occurred creating discount',
        ),
      );
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Discount>> updateDiscount(
    int discountId,
    Map<String, dynamic> data,
  ) async {
    try {
      final model = await remoteDataSource.updateDiscount(discountId, data);
      return Right(model);
    } on DioException catch (e) {
      return Left(
        ServerFailure(
          _parseErrorMessage(e.response?.data['message']) ??
              e.message ??
              'An error occurred updating discount',
        ),
      );
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteDiscount(int discountId) async {
    try {
      await remoteDataSource.deleteDiscount(discountId);
      return const Right(null);
    } on DioException catch (e) {
      return Left(
        ServerFailure(
          _parseErrorMessage(e.response?.data['message']) ??
              e.message ??
              'An error occurred deleting discount',
        ),
      );
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> saveDiscount(int discountId) async {
    try {
      await remoteDataSource.saveDiscount(discountId);
      return const Right(null);
    } on DioException catch (e) {
      return Left(
        ServerFailure(
          _parseErrorMessage(e.response?.data['message']) ??
              e.message ??
              'Lưu voucher thất bại',
        ),
      );
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  String? _parseErrorMessage(dynamic messageData) {
    if (messageData == null) return null;
    if (messageData is String) return messageData;
    if (messageData is List) {
      return messageData
          .map((e) {
            if (e is Map && e.containsKey('message')) {
              return e['message'].toString();
            }
            return e.toString();
          })
          .join('\n');
    }
    return messageData.toString();
  }
}
