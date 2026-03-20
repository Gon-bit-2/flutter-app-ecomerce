import 'package:equatable/equatable.dart';
import '../../../product/domain/entities/product.dart';

abstract class SearchState extends Equatable {
  final List<String> history;
  final double? minPrice;
  final double? maxPrice;
  final String? sortBy;
  final String? categoryId;

  const SearchState({
    this.history = const [],
    this.minPrice,
    this.maxPrice,
    this.sortBy,
    this.categoryId,
  });

  @override
  List<Object?> get props => [history, minPrice, maxPrice, sortBy, categoryId];
}

/// Trạng thái ban đầu — chưa search gì
class SearchInitial extends SearchState {
  const SearchInitial({
    super.history,
    super.minPrice,
    super.maxPrice,
    super.sortBy,
    super.categoryId,
  });
}

/// Đang tải kết quả tìm kiếm (lần đầu)
class SearchLoading extends SearchState {
  const SearchLoading({
    super.history,
    super.minPrice,
    super.maxPrice,
    super.sortBy,
    super.categoryId,
  });
}

/// Đã tải xong kết quả
class SearchLoaded extends SearchState {
  final List<Product> products;
  final String query;
  final int currentPage;
  final bool hasMore;
  final bool isLoadingMore;
  final int totalCount;

  const SearchLoaded({
    required this.products,
    required this.query,
    required this.currentPage,
    required this.hasMore,
    this.isLoadingMore = false,
    required this.totalCount,
    super.history,
    super.minPrice,
    super.maxPrice,
    super.sortBy,
    super.categoryId,
  });

  SearchLoaded copyWith({
    List<Product>? products,
    String? query,
    int? currentPage,
    bool? hasMore,
    bool? isLoadingMore,
    int? totalCount,
    List<String>? history,
    double? minPrice,
    double? maxPrice,
    String? sortBy,
    String? categoryId,
  }) {
    return SearchLoaded(
      products: products ?? this.products,
      query: query ?? this.query,
      currentPage: currentPage ?? this.currentPage,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      totalCount: totalCount ?? this.totalCount,
      history: history ?? this.history,
      minPrice: minPrice ?? this.minPrice,
      maxPrice: maxPrice ?? this.maxPrice,
      sortBy: sortBy ?? this.sortBy,
      categoryId: categoryId ?? this.categoryId,
    );
  }

  @override
  List<Object?> get props => [
        ...super.props,
        products,
        query,
        currentPage,
        hasMore,
        isLoadingMore,
        totalCount,
      ];
}

/// Lỗi khi tìm kiếm
class SearchError extends SearchState {
  final String message;
  final String query;

  const SearchError({
    required this.message,
    required this.query,
    super.history,
    super.minPrice,
    super.maxPrice,
    super.sortBy,
    super.categoryId,
  });

  @override
  List<Object?> get props => [...super.props, message, query];
}
