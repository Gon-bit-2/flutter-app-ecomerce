part of 'category_bloc.dart';

abstract class CategoryState extends Equatable {
  const CategoryState();

  @override
  List<Object> get props => [];
}

// 1. Trạng thái ban đầu
class CategoryInitial extends CategoryState {}

// 2. Đang tải
class CategoryLoading extends CategoryState {}

// 3. Tải danh sách danh mục thành công
class CategoryLoaded extends CategoryState {
  final List<CategoryEntity> categories;

  const CategoryLoaded(this.categories);

  @override
  List<Object> get props => [categories];
}

// 4. Tải chi tiết 1 danh mục thành công
class CategoryDetailLoaded extends CategoryState {
  final CategoryEntity category;

  const CategoryDetailLoaded(this.category);

  @override
  List<Object> get props => [category];
}

// 5. Thao tác CRUD thành công
class CategoryOperationSuccess extends CategoryState {
  final String message;

  const CategoryOperationSuccess({required this.message});

  @override
  List<Object> get props => [message];
}

// 6. Lỗi
class CategoryFailure extends CategoryState {
  final String message;

  const CategoryFailure(this.message);

  @override
  List<Object> get props => [message];
}
