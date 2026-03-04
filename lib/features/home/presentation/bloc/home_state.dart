import 'package:equatable/equatable.dart';
import '../../domain/entities/banner_entity.dart';
import '../../domain/entities/flash_sale_entity.dart';
import '../../../category/domain/entities/category.dart';
import '../../../product/domain/entities/product.dart';

abstract class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object?> get props => [];
}

class HomeInitial extends HomeState {}

class HomeLoading extends HomeState {}

class HomeLoaded extends HomeState {
  final List<BannerEntity> banners;
  final List<CategoryEntity> categories;
  final FlashSaleEntity flashSale;
  final List<Product> dailyDiscoverProducts;
  final int dailyDiscoverPage;
  final bool hasMoreDailyDiscover;

  const HomeLoaded({
    required this.banners,
    required this.categories,
    required this.flashSale,
    required this.dailyDiscoverProducts,
    required this.dailyDiscoverPage,
    required this.hasMoreDailyDiscover,
  });

  HomeLoaded copyWith({
    List<BannerEntity>? banners,
    List<CategoryEntity>? categories,
    FlashSaleEntity? flashSale,
    List<Product>? dailyDiscoverProducts,
    int? dailyDiscoverPage,
    bool? hasMoreDailyDiscover,
  }) {
    return HomeLoaded(
      banners: banners ?? this.banners,
      categories: categories ?? this.categories,
      flashSale: flashSale ?? this.flashSale,
      dailyDiscoverProducts:
          dailyDiscoverProducts ?? this.dailyDiscoverProducts,
      dailyDiscoverPage: dailyDiscoverPage ?? this.dailyDiscoverPage,
      hasMoreDailyDiscover: hasMoreDailyDiscover ?? this.hasMoreDailyDiscover,
    );
  }

  @override
  List<Object?> get props => [
    banners,
    categories,
    flashSale,
    dailyDiscoverProducts,
    dailyDiscoverPage,
    hasMoreDailyDiscover,
  ];
}

class HomeError extends HomeState {
  final String message;

  const HomeError(this.message);

  @override
  List<Object> get props => [message];
}
