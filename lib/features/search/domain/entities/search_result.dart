import 'package:equatable/equatable.dart';
import '../../../product/domain/entities/product.dart';

class SearchResult extends Equatable {
  final List<Product> products;
  final int totalCount;

  const SearchResult({
    required this.products,
    required this.totalCount,
  });

  @override
  List<Object?> get props => [products, totalCount];
}
