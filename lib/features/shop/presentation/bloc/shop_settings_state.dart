import 'package:equatable/equatable.dart';

abstract class ShopSettingsState extends Equatable {
  const ShopSettingsState();

  @override
  List<Object?> get props => [];
}

class ShopSettingsInitial extends ShopSettingsState {}

class ShopSettingsLoading extends ShopSettingsState {}

class ShopSettingsSuccess extends ShopSettingsState {
  final String message;

  const ShopSettingsSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class ShopSettingsError extends ShopSettingsState {
  final String message;

  const ShopSettingsError(this.message);

  @override
  List<Object?> get props => [message];
}
