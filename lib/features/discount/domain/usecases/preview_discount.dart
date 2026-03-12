import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/discount_repository.dart';

import 'package:injectable/injectable.dart';

@lazySingleton
class PreviewDiscount {
  final DiscountRepository repository;

  PreviewDiscount(this.repository);

  Future<Either<Failure, Map<String, dynamic>>> call({
    required String code,
    required double orderValue,
    required int userId,
    required int shopId,
    required List<Map<String, dynamic>> items,
  }) async {
    return await repository.previewDiscount(
      code: code,
      orderValue: orderValue,
      userId: userId,
      shopId: shopId,
      items: items,
    );
  }
}
