import 'package:equatable/equatable.dart';

class ShopEntity extends Equatable {
  final int id;
  final String name;
  final String? description;
  final String? phoneNumber;
  final String? address;
  final String? email;
  final String? avatar;
  final String status;

  const ShopEntity({
    required this.id,
    required this.name,
    this.description,
    this.phoneNumber,
    this.address,
    this.email,
    this.avatar,
    required this.status,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        phoneNumber,
        address,
        email,
        avatar,
        status,
      ];
}
