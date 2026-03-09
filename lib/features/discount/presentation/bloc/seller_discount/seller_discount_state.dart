import 'package:equatable/equatable.dart';
import '../../../domain/entities/discount.dart';

abstract class SellerDiscountState extends Equatable {
  const SellerDiscountState();

  @override
  List<Object?> get props => [];
}

class SellerDiscountInitial extends SellerDiscountState {}

class SellerDiscountLoading extends SellerDiscountState {}

class SellerDiscountsLoaded extends SellerDiscountState {
  final List<Discount> discounts;
  final bool hasReachedMax;

  const SellerDiscountsLoaded({
    required this.discounts,
    this.hasReachedMax = false,
  });

  @override
  List<Object?> get props => [discounts, hasReachedMax];
}

class SellerDiscountOperationSuccess extends SellerDiscountState {
  final String message;

  const SellerDiscountOperationSuccess({required this.message});

  @override
  List<Object?> get props => [message];
}

class SellerDiscountError extends SellerDiscountState {
  final String message;

  const SellerDiscountError({required this.message});

  @override
  List<Object?> get props => [message];
}
