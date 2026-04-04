import 'package:equatable/equatable.dart';

class StatisticPeriod extends Equatable {
  final int totalOrders;
  final double totalRevenue;

  const StatisticPeriod({
    required this.totalOrders,
    required this.totalRevenue,
  });

  @override
  List<Object?> get props => [totalOrders, totalRevenue];
}

class ShopStatistics extends Equatable {
  final StatisticPeriod today;
  final StatisticPeriod thisMonth;

  const ShopStatistics({
    required this.today,
    required this.thisMonth,
  });

  @override
  List<Object?> get props => [today, thisMonth];
}
