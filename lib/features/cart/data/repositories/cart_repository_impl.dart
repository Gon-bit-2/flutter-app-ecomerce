import 'package:app_fe_ecomerce/features/cart/domain/entities/cart_entity.dart';
import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../domain/repositories/cart_repository.dart';
import '../datasources/cart_remote_datasource.dart';

@LazySingleton(as: CartRepository)
class CartRepositoryImpl implements CartRepository {
  final CartRemoteDataSource remoteDataSource;

  CartRepositoryImpl(this.remoteDataSource);

  ServerFailure _handleError(DioException e) {
    try {
      if (e.response?.data != null) {
        final msg = e.response!.data['message'];
        if (msg is String) {
          return ServerFailure(msg);
        } else if (msg is List && msg.isNotEmpty) {
          final first = msg.first;
          if (first is Map && first.containsKey('message')) {
            return ServerFailure(first['message']);
          }
          return ServerFailure(msg.toString());
        }
      }
      return ServerFailure(e.message ?? "Unknown Error");
    } catch (_) {
      return ServerFailure(e.message ?? "Unknown Error");
    }
  }

  @override
  Future<Either<Failure, List<CartEntity>>> getCart({
    int? page,
    int? limit,
  }) async {
    try {
      final cartModels = await remoteDataSource.getCart(
        page: page,
        limit: limit,
      );
      return Right(cartModels);
    } on DioException catch (e) {
      return Left(_handleError(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, CartEntity>> addToCart({
    required int skuId,
    required int quantity,
  }) async {
    try {
      final cartModel = await remoteDataSource.addToCart(
        skuId: skuId,
        quantity: quantity,
      );
      return Right(cartModel);
    } on DioException catch (e) {
      return Left(_handleError(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> removeCartItems({
    required List<int> cartItemIds,
  }) async {
    try {
      await remoteDataSource.removeCartItems(cartItemIds: cartItemIds);
      return const Right(null);
    } on DioException catch (e) {
      return Left(_handleError(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateCart({
    required int id,
    required int quantity,
  }) async {
    try {
      await remoteDataSource.updateCart(id: id, quantity: quantity);
      return const Right(null);
    } on DioException catch (e) {
      return Left(_handleError(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
