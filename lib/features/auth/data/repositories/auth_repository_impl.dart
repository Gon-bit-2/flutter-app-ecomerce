import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';

@LazySingleton(as: AuthRepository)
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final SharedPreferences sharedPreferences;

  AuthRepositoryImpl(this.remoteDataSource, this.sharedPreferences);

  @override
  Future<Either<Failure, UserEntity>> login({
    required String email,
    required String password,
  }) async {
    try {
      // 1. Gọi Data Source
      final userModel = await remoteDataSource.login(email, password);

      // 2. Lưu Token (Nếu API có trả về token nằm trong userModel hoặc response riêng)
      // Ví dụ: await sharedPreferences.setString(AppConstants.accessTokenKey, token);

      // 3. Trả về thành công (Right)
      return Right(userModel);
    } on DioException catch (e) {
      // 4. Xử lý lỗi từ Server (Dio) trả về
      // Ví dụ: 401 Unauthorized, 500 Server Error
      return Left(ServerFailure(e.message ?? 'Lỗi kết nối máy chủ'));
    } catch (e) {
      // 5. Lỗi khác (Code sai, crash...)
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> register({
    required String email,
    required String password,
    required String name,
    required String phoneNumber,
  }) async {
    // TODO: Làm tương tự hàm login
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, void>> logout() async {
    // Xóa token khi đăng xuất
    await sharedPreferences.remove(AppConstants.accessTokenKey);
    return const Right(null);
  }
}
