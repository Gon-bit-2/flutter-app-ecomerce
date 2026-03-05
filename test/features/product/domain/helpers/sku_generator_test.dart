import 'package:app_fe_ecomerce/features/product/domain/helpers/sku_generator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SkuGenerator', () {
    test('generateAsync should return ["Default"] for empty input', () async {
      final result = await SkuGenerator.generateAsync([]);
      expect(result, ['Default']);
    });

    test(
      'generateAsync should return ["Default"] for groups with empty strings',
      () async {
        final result = await SkuGenerator.generateAsync([
          ['', '  '],
        ]);
        expect(result, ['Default']);
      },
    );

    test('generateAsync should generate correct single sku', () async {
      final result = await SkuGenerator.generateAsync([
        ['Red'],
      ]);
      expect(result, ['Red']);
    });

    test(
      'generateAsync should generate correct Cartesian Product for 2 groups',
      () async {
        final groups = [
          ['Red', 'Blue'],
          ['S', 'M'],
        ];
        final result = await SkuGenerator.generateAsync(groups);
        expect(result.length, 4);
        expect(result, containsAll(['Red, S', 'Red, M', 'Blue, S', 'Blue, M']));
      },
    );

    test(
      'generateAsync should generate correct Cartesian Product for 3 groups',
      () async {
        final groups = [
          ['Red', 'Blue'],
          ['S', 'M'],
          ['Cotton'],
        ];
        final result = await SkuGenerator.generateAsync(groups);
        expect(result.length, 4); // 2 * 2 * 1
        expect(
          result,
          containsAll([
            'Red, S, Cotton',
            'Red, M, Cotton',
            'Blue, S, Cotton',
            'Blue, M, Cotton',
          ]),
        );
      },
    );

    test('generateAsync should ignore empty strings in valid groups', () async {
      final groups = [
        ['Red', '', 'Blue'],
        ['S', '   ', 'M'],
      ];
      final result = await SkuGenerator.generateAsync(groups);
      expect(result.length, 4);
      expect(result, containsAll(['Red, S', 'Red, M', 'Blue, S', 'Blue, M']));
    });
  });
}
