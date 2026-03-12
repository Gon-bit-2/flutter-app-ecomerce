import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../entities/discount.dart';
import '../repositories/discount_repository.dart';

@lazySingleton
class UpdateDiscountUseCase {
  final DiscountRepository repository;

  UpdateDiscountUseCase(this.repository);

  Future<Either<Failure, Discount>> call(UpdateDiscountParams params) async {
    return await repository.updateDiscount(params.discountId, params.data);
  }
}

class UpdateDiscountParams extends Equatable {
  final int discountId;
  final Map<String, dynamic> data;

  const UpdateDiscountParams({required this.discountId, required this.data});

  @override
  List<Object?> get props => [discountId, data];
}
