import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../entities/brand.dart';

abstract class BrandRepository {
  Future<Either<Failure, List<Brand>>> getBrands();
}
