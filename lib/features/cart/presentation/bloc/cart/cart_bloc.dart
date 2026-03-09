import 'package:app_fe_ecomerce/features/cart/domain/entities/cart_entity.dart';
import 'package:app_fe_ecomerce/features/cart/domain/usecases/add_cart_usecase.dart';
import 'package:app_fe_ecomerce/features/cart/domain/usecases/get_cart_usecase.dart';
import 'package:app_fe_ecomerce/features/cart/domain/usecases/remove_cart_item_usecase.dart';
import 'package:app_fe_ecomerce/features/cart/domain/usecases/update_cart_usecase.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:app_fe_ecomerce/core/error/failures.dart';

part 'cart_event.dart';
part 'cart_state.dart';

@injectable
class CartBloc extends Bloc<CartEvent, CartState> {
  final GetCartUseCase _getCartUseCase;
  final AddCartUseCase _addCartUseCase;
  final UpdateCartUseCase _updateCartUseCase;
  final RemoveCartItemUseCase _removeCartItemUseCase;

  CartBloc(
    this._getCartUseCase,
    this._addCartUseCase,
    this._updateCartUseCase,
    this._removeCartItemUseCase,
  ) : super(CartInitial()) {
    // 1. Xử lý Tải giỏ hàng
    on<CartLoadRequested>((event, emit) async {
      emit(CartLoading());
      final result = await _getCartUseCase(
        GetCartParams(page: event.page, limit: event.limit),
      );
      result.fold((failure) {
        if (failure is ServerFailure && failure.statusCode == 401) {
          emit(CartUnauthenticated(failure.message));
        } else {
          emit(CartFailure(failure.message));
        }
      }, (items) => emit(CartLoaded(items)));
    });

    // 2. Xử lý Thêm sản phẩm vào giỏ
    on<CartItemAdded>((event, emit) async {
      emit(CartLoading());
      final result = await _addCartUseCase(
        AddToCartParams(skuId: event.skuId, quantity: event.quantity),
      );
      result.fold(
        (failure) {
          if (failure is ServerFailure && failure.statusCode == 401) {
            emit(CartUnauthenticated(failure.message));
          } else {
            emit(CartFailure(failure.message));
          }
        },
        (_) {
          emit(const CartOperationSuccess(message: 'Đã thêm vào giỏ hàng'));
          // Tải lại giỏ hàng sau khi thêm thành công
          add(const CartLoadRequested(page: 1, limit: 100));
        },
      );
    });

    // 3. Xử lý Cập nhật số lượng
    on<CartItemUpdated>((event, emit) async {
      emit(CartLoading());
      final result = await _updateCartUseCase(
        UpdateCartParams(id: event.id, quantity: event.quantity),
      );
      result.fold(
        (failure) {
          if (failure is ServerFailure && failure.statusCode == 401) {
            emit(CartUnauthenticated(failure.message));
          } else {
            emit(CartFailure(failure.message));
          }
        },
        (_) {
          // Sau khi cập nhật thành công, tải lại giỏ hàng
          add(const CartLoadRequested(page: 1, limit: 100));
        },
      );
    });

    // 4. Xử lý Xóa sản phẩm
    on<CartItemsRemoved>((event, emit) async {
      emit(CartLoading());
      final result = await _removeCartItemUseCase(
        RemoveCartItemParams(cartItemIds: event.cartItemIds),
      );
      result.fold(
        (failure) {
          if (failure is ServerFailure && failure.statusCode == 401) {
            emit(CartUnauthenticated(failure.message));
          } else {
            emit(CartFailure(failure.message));
          }
        },
        (_) {
          emit(const CartOperationSuccess(message: 'Đã xóa sản phẩm'));
          // Sau khi xóa thành công, tải lại giỏ hàng
          add(const CartLoadRequested(page: 1, limit: 100));
        },
      );
    });
  }
}
