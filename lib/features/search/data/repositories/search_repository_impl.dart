import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/search_result.dart';
import '../../domain/repositories/search_repository.dart';
import '../datasources/search_remote_datasource.dart';
import '../datasources/search_history_local_datasource.dart';

@LazySingleton(as: SearchRepository)
class SearchRepositoryImpl implements SearchRepository {
  final SearchRemoteDataSource remoteDataSource;
  final SearchHistoryLocalDataSource localDataSource;

  SearchRepositoryImpl(this.remoteDataSource, this.localDataSource);

  ServerFailure _handleError(DioException e) {
    try {
      if (e.response?.data != null) {
        final msg = e.response!.data['message'];
        if (msg is String) {
          return ServerFailure(msg);
        } else if (msg is List && msg.isNotEmpty) {
          final first = msg.first;
          if (first is Map && first.containsKey('message')) {
            return ServerFailure(first['message']);
          }
          return ServerFailure(msg.toString());
        }
      }
      return ServerFailure(e.message ?? "Unknown Error");
    } catch (_) {
      return ServerFailure(e.message ?? "Unknown Error");
    }
  }

  @override
  Future<Either<Failure, SearchResult>> searchProducts({
    required String query,
    int page = 1,
    int limit = 10,
    double? minPrice,
    double? maxPrice,
    String? sortBy,
    String? categoryId,
  }) async {
    try {
      final response = await remoteDataSource.searchProducts(
        query: query,
        page: page,
        limit: limit,
        minPrice: minPrice,
        maxPrice: maxPrice,
        sortBy: sortBy,
        categoryId: categoryId,
      );
      return Right(SearchResult(
        products: response.products,
        totalCount: response.totalCount,
      ));
    } on DioException catch (e) {
      return Left(_handleError(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<String>>> getSearchHistory() async {
    try {
      final history = await localDataSource.getSearchHistory();
      return Right(history);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> saveSearchQuery(String query) async {
    try {
      await localDataSource.saveSearchQuery(query);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteSearchQuery(String query) async {
    try {
      await localDataSource.deleteSearchQuery(query);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> clearSearchHistory() async {
    try {
      await localDataSource.clearSearchHistory();
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }
}
