import 'package:equatable/equatable.dart';
import '../../../../features/auth/domain/entities/user_entity.dart';

class ShopVideoComment extends Equatable {
  final int id;
  final String content;
  final DateTime createdAt;
  final UserEntity? user;
  final int? parentId;
  final List<ShopVideoComment> replies;

  const ShopVideoComment({
    required this.id,
    required this.content,
    required this.createdAt,
    this.user,
    this.parentId,
    this.replies = const [],
  });

  @override
  List<Object?> get props => [
        id,
        content,
        createdAt,
        user,
        parentId,
        replies,
      ];
}
