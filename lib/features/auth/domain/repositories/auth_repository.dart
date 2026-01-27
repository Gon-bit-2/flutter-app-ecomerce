import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../entities/user_entity.dart';

abstract class AuthRepository {
  // Hàm đăng nhập: Nhận email, pass -> Trả về Lỗi hoặc UserEntity
  Future<Either<Failure, UserEntity>> login({
    required String email,
    required String password,
  });

  // Hàm đăng ký
  Future<Either<Failure, UserEntity>> register({
    required String email,
    required String password,
    required String name,
    required String phoneNumber,
  });

  // Hàm đăng xuất
  Future<Either<Failure, void>> logout();
}
