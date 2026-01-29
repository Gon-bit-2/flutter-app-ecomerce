import 'package:app_fe_ecomerce/core/error/failures.dart';
import 'package:app_fe_ecomerce/core/usecase/usecase.dart';
import 'package:app_fe_ecomerce/features/auth/domain/repositories/auth_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';

@injectable
class Disable2FAUseCase implements UseCase<void, Disable2FAParams> {
  final AuthRepository _repository;

  Disable2FAUseCase(this._repository);

  @override
  Future<Either<Failure, void>> call(Disable2FAParams params) async {
    return await _repository.disable2FA(
      totpCode: params.totpCode,
      code: params.code,
    );
  }
}

class Disable2FAParams extends Equatable {
  final String? totpCode;
  final String? code;

  const Disable2FAParams({this.totpCode, this.code});

  @override
  List<Object?> get props => [totpCode, code];
}
