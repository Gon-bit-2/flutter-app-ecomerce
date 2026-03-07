import 'package:fpdart/fpdart.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import 'package:injectable/injectable.dart';
import '../../domain/entities/address_entity.dart';
import '../../domain/repositories/address_repository.dart';
import '../datasources/address_remote_data_source.dart';

@LazySingleton(as: AddressRepository)
class AddressRepositoryImpl implements AddressRepository {
  final AddressRemoteDataSource remoteDataSource;

  AddressRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<AddressEntity>>> getAddresses() async {
    try {
      final addresses = await remoteDataSource.getAddresses();
      return Right(addresses);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, AddressEntity>> getAddressDetail(
    String addressId,
  ) async {
    try {
      final address = await remoteDataSource.getAddressDetail(addressId);
      return Right(address);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, AddressEntity>> createAddress({
    required String name,
    required String phone,
    required String address,
    bool? isDefault,
  }) async {
    try {
      final newAddress = await remoteDataSource.createAddress(
        name: name,
        phone: phone,
        address: address,
        isDefault: isDefault,
      );
      return Right(newAddress);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, AddressEntity>> updateAddress(
    String addressId, {
    String? name,
    String? phone,
    String? address,
    bool? isDefault,
  }) async {
    try {
      final updatedAddress = await remoteDataSource.updateAddress(
        addressId,
        name: name,
        phone: phone,
        address: address,
        isDefault: isDefault,
      );
      return Right(updatedAddress);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteAddress(String addressId) async {
    try {
      await remoteDataSource.deleteAddress(addressId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> setDefaultAddress(String addressId) async {
    try {
      await remoteDataSource.setDefaultAddress(addressId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
