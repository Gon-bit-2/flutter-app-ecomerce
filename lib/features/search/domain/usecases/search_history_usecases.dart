import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../repositories/search_repository.dart';

@lazySingleton
class GetSearchHistoryUseCase extends UseCase<List<String>, NoParams> {
  final SearchRepository repository;

  GetSearchHistoryUseCase(this.repository);

  @override
  Future<Either<Failure, List<String>>> call(NoParams params) {
    return repository.getSearchHistory();
  }
}

@lazySingleton
class SaveSearchQueryUseCase extends UseCase<void, String> {
  final SearchRepository repository;

  SaveSearchQueryUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(String query) {
    return repository.saveSearchQuery(query);
  }
}

@lazySingleton
class DeleteSearchQueryUseCase extends UseCase<void, String> {
  final SearchRepository repository;

  DeleteSearchQueryUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(String query) {
    return repository.deleteSearchQuery(query);
  }
}

@lazySingleton
class ClearSearchHistoryUseCase extends UseCase<void, NoParams> {
  final SearchRepository repository;

  ClearSearchHistoryUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(NoParams params) {
    return repository.clearSearchHistory();
  }
}
