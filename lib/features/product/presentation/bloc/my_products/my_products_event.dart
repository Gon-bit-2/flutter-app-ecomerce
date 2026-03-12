part of 'my_products_bloc.dart';

abstract class MyProductsEvent extends Equatable {
  const MyProductsEvent();

  @override
  List<Object?> get props => [];
}

class MyProductsLoadRequested extends MyProductsEvent {
  final int page;
  final int limit;
  final int createdById;

  const MyProductsLoadRequested({
    this.page = 1,
    this.limit = 10,
    required this.createdById,
  });

  @override
  List<Object?> get props => [page, limit, createdById];
}

class MyProductsDeleteRequested extends MyProductsEvent {
  final int productId;

  const MyProductsDeleteRequested({required this.productId});

  @override
  List<Object?> get props => [productId];
}
