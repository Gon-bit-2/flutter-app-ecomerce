import 'package:equatable/equatable.dart';

abstract class DiscountEvent extends Equatable {
  const DiscountEvent();

  @override
  List<Object?> get props => [];
}

class FetchMyVouchers extends DiscountEvent {
  final int page;
  final int limit;

  const FetchMyVouchers({this.page = 1, this.limit = 10});

  @override
  List<Object?> get props => [page, limit];
}

class FetchAvailableDiscounts extends DiscountEvent {
  final int page;
  final int limit;

  const FetchAvailableDiscounts({this.page = 1, this.limit = 10});

  @override
  List<Object?> get props => [page, limit];
}

class DoPreviewDiscount extends DiscountEvent {
  final String code;
  final double orderValue;
  final int userId;
  final int shopId;
  final List<Map<String, dynamic>> items;

  const DoPreviewDiscount({
    required this.code,
    required this.orderValue,
    required this.userId,
    required this.shopId,
    required this.items,
  });

  @override
  List<Object?> get props => [code, orderValue, userId, shopId, items];
}

class SaveVoucherRequested extends DiscountEvent {
  final int discountId;

  const SaveVoucherRequested({required this.discountId});

  @override
  List<Object?> get props => [discountId];
}
