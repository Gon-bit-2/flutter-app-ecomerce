import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import '../../../../../core/error/failures.dart';
import '../../../../../core/usecase/usecase.dart';
import '../../repositories/auth_repository.dart';

@lazySingleton
class SendOtpUseCase implements UseCase<void, SendOtpParams> {
  final AuthRepository authRepository;

  SendOtpUseCase(this.authRepository);

  @override
  Future<Either<Failure, void>> call(SendOtpParams params) async {
    return await authRepository.sendOtp(email: params.email, type: params.type);
  }
}

class SendOtpParams {
  final String email;
  final String type;

  SendOtpParams({required this.email, required this.type});
}
