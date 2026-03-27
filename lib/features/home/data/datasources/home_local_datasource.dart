import 'package:injectable/injectable.dart';

import '../../domain/entities/flash_sale_entity.dart';
import '../../domain/entities/banner_entity.dart';
import '../../../product/domain/entities/product.dart';

// Since we are mocking, we can return Entities or Models. Clean arch says Models.
// But I haven't created BannerModel, I only created BannerEntity.
// I will create inline BannerModel or just return Entities if I don't care about JSON for mock.
// I'll accept returning Entities for Mock DS.

abstract class HomeLocalDataSource {
  Future<List<BannerEntity>> getBanners();
  Future<FlashSaleEntity> getFlashSale();
}

@LazySingleton(as: HomeLocalDataSource)
class HomeLocalDataSourceImpl implements HomeLocalDataSource {
  @override
  Future<List<BannerEntity>> getBanners() async {
    await Future.delayed(const Duration(milliseconds: 500)); // Simulate delay
    return [
      const BannerEntity(
        id: 1,
        imageUrl: 'https://res.cloudinary.com/dp5b7jl8y/image/upload/v1774599419/images/5e993a34-d523-42e7-bcaf-f1cd8dee7b1c.png',
        link: '',
      ),
      const BannerEntity(
        id: 2,
        imageUrl: 'https://res.cloudinary.com/dp5b7jl8y/image/upload/v1774599422/images/6cbf0fa2-94e1-48af-8a80-5021eb88fad5.png',
      ),
      const BannerEntity(
        id: 3,
        imageUrl: 'https://res.cloudinary.com/dp5b7jl8y/image/upload/v1774599423/images/6cb63cb3-eb43-47ee-b5d0-79c0acca88e5.png',
      ),
    ];
  }

  @override
  Future<FlashSaleEntity> getFlashSale() async {
    await Future.delayed(const Duration(milliseconds: 500));
    final mockProducts = List.generate(
      5,
      (index) => Product(
        id: index + 100,
        name: 'Flash Product $index',
        basePrice: 50000 + (index * 10000),
        virtualPrice: 100000 + (index * 10000),
        images: ['https://picsum.photos/300/300?random=${index + 10}'],
        sold: 10 + index,
        brandId: 1,
        description:
            'This is a detailed description of Flash Product $index. It features high quality materials, advanced technology, and a sleek design suitable for all users. Warranty included.',
      ),
    );

    return FlashSaleEntity(
      endTime: DateTime.now().add(const Duration(hours: 3, minutes: 30)),
      products: mockProducts,
    );
  }
}
