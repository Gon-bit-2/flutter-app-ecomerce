import 'package:equatable/equatable.dart';

class ShopInfo extends Equatable {
  final int id;
  final String name;
  final String? avatar;

  const ShopInfo({
    required this.id,
    required this.name,
    this.avatar,
  });

  @override
  List<Object?> get props => [id, name, avatar];
}
