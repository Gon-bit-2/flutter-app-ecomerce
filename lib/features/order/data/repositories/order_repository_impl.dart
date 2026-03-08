import 'package:app_fe_ecomerce/core/error/failures.dart';
import 'package:app_fe_ecomerce/features/order/data/datasources/order_remote_datasource.dart';
import 'package:app_fe_ecomerce/features/order/domain/entities/order_creation_result_entity.dart';
import 'package:app_fe_ecomerce/features/order/domain/entities/order_entity.dart';
import 'package:app_fe_ecomerce/features/order/domain/repositories/order_repository.dart';
import 'package:app_fe_ecomerce/features/order/domain/usecases/create_order_usecase.dart';
import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: OrderRepository)
class OrderRepositoryImpl implements OrderRepository {
  final OrderRemoteDataSource remoteDataSource;

  OrderRepositoryImpl(this.remoteDataSource);

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
  Future<Either<Failure, List<OrderEntity>>> getOrders({
    int page = 1,
    int limit = 10,
    String? status,
  }) async {
    try {
      final orders = await remoteDataSource.getOrders(
        page: page,
        limit: limit,
        status: status,
      );
      return Right(orders);
    } on DioException catch (e) {
      return Left(_handleError(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, OrderEntity>> getOrderDetail(int id) async {
    try {
      final order = await remoteDataSource.getOrderDetail(id);
      return Right(order);
    } on DioException catch (e) {
      return Left(_handleError(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, OrderCreationResultEntity>> createOrder({
    required List<ShopOrderParams> orders,
  }) async {
    try {
      final result = await remoteDataSource.createOrder(orders: orders);
      return right(result);
    } on DioException catch (e) {
      return left(_handleError(e));
    } catch (e) {
      return left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> cancelOrder(int id) async {
    try {
      await remoteDataSource.cancelOrder(id);
      return const Right(null);
    } on DioException catch (e) {
      return Left(_handleError(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateOrderStatus(int id, String status) async {
    try {
      await remoteDataSource.updateOrderStatus(id, status);
      return const Right(null);
    } on DioException catch (e) {
      return Left(_handleError(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
