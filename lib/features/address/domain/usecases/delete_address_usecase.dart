import 'package:fpdart/fpdart.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/usecase/usecase.dart';
import '../repositories/address_repository.dart';

@lazySingleton
class DeleteAddressUseCase implements UseCase<void, DeleteAddressParams> {
  final AddressRepository repository;

  DeleteAddressUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(DeleteAddressParams params) async {
    return await repository.deleteAddress(params.addressId);
  }
}

class DeleteAddressParams extends Equatable {
  final String addressId;

  const DeleteAddressParams({required this.addressId});

  @override
  List<Object?> get props => [addressId];
}
