import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../repositories/discount_repository.dart';

@injectable
class SaveDiscount implements UseCase<void, int> {
  final DiscountRepository repository;

  SaveDiscount(this.repository);

  @override
  Future<Either<Failure, void>> call(int params) async {
    // DiscountRepository đang trả về dartz.Either, ta cần map sang fpdart.Either
    final dartzEither = await repository.saveDiscount(params);
    return dartzEither.fold(
      (l) => Left(l),
      (r) => const Right(null),
    );
  }
}
