part of 'cart_bloc.dart';

abstract class CartEvent extends Equatable {
  const CartEvent();

  @override
  List<Object> get props => [];
}

// Sự kiện: Tải danh sách giỏ hàng
class CartLoadRequested extends CartEvent {
  final int? page;
  final int? limit;

  const CartLoadRequested({this.page, this.limit});

  @override
  List<Object> get props => [
    if (page != null) page!,
    if (limit != null) limit!,
  ];
}

// Sự kiện: Thêm sản phẩm vào giỏ hàng
class CartItemAdded extends CartEvent {
  final int skuId;
  final int quantity;

  const CartItemAdded({required this.skuId, required this.quantity});

  @override
  List<Object> get props => [skuId, quantity];
}

// Sự kiện: Cập nhật số lượng sản phẩm
class CartItemUpdated extends CartEvent {
  final int id;
  final int quantity;

  const CartItemUpdated({required this.id, required this.quantity});

  @override
  List<Object> get props => [id, quantity];
}

// Sự kiện: Xóa sản phẩm khỏi giỏ hàng (1 hoặc nhiều)
class CartItemsRemoved extends CartEvent {
  final List<int> cartItemIds;

  const CartItemsRemoved({required this.cartItemIds});

  @override
  List<Object> get props => [cartItemIds];
}
