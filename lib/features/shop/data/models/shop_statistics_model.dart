import '../../domain/entities/shop_statistics.dart';

class ShopStatisticsModel extends ShopStatistics {
  const ShopStatisticsModel({
    required StatisticPeriodModel today,
    required StatisticPeriodModel thisMonth,
  }) : super(today: today, thisMonth: thisMonth);

  factory ShopStatisticsModel.fromJson(Map<String, dynamic> json) {
    return ShopStatisticsModel(
      today: StatisticPeriodModel.fromJson(json['today'] ?? {}),
      thisMonth: StatisticPeriodModel.fromJson(json['thisMonth'] ?? {}),
    );
  }
}

class StatisticPeriodModel extends StatisticPeriod {
  const StatisticPeriodModel({
    required super.totalOrders,
    required super.totalRevenue,
  });

  factory StatisticPeriodModel.fromJson(Map<String, dynamic> json) {
    return StatisticPeriodModel(
      totalOrders: json['totalOrders'] ?? 0,
      totalRevenue: (json['totalRevenue'] ?? 0).toDouble(),
    );
  }
}
