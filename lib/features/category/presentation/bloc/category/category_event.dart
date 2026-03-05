part of 'category_bloc.dart';

abstract class CategoryEvent extends Equatable {
  const CategoryEvent();

  @override
  List<Object> get props => [];
}

// Sự kiện: Tải danh sách danh mục
class CategoryLoadRequested extends CategoryEvent {
  final int? parentCategoryId;

  const CategoryLoadRequested({this.parentCategoryId});

  @override
  List<Object> get props => [if (parentCategoryId != null) parentCategoryId!];
}

// Sự kiện: Xem chi tiết 1 danh mục
class CategoryDetailRequested extends CategoryEvent {
  final int id;

  const CategoryDetailRequested({required this.id});

  @override
  List<Object> get props => [id];
}

// Sự kiện: Tạo danh mục mới
class CategoryCreated extends CategoryEvent {
  final String name;
  final String? logo;
  final int? parentCategoryId;

  const CategoryCreated({required this.name, this.logo, this.parentCategoryId});

  @override
  List<Object> get props => [
    name,
    if (logo != null) logo!,
    if (parentCategoryId != null) parentCategoryId!,
  ];
}

// Sự kiện: Cập nhật danh mục
class CategoryUpdated extends CategoryEvent {
  final int id;
  final String name;
  final String? logo;
  final int? parentCategoryId;

  const CategoryUpdated({
    required this.id,
    required this.name,
    this.logo,
    this.parentCategoryId,
  });

  @override
  List<Object> get props => [
    id,
    name,
    if (logo != null) logo!,
    if (parentCategoryId != null) parentCategoryId!,
  ];
}

// Sự kiện: Xóa danh mục
class CategoryDeleted extends CategoryEvent {
  final int id;

  const CategoryDeleted({required this.id});

  @override
  List<Object> get props => [id];
}
