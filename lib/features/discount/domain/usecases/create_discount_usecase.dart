import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../entities/discount.dart';
import '../repositories/discount_repository.dart';

@lazySingleton
class CreateDiscountUseCase {
  final DiscountRepository repository;

  CreateDiscountUseCase(this.repository);

  Future<Either<Failure, Discount>> call(CreateDiscountParams params) async {
    return await repository.createDiscount(params.data);
  }
}

class CreateDiscountParams extends Equatable {
  final Map<String, dynamic> data;

  const CreateDiscountParams({required this.data});

  @override
  List<Object?> get props => [data];
}
