import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:app_fe_ecomerce/features/brand/domain/entities/brand.dart';
import 'package:app_fe_ecomerce/features/brand/domain/repositories/brand_repository.dart';
import 'package:app_fe_ecomerce/features/category/domain/entities/category.dart';
import 'package:app_fe_ecomerce/features/category/domain/repositories/category_repository.dart';
import 'package:app_fe_ecomerce/features/common/domain/repositories/common_repository.dart';
import 'package:app_fe_ecomerce/features/product/domain/entities/product.dart';
import 'package:app_fe_ecomerce/features/product/domain/repositories/product_repository.dart';
import 'package:app_fe_ecomerce/features/product/presentation/bloc/add_product/add_product_bloc.dart';
import 'package:app_fe_ecomerce/features/product/presentation/bloc/add_product/add_product_event.dart';
import 'package:app_fe_ecomerce/features/product/presentation/bloc/add_product/add_product_state.dart';

class MockBrandRepository extends Mock implements BrandRepository {}

class MockCategoryRepository extends Mock implements CategoryRepository {}

class MockCommonRepository extends Mock implements CommonRepository {}

class MockProductRepository extends Mock implements ProductRepository {}

void main() {
  late AddProductBloc bloc;
  late MockBrandRepository brandRepository;
  late MockCategoryRepository categoryRepository;
  late MockCommonRepository commonRepository;
  late MockProductRepository productRepository;

  setUp(() {
    brandRepository = MockBrandRepository();
    categoryRepository = MockCategoryRepository();
    commonRepository = MockCommonRepository();
    productRepository = MockProductRepository();

    bloc = AddProductBloc(
      brandRepository: brandRepository,
      categoryRepository: categoryRepository,
      commonRepository: commonRepository,
      productRepository: productRepository,
    );
  });

  tearDown(() {
    bloc.close();
  });

  group('AddProductBloc', () {
    test('initial state is AddProductState', () {
      expect(bloc.state, const AddProductState());
    });

    test('AddProductStarted emits loading then initial with data', () async {
      final tBrands = [const Brand(id: 1, name: 'Brand 1', logo: 'logo')];
      final tCategories = [
        const Category(id: 1, name: 'Category 1', image: 'img'),
      ];

      when(
        () => brandRepository.getBrands(),
      ).thenAnswer((_) async => Right(tBrands));
      when(
        () => categoryRepository.getCategories(),
      ).thenAnswer((_) async => Right(tCategories));

      bloc.add(const AddProductStarted());

      await expectLater(
        bloc.stream,
        emitsInOrder([
          isA<AddProductState>().having(
            (s) => s.status,
            'status',
            AddProductStatus.loading,
          ),
          isA<AddProductState>()
              .having((s) => s.status, 'status', AddProductStatus.initial)
              .having((s) => s.brands, 'brands', tBrands)
              .having((s) => s.categories, 'categories', tCategories)
              .having((s) => s.variants.length, 'variants length', 1),
        ]),
      );
    });

    group('SKU Generation Logic', () {
      test('generates correct SKUs when options are added', () async {
        // Pre-seed state with one variant
        // Since we can't easily seed bloc state without hack or emit,
        // we will simulate the flow from initial

        final tBrands = <Brand>[];
        final tCategories = <Category>[];
        when(
          () => brandRepository.getBrands(),
        ).thenAnswer((_) async => Right(tBrands));
        when(
          () => categoryRepository.getCategories(),
        ).thenAnswer((_) async => Right(tCategories));

        bloc.add(const AddProductStarted());
        await bloc.stream.firstWhere((s) => s.isDataLoaded);

        // Now add option
        bloc.add(const AddProductVariantOptionAdded(0, 'S'));

        await expectLater(
          bloc.stream,
          emitsThrough(
            isA<AddProductState>()
                .having((s) => s.skus.length, 'skus count', 1)
                .having((s) => s.skus[0].value, 'sku value', 'S'),
          ),
        );
      });

      test('generates combinations when multiple variants exist', () async {
        final tBrands = <Brand>[];
        final tCategories = <Category>[];
        when(
          () => brandRepository.getBrands(),
        ).thenAnswer((_) async => Right(tBrands));
        when(
          () => categoryRepository.getCategories(),
        ).thenAnswer((_) async => Right(tCategories));

        bloc.add(const AddProductStarted());
        await bloc.stream.firstWhere((s) => s.isDataLoaded);

        // Variant 1: S
        bloc.add(const AddProductVariantOptionAdded(0, 'S'));
        await bloc.stream.first; // wait for update

        // Add Variant 2
        bloc.add(AddProductVariantAdded());
        await bloc.stream.first;

        // Variant 2: Red
        // Note: Variant 2 is at index 1
        bloc.add(const AddProductVariantOptionAdded(1, 'Red'));

        await expectLater(
          bloc.stream,
          emitsThrough(
            isA<AddProductState>()
                .having((s) => s.skus.length, 'skus count', 1)
                .having((s) => s.skus[0].value, 'sku value', 'S, Red'),
          ),
        );
      });
    });
  });
}
