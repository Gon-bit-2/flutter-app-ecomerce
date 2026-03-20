import 'package:equatable/equatable.dart';

abstract class SearchEvent extends Equatable {
  const SearchEvent();

  @override
  List<Object?> get props => [];
}

/// Khi khởi tạo trang, load lịch sử
class SearchInitRequested extends SearchEvent {}

/// Khi user thay đổi text trong thanh search
class SearchQueryChanged extends SearchEvent {
  final String query;

  const SearchQueryChanged(this.query);

  @override
  List<Object?> get props => [query];
}

/// Khi cuộn xuống cuối danh sách, load thêm kết quả
class SearchLoadMore extends SearchEvent {}

/// Khi user bấm clear hoặc xóa hết text
class SearchCleared extends SearchEvent {}

/// Khi user chọn một từ khóa từ lịch sử
class SearchHistorySelected extends SearchEvent {
  final String query;

  const SearchHistorySelected(this.query);

  @override
  List<Object?> get props => [query];
}

/// Xóa một mục trong lịch sử
class SearchHistoryDeleted extends SearchEvent {
  final String query;

  const SearchHistoryDeleted(this.query);

  @override
  List<Object?> get props => [query];
}

/// Xóa sạch lịch sử
class SearchHistoryCleared extends SearchEvent {}

/// Thay đổi bộ lọc hoặc sắp xếp
class SearchFilterChanged extends SearchEvent {
  final double? minPrice;
  final double? maxPrice;
  final String? sortBy;
  final String? categoryId;

  const SearchFilterChanged({
    this.minPrice,
    this.maxPrice,
    this.sortBy,
    this.categoryId,
  });

  @override
  List<Object?> get props => [minPrice, maxPrice, sortBy, categoryId];
}
