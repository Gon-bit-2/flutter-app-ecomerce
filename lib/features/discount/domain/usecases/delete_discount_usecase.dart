import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../repositories/discount_repository.dart';

@lazySingleton
class DeleteDiscountUseCase {
  final DiscountRepository repository;

  DeleteDiscountUseCase(this.repository);

  Future<Either<Failure, void>> call(DeleteDiscountParams params) async {
    return await repository.deleteDiscount(params.discountId);
  }
}

class DeleteDiscountParams extends Equatable {
  final int discountId;

  const DeleteDiscountParams({required this.discountId});

  @override
  List<Object?> get props => [discountId];
}
