import 'package:fpdart/fpdart.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import '../../../../../core/error/failures.dart';
import '../../../../../core/usecase/usecase.dart';
import '../../repositories/auth_repository.dart';

@injectable
class Verify2FAUseCase implements UseCase<void, Verify2FAParams> {
  final AuthRepository _repository;

  Verify2FAUseCase(this._repository);

  @override
  Future<Either<Failure, void>> call(Verify2FAParams params) async {
    return await _repository.verify2FA(totpCode: params.totpCode);
  }
}

class Verify2FAParams extends Equatable {
  final String totpCode;

  const Verify2FAParams({required this.totpCode});

  @override
  List<Object?> get props => [totpCode];
}
