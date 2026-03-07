import 'package:equatable/equatable.dart';

class AddressEntity extends Equatable {
  final int id;
  final String name;
  final String phone;
  final String address;
  final bool isDefault;
  final DateTime createdAt;
  final DateTime updatedAt;

  const AddressEntity({
    required this.id,
    required this.name,
    required this.phone,
    required this.address,
    required this.isDefault,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
    id,
    name,
    phone,
    address,
    isDefault,
    createdAt,
    updatedAt,
  ];
}
