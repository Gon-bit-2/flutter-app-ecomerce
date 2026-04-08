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
        imageUrl: 'https://res.cloudinary.com/dp5b7jl8y/image/upload/v1775575199/images/ba4e13ee-a5d1-401a-b324-cc77d4a71eea.jpg',
      ),
      const BannerEntity(
        id: 2,
        imageUrl: 'https://res.cloudinary.com/dp5b7jl8y/image/upload/v1775575201/images/7c646d7c-c106-4251-938d-1319b2945414.jpg',
      ),
      const BannerEntity(
        id: 3,
        imageUrl: 'https://res.cloudinary.com/dp5b7jl8y/image/upload/v1775575203/images/746b1511-45cc-4dea-83a7-274eae8131fe.jpg',
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
