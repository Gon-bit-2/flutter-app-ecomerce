import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../entities/discount.dart';
import '../repositories/discount_repository.dart';

@lazySingleton
class GetDiscountDetailUseCase {
  final DiscountRepository repository;

  GetDiscountDetailUseCase(this.repository);

  Future<Either<Failure, Discount>> call(GetDiscountDetailParams params) async {
    return await repository.getDiscountDetail(params.discountId);
  }
}

class GetDiscountDetailParams extends Equatable {
  final int discountId;

  const GetDiscountDetailParams({required this.discountId});

  @override
  List<Object?> get props => [discountId];
}
