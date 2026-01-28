import 'package:app_fe_ecomerce/core/error/failures.dart';
import 'package:app_fe_ecomerce/core/usecase/usecase.dart';
import 'package:app_fe_ecomerce/features/auth/domain/repositories/auth_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class ResetPasswordUseCase implements UseCase<void, ResetPasswordParams> {
  final AuthRepository _repository;

  ResetPasswordUseCase(this._repository);

  @override
  Future<Either<Failure, void>> call(ResetPasswordParams params) async {
    return await _repository.forgotPassword(
      email: params.email,
      code: params.code,
      newPassword: params.newPassword,
      confirmNewPassword: params.confirmNewPassword,
    );
  }
}

class ResetPasswordParams extends Equatable {
  final String email;
  final String code;
  final String newPassword;
  final String confirmNewPassword;

  const ResetPasswordParams({
    required this.email,
    required this.code,
    required this.newPassword,
    required this.confirmNewPassword,
  });

  @override
  List<Object> get props => [email, code, newPassword, confirmNewPassword];
}
