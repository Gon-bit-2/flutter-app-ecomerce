part of 'my_products_bloc.dart';

abstract class MyProductsState extends Equatable {
  const MyProductsState();

  @override
  List<Object?> get props => [];
}

class MyProductsInitial extends MyProductsState {}

class MyProductsLoading extends MyProductsState {}

class MyProductsLoaded extends MyProductsState {
  final List<Product> products;
  final bool hasReachedMax;

  const MyProductsLoaded({required this.products, this.hasReachedMax = false});

  @override
  List<Object?> get props => [products, hasReachedMax];
}

class MyProductsDeleteSuccess extends MyProductsState {
  const MyProductsDeleteSuccess();
}

class MyProductsFailure extends MyProductsState {
  final String message;

  const MyProductsFailure(this.message);

  @override
  List<Object?> get props => [message];
}
