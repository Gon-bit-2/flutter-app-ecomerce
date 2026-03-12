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
import 'features/address/data/datasources/address_remote_data_source.dart'
    as _i315;
import 'features/address/data/repositories/address_repository_impl.dart'
    as _i423;
import 'features/address/domain/repositories/address_repository.dart' as _i535;
import 'features/address/domain/usecases/create_address_usecase.dart' as _i924;
import 'features/address/domain/usecases/delete_address_usecase.dart' as _i78;
import 'features/address/domain/usecases/get_address_detail_usecase.dart'
    as _i145;
import 'features/address/domain/usecases/get_addresses_usecase.dart' as _i494;
import 'features/address/domain/usecases/set_default_address_usecase.dart'
    as _i679;
import 'features/address/domain/usecases/update_address_usecase.dart' as _i803;
import 'features/address/presentation/bloc/address_bloc.dart' as _i400;
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
import 'features/category/domain/usecases/create_category_usecase.dart'
    as _i944;
import 'features/category/domain/usecases/delete_category_usecase.dart'
    as _i875;
import 'features/category/domain/usecases/get_category_id_usecase.dart'
    as _i206;
import 'features/category/domain/usecases/get_category_usecase.dart' as _i351;
import 'features/category/domain/usecases/update_category_usecase.dart'
    as _i1032;
import 'features/category/presentation/bloc/category/category_bloc.dart'
    as _i584;
import 'features/common/data/datasources/common_remote_datasource.dart' as _i74;
import 'features/common/data/repositories/common_repository_impl.dart' as _i499;
import 'features/common/domain/repositories/common_repository.dart' as _i493;
import 'features/discount/data/datasources/discount_remote_datasource.dart'
    as _i772;
import 'features/discount/data/repositories/discount_repository_impl.dart'
    as _i732;
import 'features/discount/domain/repositories/discount_repository.dart'
    as _i506;
import 'features/discount/domain/usecases/create_discount_usecase.dart'
    as _i791;
import 'features/discount/domain/usecases/delete_discount_usecase.dart'
    as _i350;
import 'features/discount/domain/usecases/get_admin_discounts_usecase.dart'
    as _i361;
import 'features/discount/domain/usecases/get_available_discounts.dart'
    as _i760;
import 'features/discount/domain/usecases/get_discount_detail_usecase.dart'
    as _i516;
import 'features/discount/domain/usecases/get_my_vouchers.dart' as _i440;
import 'features/discount/domain/usecases/preview_discount.dart' as _i855;
import 'features/discount/domain/usecases/save_discount.dart' as _i21;
import 'features/discount/domain/usecases/update_discount_usecase.dart'
    as _i258;
import 'features/discount/presentation/bloc/discount/discount_bloc.dart'
    as _i1016;
import 'features/discount/presentation/bloc/seller_discount/seller_discount_bloc.dart'
    as _i406;
import 'features/home/data/datasources/home_local_datasource.dart' as _i429;
import 'features/home/data/repositories/home_repository_impl.dart' as _i689;
import 'features/home/domain/repositories/home_repository.dart' as _i649;
import 'features/home/domain/usecases/get_daily_discover_usecase.dart' as _i259;
import 'features/home/domain/usecases/get_home_data_usecase.dart' as _i702;
import 'features/home/presentation/bloc/home_bloc.dart' as _i123;
import 'features/order/data/datasources/order_remote_datasource.dart' as _i176;
import 'features/order/data/repositories/order_repository_impl.dart' as _i113;
import 'features/order/domain/repositories/order_repository.dart' as _i608;
import 'features/order/domain/usecases/cancel_order_usecase.dart' as _i255;
import 'features/order/domain/usecases/create_order_usecase.dart' as _i93;
import 'features/order/domain/usecases/get_order_detail_usecase.dart' as _i1062;
import 'features/order/domain/usecases/get_orders_usecase.dart' as _i836;
import 'features/order/presentation/bloc/order/order_bloc.dart' as _i289;
import 'features/order/presentation/bloc/seller_order/seller_order_bloc.dart'
    as _i337;
import 'features/payment/data/datasources/payment_remote_datasource.dart'
    as _i983;
import 'features/payment/data/repositories/payment_repository_impl.dart'
    as _i210;
import 'features/payment/domain/repositories/payment_repository.dart' as _i376;
import 'features/payment/domain/usecases/get_payment_config_usecase.dart'
    as _i813;
import 'features/product/data/datasources/product_remote_datasource.dart'
    as _i143;
import 'features/product/data/repositories/product_repository_impl.dart'
    as _i531;
