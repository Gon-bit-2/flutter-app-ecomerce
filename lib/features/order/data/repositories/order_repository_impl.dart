import 'package:app_fe_ecomerce/core/error/failures.dart';
import 'package:app_fe_ecomerce/features/order/data/datasources/order_remote_datasource.dart';
import 'package:app_fe_ecomerce/features/order/data/models/order_model.dart';
import 'package:app_fe_ecomerce/features/order/domain/entities/order_creation_result_entity.dart';
import 'package:app_fe_ecomerce/features/order/domain/entities/order_entity.dart';
import 'package:app_fe_ecomerce/features/order/domain/repositories/order_repository.dart';
import 'package:app_fe_ecomerce/features/order/domain/usecases/create_order_usecase.dart';
import 'package:app_fe_ecomerce/features/product/data/datasources/product_remote_datasource.dart';
import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: OrderRepository)
class OrderRepositoryImpl implements OrderRepository {
  final OrderRemoteDataSource remoteDataSource;
  final ProductRemoteDataSource productRemoteDataSource;

  OrderRepositoryImpl(this.remoteDataSource, this.productRemoteDataSource);

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

  /// Bổ sung ảnh sản phẩm cho các order items nếu thiếu ảnh.
  /// Fetch ảnh từ Product API theo productId.
  Future<OrderEntity> _enrichOrderWithImages(OrderModel order) async {
    if (order.items == null || order.items!.isEmpty) return order;

    // Tìm các items thiếu ảnh
    final itemsMissingImage = order.items!
        .where((item) => (item.image == null || item.image!.isEmpty) && item.productId != null)
        .toList();

    if (itemsMissingImage.isEmpty) return order;

    // Lấy danh sách productId unique cần fetch
    final productIdsToFetch = itemsMissingImage
        .map((item) => item.productId!)
        .toSet()
        .toList();

    // Fetch ảnh cho từng product
    final Map<int, String> productImageMap = {};
    for (final productId in productIdsToFetch) {
      try {
        final product = await productRemoteDataSource.getProductById(productId);
        if (product.images.isNotEmpty) {
          productImageMap[productId] = product.images.first;
          print('✅ [OrderRepo] Fetched image for product $productId: ${product.images.first}');
        }
      } catch (e) {
        print('⚠️ [OrderRepo] Failed to fetch product $productId image: $e');
      }
    }

    if (productImageMap.isEmpty) return order;

    // Rebuild items với ảnh mới
    final enrichedItems = order.items!.map((item) {
      if ((item.image == null || item.image!.isEmpty) &&
          item.productId != null &&
          productImageMap.containsKey(item.productId!)) {
        return OrderItemModel(
          id: item.id,
          skuId: item.skuId,
          productId: item.productId,
          productName: item.productName,
          skuValue: item.skuValue,
          image: productImageMap[item.productId!],
          price: item.price,
          quantity: item.quantity,
          isReviewed: item.isReviewed,
        );
      }
      return item;
    }).toList();

    return OrderModel(
      id: order.id,
      shopId: order.shopId,
      status: order.status,
      totalAmount: order.totalAmount,
      receiverName: order.receiverName,
      receiverPhone: order.receiverPhone,
      receiverAddress: order.receiverAddress,
      paymentMethod: order.paymentMethod,
      paymentId: order.paymentId,
      items: enrichedItems.cast<OrderItemModel>(),
      createdAt: order.createdAt,
    );
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

      // Enrich mỗi order với ảnh sản phẩm nếu thiếu
      final enrichedOrders = <OrderEntity>[];
      for (final order in orders) {
        final enriched = await _enrichOrderWithImages(order);
        enrichedOrders.add(enriched);
      }

      return Right(enrichedOrders);
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
      // Enrich order với ảnh sản phẩm nếu thiếu
      final enriched = await _enrichOrderWithImages(order);
      return Right(enriched);
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

