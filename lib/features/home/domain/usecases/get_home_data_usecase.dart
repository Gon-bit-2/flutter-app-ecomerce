import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../../../category/domain/entities/category.dart';
import '../../../category/domain/repositories/category_repository.dart';
import '../../../product/domain/entities/product.dart';
import '../../../product/domain/repositories/product_repository.dart';
import '../entities/banner_entity.dart';
import '../entities/flash_sale_entity.dart';
import '../repositories/home_repository.dart';

class HomeData {
  final List<BannerEntity> banners;
  final List<CategoryEntity> categories;
  final FlashSaleEntity flashSale;

  HomeData({
    required this.banners,
    required this.categories,
    required this.flashSale,
  });
}

@lazySingleton
class GetHomeDataUseCase implements UseCase<HomeData, NoParams> {
  final HomeRepository homeRepository;
  final CategoryRepository categoryRepository;
  final ProductRepository productRepository;

  GetHomeDataUseCase(
    this.homeRepository,
    this.categoryRepository,
    this.productRepository,
  );

  @override
  Future<Either<Failure, HomeData>> call(NoParams params) async {
    // Parallel fetching
    final results = await Future.wait([
      homeRepository.getBanners(),
      categoryRepository.getCategories(),
      productRepository.getProducts(page: 1, limit: 10), // Treat as Flash Sale
    ]);

    final bannerResult = results[0] as Either<Failure, List<BannerEntity>>;
    final categoryResult = results[1] as Either<Failure, List<CategoryEntity>>;
    final productResult = results[2] as Either<Failure, List<Product>>;

    if (categoryResult.isLeft()) {
      return Left(
        (categoryResult as Left<Failure, List<CategoryEntity>>).value,
      );
    }

    // We can also check productResult if strict

    List<BannerEntity> banners = [];
    List<CategoryEntity> categories = [];
    List<Product> flashSaleProducts = [];

    bannerResult.fold((l) => null, (r) => banners = r);
    categoryResult.fold((l) => null, (r) => categories = r);
    productResult.fold((l) => null, (r) => flashSaleProducts = r);

    return Right(
      HomeData(
        banners: banners,
        categories: categories,
        flashSale: FlashSaleEntity(
          endTime: DateTime.now().add(const Duration(hours: 2)), // Mock time
          products: flashSaleProducts,
        ),
      ),
    );
  }
}
