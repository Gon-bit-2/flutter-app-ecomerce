import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import '../../../../../core/error/failures.dart';
import '../../../../../core/usecase/usecase.dart';
import '../../entities/user_entity.dart';
import '../../repositories/auth_repository.dart';

// Injectable sẽ tự động tạo UseCase này cho bạn khi cần
@lazySingleton
class RegisterUseCase implements UseCase<UserEntity, RegisterParams> {
  final AuthRepository authRepository;

  RegisterUseCase(this.authRepository);

  @override
  Future<Either<Failure, UserEntity>> call(RegisterParams params) async {
    return await authRepository.register(
      email: params.email,
      password: params.password,
      name: params.name,
      phoneNumber: params.phoneNumber,
      confirmPassword: params.confirmPassword,
      code: params.code,
    );
  }
}

// Class chứa tham số truyền vào (để code gọn hơn)
class RegisterParams {
  final String email;
  final String password;
  final String name;
  final String phoneNumber;
  final String confirmPassword;
  final String code;

  RegisterParams({
    required this.email,
    required this.password,
    required this.name,
    required this.phoneNumber,
    required this.confirmPassword,
    required this.code,
  });
}
