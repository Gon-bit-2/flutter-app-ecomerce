import 'package:equatable/equatable.dart';

abstract class AddressEvent extends Equatable {
  const AddressEvent();

  @override
  List<Object?> get props => [];
}

class GetAddressesEvent extends AddressEvent {}

class CreateAddressEvent extends AddressEvent {
  final String name;
  final String phone;
  final String address;
  final bool? isDefault;

  const CreateAddressEvent({
    required this.name,
    required this.phone,
    required this.address,
    this.isDefault,
  });

  @override
  List<Object?> get props => [name, phone, address, isDefault];
}

class UpdateAddressEvent extends AddressEvent {
  final String addressId;
  final String? name;
  final String? phone;
  final String? address;
  final bool? isDefault;

  const UpdateAddressEvent({
    required this.addressId,
    this.name,
    this.phone,
    this.address,
    this.isDefault,
  });

  @override
  List<Object?> get props => [addressId, name, phone, address, isDefault];
}

class DeleteAddressEvent extends AddressEvent {
  final String addressId;

  const DeleteAddressEvent({required this.addressId});

  @override
  List<Object?> get props => [addressId];
}

class SetDefaultAddressEvent extends AddressEvent {
  final String addressId;

  const SetDefaultAddressEvent({required this.addressId});

  @override
  List<Object?> get props => [addressId];
}
