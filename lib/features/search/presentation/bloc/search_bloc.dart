import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../domain/usecases/search_products_usecase.dart';
import 'search_event.dart';
import 'search_state.dart';


@injectable
class SearchBloc extends Bloc<SearchEvent, SearchState> {
  final SearchProductsUseCase _searchProductsUseCase;
  static const int _limit = 10;
  Timer? _debounceTimer;

  SearchBloc(this._searchProductsUseCase) : super(SearchInitial()) {
    on<SearchQueryChanged>(_onQueryChanged);
    on<SearchLoadMore>(_onLoadMore);
    on<SearchCleared>(_onCleared);
  }

  Future<void> _onQueryChanged(
    SearchQueryChanged event,
    Emitter<SearchState> emit,
  ) async {
    final query = event.query.trim();

    // Nếu query rỗng, quay về trạng thái ban đầu
    if (query.isEmpty) {
      emit(SearchInitial());
      return;
    }

    // Cancel timer cũ nếu có
    _debounceTimer?.cancel();

    // Debounce: đợi 300ms trước khi gọi API
    final completer = Completer<void>();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      completer.complete();
    });

    try {
      await completer.future;
    } catch (_) {
      return;
    }

    emit(SearchLoading());

    final result = await _searchProductsUseCase(
      SearchProductsParams(query: query, page: 1, limit: _limit),
    );

    result.fold(
      (failure) => emit(SearchError(message: failure.message, query: query)),
      (products) => emit(SearchLoaded(
        products: products,
        query: query,
        currentPage: 1,
        hasMore: products.length >= _limit,
      )),
    );
  }

  Future<void> _onLoadMore(
    SearchLoadMore event,
    Emitter<SearchState> emit,
  ) async {
    final currentState = state;
    if (currentState is! SearchLoaded ||
        !currentState.hasMore ||
        currentState.isLoadingMore) {
      return;
    }

    emit(currentState.copyWith(isLoadingMore: true));

    final nextPage = currentState.currentPage + 1;
    final result = await _searchProductsUseCase(
      SearchProductsParams(
        query: currentState.query,
        page: nextPage,
        limit: _limit,
      ),
    );

    result.fold(
      (failure) => emit(currentState.copyWith(isLoadingMore: false)),
      (newProducts) => emit(SearchLoaded(
        products: [...currentState.products, ...newProducts],
        query: currentState.query,
        currentPage: nextPage,
        hasMore: newProducts.length >= _limit,
        isLoadingMore: false,
      )),
    );
  }

  void _onCleared(
    SearchCleared event,
    Emitter<SearchState> emit,
  ) {
    _debounceTimer?.cancel();
    emit(SearchInitial());
  }

  @override
  Future<void> close() {
    _debounceTimer?.cancel();
    return super.close();
  }
}
