import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/user_entity.dart';

// Dòng này báo cho máy biết file code sinh ra sẽ tên là user_model.g.dart
part 'user_model.g.dart';

@JsonSerializable()
class UserModel extends UserEntity {
  // Constructor
  const UserModel({
    required super.id,
    required super.email,
    required super.name,
    super.phoneNumber,
    super.avatar,
    super.roleId,
    super.totpSecret,
  });

  // Hàm factory để tạo UserModel từ JSON (Do máy tự viết)
  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  // Hàm để chuyển UserModel thành JSON (để gửi lên server nếu cần)
  Map<String, dynamic> toJson() => _$UserModelToJson(this);
}
