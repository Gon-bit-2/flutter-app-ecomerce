import 'package:equatable/equatable.dart';
import '../../../product/domain/entities/product.dart';

class FlashSaleEntity extends Equatable {
  final DateTime endTime;
  final List<Product> products;

  const FlashSaleEntity({required this.endTime, required this.products});

  @override
  List<Object?> get props => [endTime, products];
}
