import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import '../../../../../core/error/failures.dart';
import '../../../../../core/usecase/usecase.dart';
import '../../entities/user_entity.dart';
import '../../repositories/auth_repository.dart';

// Injectable sẽ tự động tạo UseCase này cho bạn khi cần
@lazySingleton
class GoogleCallbackUseCase
    implements UseCase<UserEntity, GoogleCallbackParams> {
  final AuthRepository authRepository;

  GoogleCallbackUseCase(this.authRepository);

  @override
  Future<Either<Failure, UserEntity>> call(GoogleCallbackParams params) async {
    return await authRepository.googleCallback(
      state: params.state,
      code: params.code,
    );
  }
}

// Class chứa tham số truyền vào (để code gọn hơn)
class GoogleCallbackParams {
  final String state;
  final String code;

  GoogleCallbackParams({required this.state, required this.code});
}
