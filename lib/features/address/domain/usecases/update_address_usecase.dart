import 'package:fpdart/fpdart.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/address_entity.dart';
import '../repositories/address_repository.dart';

@lazySingleton
class UpdateAddressUseCase
    implements UseCase<AddressEntity, UpdateAddressParams> {
  final AddressRepository repository;

  UpdateAddressUseCase(this.repository);

  @override
  Future<Either<Failure, AddressEntity>> call(
    UpdateAddressParams params,
  ) async {
    return await repository.updateAddress(
      params.addressId,
      name: params.name,
      phone: params.phone,
      address: params.address,
      isDefault: params.isDefault,
    );
  }
}

class UpdateAddressParams extends Equatable {
  final String addressId;
  final String? name;
  final String? phone;
  final String? address;
  final bool? isDefault;

  const UpdateAddressParams({
    required this.addressId,
    this.name,
    this.phone,
    this.address,
    this.isDefault,
  });

  @override
  List<Object?> get props => [addressId, name, phone, address, isDefault];
}
