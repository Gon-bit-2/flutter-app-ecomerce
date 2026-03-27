import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../datasources/auth_local_datasource.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';

@LazySingleton(as: AuthRepository)
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;

  AuthRepositoryImpl(this.remoteDataSource, this.localDataSource);

  ServerFailure _handleError(DioException e) {
    try {
      if (e.response?.data != null) {
        final msg = e.response!.data['message'];
        if (msg is String) {
          return ServerFailure(msg);
        } else if (msg is List && msg.isNotEmpty) {
          final first = msg.first;
          if (first is Map && first.containsKey('message')) {
            return ServerFailure(first['message']);
          }
          return ServerFailure(msg.toString());
        }
      }
      return ServerFailure(e.message ?? "Unknown Error");
    } catch (_) {
      return ServerFailure(e.message ?? "Unknown Error");
    }
  }

  @override
  Future<Either<Failure, UserEntity>> login({
    required String email,
    required String password,
    String? totpCode,
    String? code,
  }) async {
    try {
      final tokenModel = await remoteDataSource.login(
        email,
        password,
        totpCode: totpCode,
        code: code,
      );
      await localDataSource.saveTokens(
        tokenModel.accessToken,
        tokenModel.refreshToken,
      );
      final userModel = await remoteDataSource.getProfile();
      return Right(userModel);
    } on DioException catch (e) {
      return Left(_handleError(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> register({
    required String email,
    required String password,
    required String name,
    required String phoneNumber,
    required String confirmPassword,
    required String code,
  }) async {
    try {
      await remoteDataSource.register(
        email: email,
        password: password,
        name: name,
        phoneNumber: phoneNumber,
        confirmPassword: confirmPassword,
        code: code,
      );
      
      // Auto login after successful registration
      final tokenModel = await remoteDataSource.login(email, password);
      await localDataSource.saveTokens(
        tokenModel.accessToken,
        tokenModel.refreshToken,
      );
      final userModel = await remoteDataSource.getProfile();
      
      return Right(userModel);
    } on DioException catch (e) {
      return Left(_handleError(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      final refreshToken = await localDataSource.getRefreshToken();
      if (refreshToken != null) {
        await remoteDataSource.logout(refreshToken);
      }
      await localDataSource.clearTokens();
      return const Right(null);
    } on DioException catch (e) {
      await localDataSource.clearTokens();
      return Left(_handleError(e));
    } catch (e) {
      await localDataSource.clearTokens();
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> sendOtp({
    required String email,
    required String type,
  }) async {
    try {
      await remoteDataSource.sendOtp(email, type);
      return const Right(null);
    } on DioException catch (e) {
      return Left(_handleError(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> verifyOtp({
    required String email,
    required String code,
    required String type,
  }) async {
    try {
      await remoteDataSource.verifyOtp(email, code, type);
      return const Right(null);
    } on DioException catch (e) {
      return Left(_handleError(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> refreshToken(String refreshToken) async {
    try {
      final tokenModel = await remoteDataSource.refreshToken(refreshToken);
      await localDataSource.saveTokens(
        tokenModel.accessToken,
        tokenModel.refreshToken,
      );
      return Right(tokenModel.accessToken);
    } on DioException catch (e) {
      await localDataSource.clearTokens();
      return Left(_handleError(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> getGoogleAuthUrl() async {
    try {
      final url = await remoteDataSource.googleLink();
      return Right(url);
    } on DioException catch (e) {
      return Left(_handleError(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> googleCallback({
    required String state,
    required String code,
  }) async {
    try {
      final tokenModel = await remoteDataSource.googleCallback(state, code);
      await localDataSource.saveTokens(
        tokenModel.accessToken,
        tokenModel.refreshToken,
      );
      final userModel = await remoteDataSource.getProfile();
      return Right(userModel);
    } on DioException catch (e) {
      return Left(_handleError(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> forgotPassword({
    required String email,
    required String code,
    required String newPassword,
    required String confirmNewPassword,
  }) async {
    try {
      await remoteDataSource.forgotPassword(
        email: email,
        code: code,
        newPassword: newPassword,
        confirmNewPassword: confirmNewPassword,
      );
      return const Right(null);
    } on DioException catch (e) {
      return Left(_handleError(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> setup2FA() async {
    try {
      final result = await remoteDataSource.setup2FA();
      return Right(result);
    } on DioException catch (e) {
      return Left(_handleError(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> verify2FA({required String totpCode}) async {
    try {
      await remoteDataSource.verify2FA(totpCode: totpCode);
      return const Right(null);
    } on DioException catch (e) {
      return Left(_handleError(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> disable2FA({
    String? totpCode,
    String? code,
  }) async {
    try {
      await remoteDataSource.disable2FA(totpCode: totpCode, code: code);
      return const Right(null);
    } on DioException catch (e) {
      return Left(_handleError(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> processSocialLogin({
    required String accessToken,
    required String refreshToken,
  }) async {
    try {
      await localDataSource.saveTokens(accessToken, refreshToken);
      final userModel = await remoteDataSource.getProfile();
      return Right(userModel);
    } on DioException catch (e) {
      // Nếu load profile lỗi -> clear token
      await localDataSource.clearTokens();
      return Left(_handleError(e));
    } catch (e) {
      await localDataSource.clearTokens();
      return Left(ServerFailure(e.toString()));
    }
  }
}
