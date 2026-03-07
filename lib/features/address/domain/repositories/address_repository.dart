import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../entities/address_entity.dart';

abstract class AddressRepository {
  Future<Either<Failure, List<AddressEntity>>> getAddresses();
  Future<Either<Failure, AddressEntity>> getAddressDetail(String addressId);
  Future<Either<Failure, AddressEntity>> createAddress({
    required String name,
    required String phone,
    required String address,
    bool? isDefault,
  });
  Future<Either<Failure, AddressEntity>> updateAddress(
    String addressId, {
    String? name,
    String? phone,
    String? address,
    bool? isDefault,
  });
  Future<Either<Failure, void>> deleteAddress(String addressId);
  Future<Either<Failure, void>> setDefaultAddress(String addressId);
}
