import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../entities/discount.dart';
import '../repositories/discount_repository.dart';

@lazySingleton
class GetAdminDiscountsUseCase {
  final DiscountRepository repository;

  GetAdminDiscountsUseCase(this.repository);

  Future<Either<Failure, List<Discount>>> call(
    GetAdminDiscountsParams params,
  ) async {
    return await repository.getDiscountsByAdmin(
      page: params.page,
      limit: params.limit,
      shopId: params.shopId,
      type: params.type,
      scope: params.scope,
      isActive: params.isActive,
      search: params.search,
    );
  }
}

class GetAdminDiscountsParams extends Equatable {
  final int page;
  final int limit;
  final int? shopId;
  final String? type;
  final String? scope;
  final bool? isActive;
  final String? search;

  const GetAdminDiscountsParams({
    this.page = 1,
    this.limit = 10,
    this.shopId,
    this.type,
    this.scope,
    this.isActive,
    this.search,
  });

  @override
  List<Object?> get props => [
    page,
    limit,
    shopId,
    type,
    scope,
    isActive,
    search,
  ];
}
