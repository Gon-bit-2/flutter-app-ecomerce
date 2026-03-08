import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../domain/entities/product.dart';
import '../../../domain/repositories/product_repository.dart';

part 'my_products_event.dart';
part 'my_products_state.dart';

@injectable
class MyProductsBloc extends Bloc<MyProductsEvent, MyProductsState> {
  final ProductRepository _productRepository;

  MyProductsBloc(this._productRepository) : super(MyProductsInitial()) {
    on<MyProductsLoadRequested>(_onLoadRequested);
    on<MyProductsDeleteRequested>(_onDeleteRequested);
  }

  Future<void> _onLoadRequested(
    MyProductsLoadRequested event,
    Emitter<MyProductsState> emit,
  ) async {
    if (event.page == 1) {
      emit(MyProductsLoading());
    }

    final result = await _productRepository.getManageProducts(
      page: event.page,
      limit: event.limit,
    );

    result.fold((failure) => emit(MyProductsFailure(failure.message)), (
      products,
    ) {
      if (state is MyProductsLoaded && event.page > 1) {
        final currentProducts = (state as MyProductsLoaded).products;
        emit(
          MyProductsLoaded(
            products: currentProducts + products,
            hasReachedMax: products.length < event.limit,
          ),
        );
      } else {
        emit(
          MyProductsLoaded(
            products: products,
            hasReachedMax: products.length < event.limit,
          ),
        );
      }
    });
  }

  Future<void> _onDeleteRequested(
    MyProductsDeleteRequested event,
    Emitter<MyProductsState> emit,
  ) async {
    final previousState = state;
    emit(MyProductsLoading());

    final result = await _productRepository.deleteProduct(event.productId);

    result.fold(
      (failure) {
        emit(MyProductsFailure(failure.message));
        // Restore previous state so list is still visible
        if (previousState is MyProductsLoaded) {
          emit(previousState);
        }
      },
      (_) {
        emit(const MyProductsDeleteSuccess());
        // Reload products
        add(const MyProductsLoadRequested());
      },
    );
  }
}
