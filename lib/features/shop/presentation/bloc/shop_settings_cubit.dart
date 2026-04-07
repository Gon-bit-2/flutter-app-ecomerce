import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:app_fe_ecomerce/core/network/dio_client.dart';
import 'package:app_fe_ecomerce/core/constants/app_constants.dart';
import 'package:dio/dio.dart';
import 'shop_settings_state.dart';

@injectable
class ShopSettingsCubit extends Cubit<ShopSettingsState> {
  final DioClient _dioClient;

  ShopSettingsCubit(this._dioClient) : super(ShopSettingsInitial());

  Future<void> updateShopSettings({
    required String name,
    String? avatar,
  }) async {
    try {
      emit(ShopSettingsLoading());

      final data = <String, dynamic>{
        'name': name,
        'avatar': avatar ?? '',
      };

      // Dùng chung API update profile (PUT /profile)
      await _dioClient.put(
        AppConstants.updateProfileEndpoint,
        data: data,
      );

      emit(const ShopSettingsSuccess('Cập nhật thông tin shop thành công!'));
    } catch (e) {
      String errorMessage = 'Có lỗi xảy ra, vui lòng thử lại.';
      if (e is DioException && e.response != null) {
        final msg = e.response?.data;
        if (msg is Map && msg.containsKey('message')) {
          errorMessage = msg['message'].toString();
        }
      }
      emit(ShopSettingsError(errorMessage));
    }
  }
}
