import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/usecase/usecase.dart';
import '../../domain/usecases/search_products_usecase.dart';
import '../../domain/usecases/search_history_usecases.dart';
import 'search_event.dart';
import 'search_state.dart';


@injectable
class SearchBloc extends Bloc<SearchEvent, SearchState> {
  final SearchProductsUseCase _searchProductsUseCase;
  final GetSearchHistoryUseCase _getSearchHistoryUseCase;
  final SaveSearchQueryUseCase _saveSearchQueryUseCase;
  final DeleteSearchQueryUseCase _deleteSearchQueryUseCase;
  final ClearSearchHistoryUseCase _clearSearchHistoryUseCase;

  static const int _limit = 10;
  Timer? _debounceTimer;

  SearchBloc(
    this._searchProductsUseCase,
    this._getSearchHistoryUseCase,
    this._saveSearchQueryUseCase,
    this._deleteSearchQueryUseCase,
    this._clearSearchHistoryUseCase,
  ) : super(const SearchInitial()) {
    on<SearchInitRequested>(_onInitRequested);
    on<SearchQueryChanged>(_onQueryChanged);
    on<SearchLoadMore>(_onLoadMore);
    on<SearchCleared>(_onCleared);
    on<SearchHistorySelected>(_onHistorySelected);
    on<SearchHistoryDeleted>(_onHistoryDeleted);
    on<SearchHistoryCleared>(_onHistoryCleared);
    on<SearchFilterChanged>(_onFilterChanged);
  }

  Future<void> _onInitRequested(
    SearchInitRequested event,
    Emitter<SearchState> emit,
  ) async {
    final result = await _getSearchHistoryUseCase(NoParams());
    result.fold(
      (failure) => emit(const SearchInitial()),
      (history) => emit(SearchInitial(history: history)),
    );
  }

  Future<void> _onQueryChanged(
    SearchQueryChanged event,
    Emitter<SearchState> emit,
  ) async {
    final query = event.query.trim();

    if (query.isEmpty && state.categoryId == null) {
      final historyResult = await _getSearchHistoryUseCase(NoParams());
      final history = historyResult.getOrElse((_) => []);
      emit(SearchInitial(
        history: history,
        minPrice: state.minPrice,
        maxPrice: state.maxPrice,
        sortBy: state.sortBy,
        categoryId: state.categoryId,
      ));
      return;
    }

    _debounceTimer?.cancel();

    final completer = Completer<void>();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      completer.complete();
    });

    try {
      await completer.future;
    } catch (_) {
      return;
    }

    await _performSearch(query, emit);
  }

  Future<void> _performSearch(
    String query,
    Emitter<SearchState> emit, {
    int page = 1,
    bool isLoadMore = false,
  }) async {
    if (!isLoadMore) {
      emit(SearchLoading(
        history: state.history,
        minPrice: state.minPrice,
        maxPrice: state.maxPrice,
        sortBy: state.sortBy,
        categoryId: state.categoryId,
      ));
    }

    final result = await _searchProductsUseCase(
      SearchProductsParams(
        query: query,
        page: page,
        limit: _limit,
        minPrice: state.minPrice,
        maxPrice: state.maxPrice,
        sortBy: state.sortBy,
        categoryId: state.categoryId,
      ),
    );

    await result.fold(
      (failure) async {
        emit(SearchError(
          message: failure.message,
          query: query,
          history: state.history,
          minPrice: state.minPrice,
          maxPrice: state.maxPrice,
          sortBy: state.sortBy,
          categoryId: state.categoryId,
        ));
      },
      (searchResult) async {
        // Save to history on success
        if (query.isNotEmpty) {
          await _saveSearchQueryUseCase(query);
        }
        
        final historyResult = await _getSearchHistoryUseCase(NoParams());
        final history = historyResult.getOrElse((_) => []);

        if (isLoadMore) {
          final currentState = state as SearchLoaded;
          emit(SearchLoaded(
            products: [...currentState.products, ...searchResult.products],
            query: query,
            currentPage: page,
            hasMore: searchResult.products.length >= _limit,
            isLoadingMore: false,
            totalCount: searchResult.totalCount,
            history: history,
            minPrice: state.minPrice,
            maxPrice: state.maxPrice,
            sortBy: state.sortBy,
            categoryId: state.categoryId,
          ));
        } else {
          emit(SearchLoaded(
            products: searchResult.products,
            query: query,
            currentPage: 1,
            hasMore: searchResult.products.length >= _limit,
            totalCount: searchResult.totalCount,
            history: history,
            minPrice: state.minPrice,
            maxPrice: state.maxPrice,
            sortBy: state.sortBy,
            categoryId: state.categoryId,
          ));
        }
      },
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
    await _performSearch(currentState.query, emit, page: nextPage, isLoadMore: true);
  }

  Future<void> _onCleared(
    SearchCleared event,
    Emitter<SearchState> emit,
  ) async {
    _debounceTimer?.cancel();
    final historyResult = await _getSearchHistoryUseCase(NoParams());
    final history = historyResult.getOrElse((_) => []);
    emit(SearchInitial(history: history));
  }

  Future<void> _onHistorySelected(
    SearchHistorySelected event,
    Emitter<SearchState> emit,
  ) async {
    await _performSearch(event.query, emit);
  }

  Future<void> _onHistoryDeleted(
    SearchHistoryDeleted event,
    Emitter<SearchState> emit,
  ) async {
    await _deleteSearchQueryUseCase(event.query);
    final historyResult = await _getSearchHistoryUseCase(NoParams());
    final history = historyResult.getOrElse((_) => []);
    
    if (state is SearchInitial) {
      emit(SearchInitial(history: history));
    } else if (state is SearchLoaded) {
      emit((state as SearchLoaded).copyWith(history: history));
    }
  }

  Future<void> _onHistoryCleared(
    SearchHistoryCleared event,
    Emitter<SearchState> emit,
  ) async {
    await _clearSearchHistoryUseCase(NoParams());
    if (state is SearchInitial) {
      emit(const SearchInitial(history: []));
    } else if (state is SearchLoaded) {
      emit((state as SearchLoaded).copyWith(history: []));
    }
  }

  Future<void> _onFilterChanged(
    SearchFilterChanged event,
    Emitter<SearchState> emit,
  ) async {
    // If there was a query, re-run search with new filters
    String query = "";
    if (state is SearchLoaded) {
      query = (state as SearchLoaded).query;
    } else if (state is SearchError) {
      query = (state as SearchError).query;
    }

    // Cho phép tìm kiếm nếu có query hoặc nếu CÓ categoryId (để hiển thị kho theo danh mục)
    if (query.isNotEmpty || event.categoryId != null) {
      emit(SearchLoading(
        history: state.history,
        minPrice: event.minPrice,
        maxPrice: event.maxPrice,
        sortBy: event.sortBy,
        categoryId: event.categoryId,
      ));
      await _performSearch(query, emit);
    } else {
      emit(SearchInitial(
        history: state.history,
        minPrice: event.minPrice,
        maxPrice: event.maxPrice,
        sortBy: event.sortBy,
        categoryId: event.categoryId,
      ));
    }
  }

  @override
  Future<void> close() {
    _debounceTimer?.cancel();
    return super.close();
  }
}
