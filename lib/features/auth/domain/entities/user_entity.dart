import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final int id;
  final String email;
  final String name;
  final String? phoneNumber;
  final String? avatar;
  final int? roleId;

  const UserEntity({
    required this.id,
    required this.email,
    required this.name,
    this.phoneNumber,
    this.avatar,
    this.roleId,
  });

  // Equatable giúp so sánh 2 object.
  // Nếu user A và user B có cùng id, email... thì A == B là true.
  @override
  List<Object?> get props => [id, email, name, phoneNumber, avatar, roleId];
}
