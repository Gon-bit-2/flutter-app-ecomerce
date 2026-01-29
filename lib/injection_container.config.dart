// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:connectivity_plus/connectivity_plus.dart' as _i895;
import 'package:dio/dio.dart' as _i361;
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;
import 'package:shared_preferences/shared_preferences.dart' as _i460;

import 'core/di/register_module.dart' as _i854;
import 'core/network/auth_interceptor.dart' as _i8;
import 'core/network/dio_client.dart' as _i45;
import 'core/network/network_info.dart' as _i75;
import 'core/services/deep_link_service.dart' as _i872;
import 'features/auth/data/datasources/auth_local_datasource.dart' as _i1043;
import 'features/auth/data/datasources/auth_remote_datasource.dart' as _i588;
import 'features/auth/data/repositories/auth_repository_impl.dart' as _i111;
import 'features/auth/domain/repositories/auth_repository.dart' as _i1015;
import 'features/auth/domain/usecases/auth/google_auth_usecase.dart' as _i812;
import 'features/auth/domain/usecases/auth/google_callback_usecase.dart'
    as _i947;
import 'features/auth/domain/usecases/auth/login_usecase.dart' as _i804;
import 'features/auth/domain/usecases/auth/process_social_login_usecase.dart'
    as _i955;
import 'features/auth/domain/usecases/auth/register_usecase.dart' as _i12;
import 'features/auth/domain/usecases/auth/reset_password_usecase.dart'
    as _i944;
import 'features/auth/domain/usecases/auth/send_otp_usecase.dart' as _i1024;
import 'features/auth/domain/usecases/auth/verify_otp_usecase.dart' as _i293;
import 'features/auth/presentation/bloc/auth/auth_bloc.dart' as _i339;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  Future<_i174.GetIt> init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) async {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    final registerModule = _$RegisterModule();
    await gh.factoryAsync<_i460.SharedPreferences>(
      () => registerModule.prefs,
      preResolve: true,
    );
    gh.lazySingleton<_i361.Dio>(() => registerModule.dio);
    gh.lazySingleton<_i895.Connectivity>(() => registerModule.connectivity);
    gh.lazySingleton<_i872.DeepLinkService>(() => _i872.DeepLinkService());
    gh.lazySingleton<_i1043.AuthLocalDataSource>(
      () => _i1043.AuthLocalDataSourceImpl(),
    );
    gh.lazySingleton<_i75.NetworkInfo>(
      () => _i75.NetworkInfoImpl(gh<_i895.Connectivity>()),
    );
    gh.factory<_i8.AuthInterceptor>(
      () => _i8.AuthInterceptor(gh<_i1043.AuthLocalDataSource>()),
    );
    gh.lazySingleton<_i45.DioClient>(
      () => _i45.DioClient(gh<_i361.Dio>(), gh<_i8.AuthInterceptor>()),
    );
    gh.lazySingleton<_i588.AuthRemoteDataSource>(
      () => _i588.AuthRemoteDataSourceImpl(gh<_i45.DioClient>()),
    );
    gh.lazySingleton<_i1015.AuthRepository>(
      () => _i111.AuthRepositoryImpl(
        gh<_i588.AuthRemoteDataSource>(),
        gh<_i1043.AuthLocalDataSource>(),
      ),
    );
    gh.lazySingleton<_i955.ProcessSocialLoginUseCase>(
      () => _i955.ProcessSocialLoginUseCase(gh<_i1015.AuthRepository>()),
    );
    gh.lazySingleton<_i944.ResetPasswordUseCase>(
      () => _i944.ResetPasswordUseCase(gh<_i1015.AuthRepository>()),
    );
    gh.lazySingleton<_i812.GoogleAuthUseCase>(
      () => _i812.GoogleAuthUseCase(gh<_i1015.AuthRepository>()),
    );
    gh.lazySingleton<_i947.GoogleCallbackUseCase>(
      () => _i947.GoogleCallbackUseCase(gh<_i1015.AuthRepository>()),
    );
    gh.lazySingleton<_i804.LoginUseCase>(
      () => _i804.LoginUseCase(gh<_i1015.AuthRepository>()),
    );
    gh.lazySingleton<_i12.RegisterUseCase>(
      () => _i12.RegisterUseCase(gh<_i1015.AuthRepository>()),
    );
    gh.lazySingleton<_i1024.SendOtpUseCase>(
      () => _i1024.SendOtpUseCase(gh<_i1015.AuthRepository>()),
    );
    gh.lazySingleton<_i293.VerifyOtpUseCase>(
      () => _i293.VerifyOtpUseCase(gh<_i1015.AuthRepository>()),
    );
    gh.factory<_i339.AuthBloc>(
      () => _i339.AuthBloc(
        gh<_i804.LoginUseCase>(),
        gh<_i12.RegisterUseCase>(),
        gh<_i1024.SendOtpUseCase>(),
        gh<_i293.VerifyOtpUseCase>(),
        gh<_i812.GoogleAuthUseCase>(),
        gh<_i947.GoogleCallbackUseCase>(),
        gh<_i944.ResetPasswordUseCase>(),
        gh<_i955.ProcessSocialLoginUseCase>(),
      ),
    );
    return this;
  }
}

class _$RegisterModule extends _i854.RegisterModule {}
