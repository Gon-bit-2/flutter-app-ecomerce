import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import '../../../../../core/error/failures.dart';
import '../../../../../core/usecase/usecase.dart';
import '../../entities/user_entity.dart';
import '../../repositories/auth_repository.dart';

// Injectable sẽ tự động tạo UseCase này cho bạn khi cần
@lazySingleton
class LoginUseCase implements UseCase<UserEntity, LoginParams> {
  final AuthRepository authRepository;

  LoginUseCase(this.authRepository);

  @override
  Future<Either<Failure, UserEntity>> call(LoginParams params) async {
    return await authRepository.login(
      email: params.email,
      password: params.password,
    );
  }
}

// Class chứa tham số truyền vào (để code gọn hơn)
class LoginParams {
  final String email;
  final String password;

  LoginParams({required this.email, required this.password});
}
