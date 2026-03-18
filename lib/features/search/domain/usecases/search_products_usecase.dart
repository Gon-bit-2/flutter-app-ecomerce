import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../../../product/domain/entities/product.dart';
import '../repositories/search_repository.dart';

class SearchProductsParams extends Equatable {
  final String query;
  final int page;
  final int limit;

  const SearchProductsParams({
    required this.query,
    this.page = 1,
    this.limit = 10,
  });

  @override
  List<Object?> get props => [query, page, limit];
}

@lazySingleton
class SearchProductsUseCase
    extends UseCase<List<Product>, SearchProductsParams> {
  final SearchRepository repository;

  SearchProductsUseCase(this.repository);

  @override
  Future<Either<Failure, List<Product>>> call(
    SearchProductsParams params,
  ) {
    return repository.searchProducts(
      query: params.query,
      page: params.page,
      limit: params.limit,
    );
  }
}
