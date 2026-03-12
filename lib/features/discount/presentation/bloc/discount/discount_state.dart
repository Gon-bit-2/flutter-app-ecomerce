import 'package:equatable/equatable.dart';
import '../../../domain/entities/discount.dart';

abstract class DiscountState extends Equatable {
  const DiscountState();

  @override
  List<Object?> get props => [];
}

class DiscountInitial extends DiscountState {}

class DiscountLoading extends DiscountState {}

class MyVouchersLoaded extends DiscountState {
  final List<Discount> vouchers;

  const MyVouchersLoaded({required this.vouchers});

  @override
  List<Object?> get props => [vouchers];
}

class AvailableDiscountsLoaded extends DiscountState {
  final List<Discount> vouchers;

  const AvailableDiscountsLoaded({required this.vouchers});

  @override
  List<Object?> get props => [vouchers];
}

class DiscountError extends DiscountState {
  final String message;

  const DiscountError({required this.message});

  @override
  List<Object?> get props => [message];
}

class DiscountPreviewLoading extends DiscountState {}

class DiscountPreviewLoaded extends DiscountState {
  final Map<String, dynamic> previewData;

  const DiscountPreviewLoaded({required this.previewData});

  @override
  List<Object?> get props => [previewData];
}

class SaveVoucherLoading extends DiscountState {}

class SaveVoucherSuccess extends DiscountState {
  final int discountId;

  const SaveVoucherSuccess({required this.discountId});

  @override
  List<Object?> get props => [discountId];
}
