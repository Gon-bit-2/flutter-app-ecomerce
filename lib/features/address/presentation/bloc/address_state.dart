import 'package:equatable/equatable.dart';
import '../../domain/entities/address_entity.dart';

abstract class AddressState extends Equatable {
  const AddressState();

  @override
  List<Object?> get props => [];
}

class AddressInitial extends AddressState {}

class AddressLoading extends AddressState {}

class AddressesLoaded extends AddressState {
  final List<AddressEntity> addresses;

  const AddressesLoaded({required this.addresses});

  @override
  List<Object?> get props => [addresses];
}

class AddressActionSuccess extends AddressState {
  final String message;

  const AddressActionSuccess({required this.message});

  @override
  List<Object?> get props => [message];
}

class AddressError extends AddressState {
  final String message;

  const AddressError({required this.message});

  @override
  List<Object?> get props => [message];
}
