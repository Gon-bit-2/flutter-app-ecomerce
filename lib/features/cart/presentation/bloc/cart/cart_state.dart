part of 'cart_bloc.dart';

abstract class CartState extends Equatable {
  const CartState();

  @override
  List<Object> get props => [];
}

// 1. Trạng thái ban đầu (chưa tải giỏ hàng)
class CartInitial extends CartState {}

// 2. Đang tải (hiện spinner)
class CartLoading extends CartState {}

// 3. Tải giỏ hàng thành công
class CartLoaded extends CartState {
  final List<CartEntity> items;

  const CartLoaded(this.items);

  @override
  List<Object> get props => [items];
}

// 4. Thao tác (thêm/xóa/cập nhật) thành công
class CartOperationSuccess extends CartState {
  final String message;

  const CartOperationSuccess({required this.message});

  @override
  List<Object> get props => [message];
}

// 5. Lỗi
class CartFailure extends CartState {
  final String message;

  const CartFailure(this.message);

  @override
  List<Object> get props => [message];
}

// 6. Chưa đăng nhập (Unauthorized 401)
class CartUnauthenticated extends CartState {
  final String message;

  const CartUnauthenticated(this.message);

  @override
  List<Object> get props => [message];
}
