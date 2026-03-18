import 'package:equatable/equatable.dart';
import '../../../product/domain/entities/product.dart';

abstract class SearchState extends Equatable {
  const SearchState();

  @override
  List<Object?> get props => [];
}

/// Trạng thái ban đầu — chưa search gì
class SearchInitial extends SearchState {}

/// Đang tải kết quả tìm kiếm (lần đầu)
class SearchLoading extends SearchState {}

/// Đã tải xong kết quả
class SearchLoaded extends SearchState {
  final List<Product> products;
  final String query;
  final int currentPage;
  final bool hasMore;
  final bool isLoadingMore;

  const SearchLoaded({
    required this.products,
    required this.query,
    required this.currentPage,
    required this.hasMore,
    this.isLoadingMore = false,
  });

  SearchLoaded copyWith({
    List<Product>? products,
    String? query,
    int? currentPage,
    bool? hasMore,
    bool? isLoadingMore,
  }) {
    return SearchLoaded(
      products: products ?? this.products,
      query: query ?? this.query,
      currentPage: currentPage ?? this.currentPage,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }

  @override
  List<Object?> get props => [
        products,
        query,
        currentPage,
        hasMore,
        isLoadingMore,
      ];
}

/// Lỗi khi tìm kiếm
class SearchError extends SearchState {
  final String message;
  final String query;

  const SearchError({required this.message, required this.query});

  @override
  List<Object?> get props => [message, query];
}
