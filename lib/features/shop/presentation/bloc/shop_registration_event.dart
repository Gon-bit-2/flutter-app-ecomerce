import 'package:equatable/equatable.dart';

abstract class ShopRegistrationEvent extends Equatable {
  const ShopRegistrationEvent();

  @override
  List<Object?> get props => [];
}

class CheckShopStatus extends ShopRegistrationEvent {}

class RegisterShopSubmitted extends ShopRegistrationEvent {
  final String name;
  final String description;
  final String phoneNumber;
  final String address;
  final String email;

  const RegisterShopSubmitted({
    required this.name,
    required this.description,
    required this.phoneNumber,
    required this.address,
    required this.email,
  });

  @override
  List<Object?> get props => [name, description, phoneNumber, address, email];
}
