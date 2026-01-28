import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import '../../../../../core/error/failures.dart';
import '../../../../../core/usecase/usecase.dart';
import '../../repositories/auth_repository.dart';

@lazySingleton
class VerifyOtpUseCase implements UseCase<void, VerifyOtpParams> {
  final AuthRepository authRepository;

  VerifyOtpUseCase(this.authRepository);

  @override
  Future<Either<Failure, void>> call(VerifyOtpParams params) async {
    return await authRepository.verifyOtp(
      email: params.email,
      code: params.code,
      type: params.type,
    );
  }
}

class VerifyOtpParams {
  final String email;
  final String code;
  final String type;

  VerifyOtpParams({
    required this.email,
    required this.code,
    required this.type,
  });
}
