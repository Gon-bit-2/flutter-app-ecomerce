import 'package:equatable/equatable.dart';
import '../../domain/entities/shop_entity.dart';

abstract class ShopRegistrationState extends Equatable {
  const ShopRegistrationState();

  @override
  List<Object?> get props => [];
}

class ShopRegistrationInitial extends ShopRegistrationState {}

class ShopStatusLoading extends ShopRegistrationState {}

class ShopStatusLoaded extends ShopRegistrationState {
  final ShopEntity? shop;

  const ShopStatusLoaded({this.shop});

  @override
  List<Object?> get props => [shop];
}

class ShopRegistrationLoading extends ShopRegistrationState {}

class ShopRegistrationSuccess extends ShopRegistrationState {}

class ShopRegistrationFailure extends ShopRegistrationState {
  final String message;

  const ShopRegistrationFailure({required this.message});

  @override
  List<Object?> get props => [message];
}

class ShopStatusCheckFailure extends ShopRegistrationState {
  final String message;

  const ShopStatusCheckFailure({required this.message});

  @override
  List<Object?> get props => [message];
}
