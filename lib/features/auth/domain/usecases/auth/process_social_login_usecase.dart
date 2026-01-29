import 'package:app_fe_ecomerce/core/error/failures.dart';
import 'package:app_fe_ecomerce/core/usecase/usecase.dart';
import 'package:app_fe_ecomerce/features/auth/domain/entities/user_entity.dart';
import 'package:app_fe_ecomerce/features/auth/domain/repositories/auth_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class ProcessSocialLoginUseCase
    implements UseCase<UserEntity, ProcessSocialLoginParams> {
  final AuthRepository _repository;

  ProcessSocialLoginUseCase(this._repository);

  @override
  Future<Either<Failure, UserEntity>> call(
    ProcessSocialLoginParams params,
  ) async {
    return await _repository.processSocialLogin(
      accessToken: params.accessToken,
      refreshToken: params.refreshToken,
    );
  }
}

class ProcessSocialLoginParams extends Equatable {
  final String accessToken;
  final String refreshToken;

  const ProcessSocialLoginParams({
    required this.accessToken,
    required this.refreshToken,
  });

  @override
  List<Object?> get props => [accessToken, refreshToken];
}
