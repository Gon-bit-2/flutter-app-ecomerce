import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/discount.dart';
import '../repositories/discount_repository.dart';

import 'package:injectable/injectable.dart';

@lazySingleton
class GetAvailableDiscounts {
  final DiscountRepository repository;

  GetAvailableDiscounts(this.repository);

  Future<Either<Failure, List<Discount>>> call({
    int page = 1,
    int limit = 10,
  }) async {
    return await repository.getAvailableDiscounts(page: page, limit: limit);
  }
}
