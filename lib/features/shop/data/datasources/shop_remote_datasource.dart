import 'package:injectable/injectable.dart';
import '../../../../core/network/dio_client.dart';
import '../models/shop_model.dart';
import '../../../../core/constants/app_constants.dart';

abstract class ShopRemoteDataSource {
  Future<void> registerShop({
    required String name,
    required String description,
    required String phoneNumber,
    required String address,
    required String email,
  });
  
  Future<ShopModel?> getMyShop();
}

@LazySingleton(as: ShopRemoteDataSource)
class ShopRemoteDataSourceImpl implements ShopRemoteDataSource {
  final DioClient _dioClient;

  ShopRemoteDataSourceImpl(this._dioClient);

  @override
  Future<void> registerShop({
    required String name,
    required String description,
    required String phoneNumber,
    required String address,
    required String email,
  }) async {
    final Map<String, dynamic> data = {'name': name};
    if (description.isNotEmpty) data['description'] = description;
    if (phoneNumber.isNotEmpty) data['phoneNumber'] = phoneNumber;
    if (address.isNotEmpty) data['address'] = address;
    if (email.isNotEmpty) data['email'] = email;

    await _dioClient.post(
      AppConstants.registerShopEndpoint,
      data: data,
    );
  }

  @override
  Future<ShopModel?> getMyShop() async {
    final response = await _dioClient.get(AppConstants.myShopEndpoint);
    if (response.data == null || response.data == '') return null;
    return ShopModel.fromJson(response.data);
  }
}
