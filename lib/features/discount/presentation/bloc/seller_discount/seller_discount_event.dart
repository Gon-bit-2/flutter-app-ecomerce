import 'package:equatable/equatable.dart';

abstract class SellerDiscountEvent extends Equatable {
  const SellerDiscountEvent();

  @override
  List<Object?> get props => [];
}

class FetchSellerDiscounts extends SellerDiscountEvent {
  final int page;
  final int limit;
  final int? shopId;
  final String? type;
  final String? scope;
  final bool? isActive;
  final String? search;

  const FetchSellerDiscounts({
    this.page = 1,
    this.limit = 10,
    this.shopId,
    this.type,
    this.scope,
    this.isActive,
    this.search,
  });

  @override
  List<Object?> get props => [
    page,
    limit,
    shopId,
    type,
    scope,
    isActive,
    search,
  ];
}

class CreateNewDiscount extends SellerDiscountEvent {
  final Map<String, dynamic> data;

  const CreateNewDiscount({required this.data});

  @override
  List<Object?> get props => [data];
}

class UpdateExistingDiscount extends SellerDiscountEvent {
  final int discountId;
  final Map<String, dynamic> data;

  const UpdateExistingDiscount({required this.discountId, required this.data});

  @override
  List<Object?> get props => [discountId, data];
}

class DeleteExistingDiscount extends SellerDiscountEvent {
  final int discountId;

  const DeleteExistingDiscount({required this.discountId});

  @override
  List<Object?> get props => [discountId];
}
