import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/address_entity.dart';
import '../repositories/address_repository.dart';

@lazySingleton
class GetAddressesUseCase implements UseCase<List<AddressEntity>, NoParams> {
  final AddressRepository repository;

  GetAddressesUseCase(this.repository);

  @override
  Future<Either<Failure, List<AddressEntity>>> call(NoParams params) async {
    return await repository.getAddresses();
  }
}
