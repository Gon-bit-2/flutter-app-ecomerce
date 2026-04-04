import 'package:equatable/equatable.dart';
import '../../domain/entities/shop_statistics.dart';

abstract class ShopStatisticsState extends Equatable {
  const ShopStatisticsState();

  @override
  List<Object?> get props => [];
}

class ShopStatisticsInitial extends ShopStatisticsState {}

class ShopStatisticsLoading extends ShopStatisticsState {}

class ShopStatisticsLoaded extends ShopStatisticsState {
  final ShopStatistics statistics;

  const ShopStatisticsLoaded({required this.statistics});

  @override
  List<Object?> get props => [statistics];
}

class ShopStatisticsError extends ShopStatisticsState {
  final String message;

  const ShopStatisticsError({required this.message});

  @override
  List<Object?> get props => [message];
}