import 'features/product/domain/repositories/product_repository.dart' as _i841;
import 'features/product/presentation/bloc/my_products/my_products_bloc.dart'
    as _i947;

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
    gh.lazySingleton<_i315.AddressRemoteDataSource>(
      () => _i315.AddressRemoteDataSourceImpl(apiClient: gh<_i45.DioClient>()),
    );
    gh.lazySingleton<_i979.CategoryRemoteDataSource>(
      () => _i979.CategoryRemoteDataSourceImpl(gh<_i45.DioClient>()),
    );
    gh.lazySingleton<_i588.AuthRemoteDataSource>(
      () => _i588.AuthRemoteDataSourceImpl(gh<_i45.DioClient>()),
    );
    gh.lazySingleton<_i176.OrderRemoteDataSource>(
      () => _i176.OrderRemoteDataSourceImpl(gh<_i45.DioClient>()),
    );
    gh.lazySingleton<_i772.DiscountRemoteDataSource>(
      () => _i772.DiscountRemoteDataSourceImpl(gh<_i45.DioClient>()),
    );
    gh.lazySingleton<_i143.ProductRemoteDataSource>(
      () => _i143.ProductRemoteDataSourceImpl(gh<_i45.DioClient>()),
    );
    gh.lazySingleton<_i535.AddressRepository>(
      () => _i423.AddressRepositoryImpl(
        remoteDataSource: gh<_i315.AddressRemoteDataSource>(),
      ),
    );
    gh.lazySingleton<_i987.CartRemoteDataSource>(
      () => _i987.CartRemoteDataSourceImpl(gh<_i45.DioClient>()),
    );
    gh.lazySingleton<_i983.PaymentRemoteDataSource>(
      () => _i983.PaymentRemoteDataSourceImpl(gh<_i45.DioClient>()),
    );
    gh.lazySingleton<_i74.CommonRemoteDataSource>(
      () => _i74.CommonRemoteDataSourceImpl(gh<_i45.DioClient>()),
    );
    gh.lazySingleton<_i376.PaymentRepository>(
      () => _i210.PaymentRepositoryImpl(gh<_i983.PaymentRemoteDataSource>()),
    );
    gh.lazySingleton<_i493.CommonRepository>(
      () => _i499.CommonRepositoryImpl(gh<_i74.CommonRemoteDataSource>()),
    );
    gh.factory<_i813.GetPaymentConfigUseCase>(
      () => _i813.GetPaymentConfigUseCase(gh<_i376.PaymentRepository>()),
    );
    gh.lazySingleton<_i1043.BrandRemoteDataSource>(
      () => _i1043.BrandRemoteDataSourceImpl(gh<_i45.DioClient>()),
    );
    gh.lazySingleton<_i303.CartRepository>(
      () => _i302.CartRepositoryImpl(gh<_i987.CartRemoteDataSource>()),
    );
    gh.lazySingleton<_i924.CreateAddressUseCase>(
      () => _i924.CreateAddressUseCase(gh<_i535.AddressRepository>()),
    );
    gh.lazySingleton<_i78.DeleteAddressUseCase>(
      () => _i78.DeleteAddressUseCase(gh<_i535.AddressRepository>()),
    );
    gh.lazySingleton<_i145.GetAddressDetailUseCase>(
      () => _i145.GetAddressDetailUseCase(gh<_i535.AddressRepository>()),
    );
    gh.lazySingleton<_i494.GetAddressesUseCase>(
      () => _i494.GetAddressesUseCase(gh<_i535.AddressRepository>()),
    );
    gh.lazySingleton<_i679.SetDefaultAddressUseCase>(
      () => _i679.SetDefaultAddressUseCase(gh<_i535.AddressRepository>()),
    );
    gh.lazySingleton<_i803.UpdateAddressUseCase>(
      () => _i803.UpdateAddressUseCase(gh<_i535.AddressRepository>()),
    );
    gh.lazySingleton<_i608.OrderRepository>(
      () => _i113.OrderRepositoryImpl(gh<_i176.OrderRemoteDataSource>()),
    );
    gh.lazySingleton<_i5.CategoryRepository>(
      () => _i44.CategoryRepositoryImpl(gh<_i979.CategoryRemoteDataSource>()),
    );
    gh.lazySingleton<_i841.ProductRepository>(
      () => _i531.ProductRepositoryImpl(gh<_i143.ProductRemoteDataSource>()),
    );
    gh.lazySingleton<_i506.DiscountRepository>(
      () => _i732.DiscountRepositoryImpl(
        remoteDataSource: gh<_i772.DiscountRemoteDataSource>(),
      ),
    );
    gh.factory<_i944.CreateCategoryUseCase>(
      () => _i944.CreateCategoryUseCase(gh<_i5.CategoryRepository>()),
    );
    gh.factory<_i875.DeleteCategoryUseCase>(
      () => _i875.DeleteCategoryUseCase(gh<_i5.CategoryRepository>()),
    );
    gh.factory<_i206.GetCategoryIdUseCase>(
      () => _i206.GetCategoryIdUseCase(gh<_i5.CategoryRepository>()),
    );
    gh.factory<_i351.GetCategoryUseCase>(
      () => _i351.GetCategoryUseCase(gh<_i5.CategoryRepository>()),
    );
    gh.factory<_i1032.UpdateCategoryUseCase>(
      () => _i1032.UpdateCategoryUseCase(gh<_i5.CategoryRepository>()),
    );
    gh.lazySingleton<_i791.CreateDiscountUseCase>(
      () => _i791.CreateDiscountUseCase(gh<_i506.DiscountRepository>()),
    );
    gh.lazySingleton<_i350.DeleteDiscountUseCase>(
      () => _i350.DeleteDiscountUseCase(gh<_i506.DiscountRepository>()),
    );
    gh.lazySingleton<_i361.GetAdminDiscountsUseCase>(
      () => _i361.GetAdminDiscountsUseCase(gh<_i506.DiscountRepository>()),
    );
    gh.lazySingleton<_i760.GetAvailableDiscounts>(
      () => _i760.GetAvailableDiscounts(gh<_i506.DiscountRepository>()),
    );
    gh.lazySingleton<_i516.GetDiscountDetailUseCase>(
      () => _i516.GetDiscountDetailUseCase(gh<_i506.DiscountRepository>()),
    );
    gh.lazySingleton<_i440.GetMyVouchers>(
      () => _i440.GetMyVouchers(gh<_i506.DiscountRepository>()),
    );
    gh.lazySingleton<_i855.PreviewDiscount>(
      () => _i855.PreviewDiscount(gh<_i506.DiscountRepository>()),
    );
    gh.lazySingleton<_i258.UpdateDiscountUseCase>(
      () => _i258.UpdateDiscountUseCase(gh<_i506.DiscountRepository>()),
    );
    gh.factory<_i21.SaveDiscount>(
      () => _i21.SaveDiscount(gh<_i506.DiscountRepository>()),
    );
    gh.factory<_i584.CategoryBloc>(
      () => _i584.CategoryBloc(
        gh<_i351.GetCategoryUseCase>(),
        gh<_i206.GetCategoryIdUseCase>(),
        gh<_i944.CreateCategoryUseCase>(),
        gh<_i1032.UpdateCategoryUseCase>(),
        gh<_i875.DeleteCategoryUseCase>(),
      ),
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
    gh.factory<_i406.SellerDiscountBloc>(
      () => _i406.SellerDiscountBloc(
        gh<_i361.GetAdminDiscountsUseCase>(),
        gh<_i791.CreateDiscountUseCase>(),
        gh<_i258.UpdateDiscountUseCase>(),
        gh<_i350.DeleteDiscountUseCase>(),
      ),
    );
    gh.factory<_i400.AddressBloc>(
      () => _i400.AddressBloc(
        getAddressesUseCase: gh<_i494.GetAddressesUseCase>(),
        createAddressUseCase: gh<_i924.CreateAddressUseCase>(),
        updateAddressUseCase: gh<_i803.UpdateAddressUseCase>(),
        deleteAddressUseCase: gh<_i78.DeleteAddressUseCase>(),
        setDefaultAddressUseCase: gh<_i679.SetDefaultAddressUseCase>(),
      ),
    );
    gh.factory<_i255.CancelOrderUseCase>(
      () => _i255.CancelOrderUseCase(gh<_i608.OrderRepository>()),
    );
    gh.factory<_i93.CreateOrderUseCase>(
      () => _i93.CreateOrderUseCase(gh<_i608.OrderRepository>()),
    );
    gh.factory<_i1062.GetOrderDetailUseCase>(
      () => _i1062.GetOrderDetailUseCase(gh<_i608.OrderRepository>()),
    );
    gh.factory<_i836.GetOrdersUseCase>(
      () => _i836.GetOrdersUseCase(gh<_i608.OrderRepository>()),
    );
    gh.factory<_i947.MyProductsBloc>(
      () => _i947.MyProductsBloc(gh<_i841.ProductRepository>()),
    );
    gh.factory<_i1016.DiscountBloc>(
      () => _i1016.DiscountBloc(
        getMyVouchers: gh<_i440.GetMyVouchers>(),
        getAvailableDiscounts: gh<_i760.GetAvailableDiscounts>(),
        previewDiscount: gh<_i855.PreviewDiscount>(),
        saveDiscount: gh<_i21.SaveDiscount>(),
      ),
    );
    gh.lazySingleton<_i468.BrandRepository>(
      () => _i831.BrandRepositoryImpl(gh<_i1043.BrandRemoteDataSource>()),
    );
    gh.factory<_i337.SellerOrderBloc>(
      () => _i337.SellerOrderBloc(gh<_i608.OrderRepository>()),
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
    gh.factory<_i289.OrderBloc>(
      () => _i289.OrderBloc(
        gh<_i93.CreateOrderUseCase>(),
        gh<_i836.GetOrdersUseCase>(),
        gh<_i1062.GetOrderDetailUseCase>(),
        gh<_i255.CancelOrderUseCase>(),
      ),
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
