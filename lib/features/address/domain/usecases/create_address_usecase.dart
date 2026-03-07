import 'package:fpdart/fpdart.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/address_entity.dart';
import '../repositories/address_repository.dart';

@lazySingleton
class CreateAddressUseCase
    implements UseCase<AddressEntity, CreateAddressParams> {
  final AddressRepository repository;

  CreateAddressUseCase(this.repository);

  @override
  Future<Either<Failure, AddressEntity>> call(
    CreateAddressParams params,
  ) async {
    return await repository.createAddress(
      name: params.name,
      phone: params.phone,
      address: params.address,
      isDefault: params.isDefault,
    );
  }
}

class CreateAddressParams extends Equatable {
  final String name;
  final String phone;
  final String address;
  final bool? isDefault;

  const CreateAddressParams({
    required this.name,
    required this.phone,
    required this.address,
    this.isDefault,
  });

  @override
  List<Object?> get props => [name, phone, address, isDefault];
}
