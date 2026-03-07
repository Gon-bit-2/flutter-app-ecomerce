import 'package:fpdart/fpdart.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/usecase/usecase.dart';
import '../repositories/address_repository.dart';

@lazySingleton
class SetDefaultAddressUseCase
    implements UseCase<void, SetDefaultAddressParams> {
  final AddressRepository repository;

  SetDefaultAddressUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(SetDefaultAddressParams params) async {
    return await repository.setDefaultAddress(params.addressId);
  }
}

class SetDefaultAddressParams extends Equatable {
  final String addressId;

  const SetDefaultAddressParams({required this.addressId});

  @override
  List<Object?> get props => [addressId];
}
