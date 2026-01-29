import 'package:equatable/equatable.dart';

class Category extends Equatable {
  final int id;
  final String name;
  final String? logo;
  final int? parentCategoryId;

  const Category({
    required this.id,
    required this.name,
    this.logo,
    this.parentCategoryId,
  });

  @override
  List<Object?> get props => [id, name, logo, parentCategoryId];
}
