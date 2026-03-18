import 'package:equatable/equatable.dart';

abstract class SearchEvent extends Equatable {
  const SearchEvent();

  @override
  List<Object?> get props => [];
}

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
