import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../../../product/domain/entities/product.dart';
import '../../../product/domain/repositories/product_repository.dart';

class GetDailyDiscoverParams {
  final int page;
  final int limit;

  GetDailyDiscoverParams({this.page = 1, this.limit = 10});
}

@lazySingleton
class GetDailyDiscoverUseCase
    implements UseCase<List<Product>, GetDailyDiscoverParams> {
  final ProductRepository productRepository;

  GetDailyDiscoverUseCase(this.productRepository);

  @override
  Future<Either<Failure, List<Product>>> call(GetDailyDiscoverParams params) {
    return productRepository.getProducts(
      page: params.page,
      limit: params.limit,
    );
  }
}
