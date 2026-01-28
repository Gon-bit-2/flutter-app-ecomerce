import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import '../../../../../core/error/failures.dart';
import '../../../../../core/usecase/usecase.dart';
import '../../repositories/auth_repository.dart';

// Injectable sẽ tự động tạo UseCase này cho bạn khi cần
@lazySingleton
class GoogleAuthUseCase implements UseCase<String, NoParams> {
  final AuthRepository authRepository;

  GoogleAuthUseCase(this.authRepository);

  @override
  Future<Either<Failure, String>> call(NoParams params) async {
    return await authRepository.getGoogleAuthUrl();
  }
}
