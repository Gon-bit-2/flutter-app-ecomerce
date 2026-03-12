import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/discount.dart';

abstract class DiscountRepository {
  Future<Either<Failure, List<Discount>>> getMyVouchers({
    int page = 1,
    int limit = 10,
  });
  Future<Either<Failure, List<Discount>>> getAvailableDiscounts({
    int page = 1,
    int limit = 10,
  });
  Future<Either<Failure, Map<String, dynamic>>> previewDiscount({
    required String code,
    required double orderValue,
    required int userId, // Có thể bỏ qua nếu có thể lấy từ Token/Auth
    required int shopId,
    required List<Map<String, dynamic>> items,
  });
  Future<Either<Failure, List<Discount>>> getDiscountsByAdmin({
    int page = 1,
    int limit = 10,
    int? shopId,
    String? type,
    String? scope,
    bool? isActive,
    String? search,
  });
  Future<Either<Failure, Discount>> getDiscountDetail(int discountId);
  Future<Either<Failure, Discount>> createDiscount(Map<String, dynamic> data);
  Future<Either<Failure, Discount>> updateDiscount(
    int discountId,
    Map<String, dynamic> data,
  );
  Future<Either<Failure, void>> deleteDiscount(int discountId);
  Future<Either<Failure, void>> saveDiscount(int discountId);
}
