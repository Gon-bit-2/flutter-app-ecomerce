import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/search_result.dart';
import '../repositories/search_repository.dart';

class SearchProductsParams extends Equatable {
  final String query;
  final int page;
  final int limit;
  final double? minPrice;
  final double? maxPrice;
  final String? sortBy; // 'price_asc', 'price_desc', 'newest', 'best_seller'
  final String? categoryId;

  const SearchProductsParams({
    required this.query,
    this.page = 1,
    this.limit = 10,
    this.minPrice,
    this.maxPrice,
    this.sortBy,
    this.categoryId,
  });

  @override
  List<Object?> get props => [
        query,
        page,
        limit,
        minPrice,
        maxPrice,
        sortBy,
        categoryId,
      ];
}

@lazySingleton
class SearchProductsUseCase
    extends UseCase<SearchResult, SearchProductsParams> {
  final SearchRepository repository;

  SearchProductsUseCase(this.repository);

  @override
  Future<Either<Failure, SearchResult>> call(
    SearchProductsParams params,
  ) {
    return repository.searchProducts(
      query: params.query,
      page: params.page,
      limit: params.limit,
      minPrice: params.minPrice,
      maxPrice: params.maxPrice,
      sortBy: params.sortBy,
      categoryId: params.categoryId,
    );
  }
}
