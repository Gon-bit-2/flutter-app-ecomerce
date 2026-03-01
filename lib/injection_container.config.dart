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
import 'features/auth/domain/usecases/auth/disable_2fa_usecase.dart' as _i493;
import 'features/auth/domain/usecases/auth/google_auth_usecase.dart' as _i812;
import 'features/auth/domain/usecases/auth/google_callback_usecase.dart'
    as _i947;
import 'features/auth/domain/usecases/auth/login_usecase.dart' as _i804;
import 'features/auth/domain/usecases/auth/logout_usecase.dart' as _i639;
import 'features/auth/domain/usecases/auth/process_social_login_usecase.dart'
    as _i955;
import 'features/auth/domain/usecases/auth/register_usecase.dart' as _i12;
import 'features/auth/domain/usecases/auth/reset_password_usecase.dart'
    as _i944;
import 'features/auth/domain/usecases/auth/send_otp_usecase.dart' as _i1024;
import 'features/auth/domain/usecases/auth/setup_2fa_usecase.dart' as _i225;
import 'features/auth/domain/usecases/auth/verify_otp_usecase.dart' as _i293;
import 'features/auth/presentation/bloc/auth/auth_bloc.dart' as _i339;
import 'features/brand/data/datasources/brand_remote_datasource.dart' as _i1043;
import 'features/brand/data/repositories/brand_repository_impl.dart' as _i831;
import 'features/brand/domain/repositories/brand_repository.dart' as _i468;
import 'features/cart/data/datasources/cart_remote_datasource.dart' as _i987;
import 'features/cart/data/repositories/cart_repository_impl.dart' as _i302;
import 'features/cart/domain/repositories/cart_repository.dart' as _i303;
import 'features/cart/domain/usecases/add_cart_usecase.dart' as _i685;
import 'features/cart/domain/usecases/get_cart_usecase.dart' as _i810;
import 'features/cart/domain/usecases/remove_cart_item_usecase.dart' as _i494;
import 'features/cart/domain/usecases/update_cart_usecase.dart' as _i138;
import 'features/cart/presentation/bloc/cart/cart_bloc.dart' as _i44;
import 'features/category/data/datasources/category_remote_datasource.dart'
    as _i979;
import 'features/category/data/repositories/category_repository_impl.dart'
    as _i44;
import 'features/category/domain/repositories/category_repository.dart' as _i5;
import 'features/common/data/datasources/common_remote_datasource.dart' as _i74;
import 'features/common/data/repositories/common_repository_impl.dart' as _i499;
import 'features/common/domain/repositories/common_repository.dart' as _i493;
import 'features/home/data/datasources/home_local_datasource.dart' as _i429;
import 'features/home/data/repositories/home_repository_impl.dart' as _i689;
import 'features/home/domain/repositories/home_repository.dart' as _i649;
import 'features/home/domain/usecases/get_daily_discover_usecase.dart' as _i259;
import 'features/home/domain/usecases/get_home_data_usecase.dart' as _i702;
import 'features/home/presentation/bloc/home_bloc.dart' as _i123;
import 'features/product/data/datasources/product_remote_datasource.dart'
    as _i143;
import 'features/product/data/repositories/product_repository_impl.dart'
    as _i531;
