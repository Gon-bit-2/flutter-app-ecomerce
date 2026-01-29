import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final int id;
  final String email;
  final String name;
  final String? phoneNumber;
  final String? avatar;
  final int? roleId;
  final String? totpSecret;

  const UserEntity({
    required this.id,
    required this.email,
    required this.name,
    this.phoneNumber,
    this.avatar,
    this.roleId,
    this.totpSecret,
  });

  // Equatable giúp so sánh 2 object.
  // Nếu user A và user B có cùng id, email... thì A == B là true.
  @override
  List<Object?> get props => [
    id,
    email,
    name,
    phoneNumber,
    avatar,
    roleId,
    totpSecret,
  ];

  UserEntity copyWith({
    int? id,
    String? email,
    String? name,
    String? phoneNumber,
    String? avatar,
    int? roleId,
    String? totpSecret,
    bool nullTotpSecret = false,
  }) {
    return UserEntity(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      avatar: avatar ?? this.avatar,
      roleId: roleId ?? this.roleId,
      totpSecret: nullTotpSecret ? null : (totpSecret ?? this.totpSecret),
    );
  }
}
