import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/exceptions.dart';
import '../models/address_model.dart';
import '../../../../core/network/dio_client.dart';

abstract class AddressRemoteDataSource {
  Future<List<AddressModel>> getAddresses();
  Future<AddressModel> getAddressDetail(String addressId);
  Future<AddressModel> createAddress({
    required String name,
    required String phone,
    required String address,
    bool? isDefault,
  });
  Future<AddressModel> updateAddress(
    String addressId, {
    String? name,
    String? phone,
    String? address,
    bool? isDefault,
  });
  Future<void> deleteAddress(String addressId);
  Future<void> setDefaultAddress(String addressId);
}

@LazySingleton(as: AddressRemoteDataSource)
class AddressRemoteDataSourceImpl implements AddressRemoteDataSource {
  final DioClient apiClient;

  AddressRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<List<AddressModel>> getAddresses() async {
    try {
      final response = await apiClient.get('/address');
      // Dựa trên response format backend, giả sử trả về 1 mảng các địa chỉ
      if (response.data is List) {
        return (response.data as List)
            .map((json) => AddressModel.fromJson(json))
            .toList();
      } else if (response.data['data'] is List) {
        return (response.data['data'] as List)
            .map((json) => AddressModel.fromJson(json))
            .toList();
      }
      return [];
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<AddressModel> getAddressDetail(String addressId) async {
    try {
      final response = await apiClient.get('/address/$addressId');
      if (response.statusCode == 200 || response.statusCode == 201) {
        return AddressModel.fromJson(response.data['data']);
      } else {
        throw ServerException('Lỗi máy chủ rên tạo địa chỉ');
      }
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<AddressModel> createAddress({
    required String name,
    required String phone,
    required String address,
    bool? isDefault,
  }) async {
    try {
      final response = await apiClient.post(
        '/address',
        data: {
          'name': name,
          'phone': phone,
          'address': address,
          if (isDefault != null) 'isDefault': isDefault,
        },
      );
      final data = response.data['data'] ?? response.data;
      return AddressModel.fromJson(data);
    } on DioException catch (e) {
      throw ServerException(
        e.response?.data?['message'] ?? 'Lỗi khi tạo địa chỉ mới',
      );
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<AddressModel> updateAddress(
    String addressId, {
    String? name,
    String? phone,
    String? address,
    bool? isDefault,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (name != null) data['name'] = name;
      if (phone != null) data['phone'] = phone;
      if (address != null) data['address'] = address;
      if (isDefault != null) data['isDefault'] = isDefault;

      final response = await apiClient.put('/address/$addressId', data: data);
      final responseData = response.data['data'] ?? response.data;
      return AddressModel.fromJson(responseData);
    } on DioException catch (e) {
      throw ServerException(
        e.response?.data?['message'] ?? 'Lỗi khi cập nhật địa chỉ',
      );
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> deleteAddress(String addressId) async {
    try {
      final response = await apiClient.delete('/address/$addressId');
      if (response.statusCode != 200) {
        throw ServerException('Không thể xóa địa chỉ');
      }
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> setDefaultAddress(String addressId) async {
    try {
      await apiClient.put('/address/$addressId/default');
    } on DioException catch (e) {
      throw ServerException(
        e.response?.data?['message'] ?? 'Lỗi khi đặt địa chỉ mặc định',
      );
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
