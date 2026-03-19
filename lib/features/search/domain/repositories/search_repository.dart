import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../entities/search_result.dart';

abstract class SearchRepository {
  Future<Either<Failure, SearchResult>> searchProducts({
    required String query,
    int page = 1,
    int limit = 10,
    double? minPrice,
    double? maxPrice,
    String? sortBy,
    String? categoryId,
  });

  Future<Either<Failure, List<String>>> getSearchHistory();
  Future<Either<Failure, void>> saveSearchQuery(String query);
  Future<Either<Failure, void>> deleteSearchQuery(String query);
  Future<Either<Failure, void>> clearSearchHistory();
}
