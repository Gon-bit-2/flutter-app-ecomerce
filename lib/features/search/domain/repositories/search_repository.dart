import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../../../product/domain/entities/product.dart';

abstract class SearchRepository {
  Future<Either<Failure, List<Product>>> searchProducts({
    required String query,
    int page = 1,
    int limit = 10,
  });
}
