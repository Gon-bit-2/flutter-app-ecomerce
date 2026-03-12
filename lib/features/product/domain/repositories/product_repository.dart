import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../entities/product.dart';

abstract class ProductRepository {
  Future<Either<Failure, List<Product>>> getProducts({
    int page = 1,
    int limit = 10,
    // Add other filters as needed
  });

  Future<Either<Failure, Product>> getProductById(int productId);

  Future<Either<Failure, bool>> createProduct(Map<String, dynamic> productData);
  Future<Either<Failure, bool>> updateProduct(
    int id,
    Map<String, dynamic> productData,
  );
  Future<Either<Failure, void>> deleteProduct(int id);
  Future<Either<Failure, List<Product>>> getManageProducts({
    int page = 1,
    int limit = 10,
    required int createdById,
  });
}