import 'features/product/domain/repositories/product_repository.dart' as _i841;

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
    gh.lazySingleton<_i429.HomeLocalDataSource>(
      () => _i429.HomeLocalDataSourceImpl(),
    );
    gh.lazySingleton<_i1043.AuthLocalDataSource>(
      () => _i1043.AuthLocalDataSourceImpl(),
    );
    gh.lazySingleton<_i75.NetworkInfo>(
      () => _i75.NetworkInfoImpl(gh<_i895.Connectivity>()),
    );
    gh.lazySingleton<_i649.HomeRepository>(
      () => _i689.HomeRepositoryImpl(gh<_i429.HomeLocalDataSource>()),
    );
    gh.factory<_i8.AuthInterceptor>(
      () => _i8.AuthInterceptor(gh<_i1043.AuthLocalDataSource>()),
    );
    gh.lazySingleton<_i45.DioClient>(
      () => _i45.DioClient(gh<_i361.Dio>(), gh<_i8.AuthInterceptor>()),
    );
    gh.lazySingleton<_i979.CategoryRemoteDataSource>(
      () => _i979.CategoryRemoteDataSourceImpl(gh<_i45.DioClient>()),
    );
    gh.lazySingleton<_i588.AuthRemoteDataSource>(
      () => _i588.AuthRemoteDataSourceImpl(gh<_i45.DioClient>()),
    );
    gh.lazySingleton<_i143.ProductRemoteDataSource>(
      () => _i143.ProductRemoteDataSourceImpl(gh<_i45.DioClient>()),
    );
    gh.lazySingleton<_i987.CartRemoteDataSource>(
      () => _i987.CartRemoteDataSourceImpl(gh<_i45.DioClient>()),
    );
    gh.lazySingleton<_i74.CommonRemoteDataSource>(
      () => _i74.CommonRemoteDataSourceImpl(gh<_i45.DioClient>()),
    );
    gh.lazySingleton<_i493.CommonRepository>(
      () => _i499.CommonRepositoryImpl(gh<_i74.CommonRemoteDataSource>()),
    );
    gh.lazySingleton<_i1043.BrandRemoteDataSource>(
      () => _i1043.BrandRemoteDataSourceImpl(gh<_i45.DioClient>()),
    );
    gh.lazySingleton<_i303.CartRepository>(
      () => _i302.CartRepositoryImpl(gh<_i987.CartRemoteDataSource>()),
    );
    gh.lazySingleton<_i5.CategoryRepository>(
      () => _i44.CategoryRepositoryImpl(gh<_i979.CategoryRemoteDataSource>()),
    );
    gh.lazySingleton<_i841.ProductRepository>(
      () => _i531.ProductRepositoryImpl(gh<_i143.ProductRemoteDataSource>()),
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
    gh.factory<_i493.Disable2FAUseCase>(
      () => _i493.Disable2FAUseCase(gh<_i1015.AuthRepository>()),
    );
    gh.factory<_i639.LogoutUseCase>(
      () => _i639.LogoutUseCase(gh<_i1015.AuthRepository>()),
    );
    gh.factory<_i225.Setup2FAUseCase>(
      () => _i225.Setup2FAUseCase(gh<_i1015.AuthRepository>()),
    );
    gh.lazySingleton<_i468.BrandRepository>(
      () => _i831.BrandRepositoryImpl(gh<_i1043.BrandRemoteDataSource>()),
    );
    gh.lazySingleton<_i259.GetDailyDiscoverUseCase>(
      () => _i259.GetDailyDiscoverUseCase(gh<_i841.ProductRepository>()),
    );
    gh.factory<_i685.AddCartUseCase>(
      () => _i685.AddCartUseCase(gh<_i303.CartRepository>()),
    );
    gh.factory<_i810.GetCartUseCase>(
      () => _i810.GetCartUseCase(gh<_i303.CartRepository>()),
    );
    gh.factory<_i494.RemoveCartItemUseCase>(
      () => _i494.RemoveCartItemUseCase(gh<_i303.CartRepository>()),
    );
    gh.factory<_i138.UpdateCartUseCase>(
      () => _i138.UpdateCartUseCase(gh<_i303.CartRepository>()),
    );
    gh.factory<_i44.CartBloc>(
      () => _i44.CartBloc(
        gh<_i810.GetCartUseCase>(),
        gh<_i685.AddCartUseCase>(),
        gh<_i138.UpdateCartUseCase>(),
        gh<_i494.RemoveCartItemUseCase>(),
      ),
    );
    gh.lazySingleton<_i702.GetHomeDataUseCase>(
      () => _i702.GetHomeDataUseCase(
        gh<_i649.HomeRepository>(),
        gh<_i5.CategoryRepository>(),
        gh<_i841.ProductRepository>(),
      ),
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
    gh.factory<_i123.HomeBloc>(
      () => _i123.HomeBloc(
        gh<_i702.GetHomeDataUseCase>(),
        gh<_i259.GetDailyDiscoverUseCase>(),
      ),
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
        gh<_i639.LogoutUseCase>(),
        gh<_i225.Setup2FAUseCase>(),
        gh<_i493.Disable2FAUseCase>(),
        gh<_i1043.AuthLocalDataSource>(),
      ),
    );
    return this;
  }
}

class _$RegisterModule extends _i854.RegisterModule {}
