import 'package:fpdart/fpdart.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/address_entity.dart';
import '../repositories/address_repository.dart';

@lazySingleton
class GetAddressDetailUseCase
    implements UseCase<AddressEntity, GetAddressDetailParams> {
  final AddressRepository repository;

  GetAddressDetailUseCase(this.repository);

  @override
  Future<Either<Failure, AddressEntity>> call(
    GetAddressDetailParams params,
  ) async {
    return await repository.getAddressDetail(params.addressId);
  }
}

class GetAddressDetailParams extends Equatable {
  final String addressId;

  const GetAddressDetailParams({required this.addressId});

  @override
  List<Object?> get props => [addressId];
}
