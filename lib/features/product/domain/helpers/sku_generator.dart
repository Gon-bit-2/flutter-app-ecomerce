import 'package:flutter/foundation.dart';

class SkuGenerator {
  /// Sinh các tổ hợp SKU dựa trên các nhóm tùy chọn (options).
  /// Chạy dưới background Isolate để tránh làm lag UI.
  static Future<List<String>> generateAsync(
    List<List<String>> optionGroups,
  ) async {
    // Nếu optionGroups rỗng hoặc chả có gì, trả về default
    if (optionGroups.isEmpty || optionGroups.every((g) => g.isEmpty)) {
      return ['Default'];
    }

    // Lọc bỏ những options rỗng
    final validOptionGroups = optionGroups
        .map((g) => g.where((o) => o.trim().isNotEmpty).toList())
        .where((g) => g.isNotEmpty)
        .toList();

    if (validOptionGroups.isEmpty) {
      return ['Default'];
    }

    // Dùng compute để chuyển toán học sang background Isolate
    return await compute(_buildSkuValues, validOptionGroups);
  }

  /// Thuật toán đếm tổ hợp Cartesian Product thuần túy (Pure logic)
  static List<String> _buildSkuValues(List<List<String>> optionGroups) {
    if (optionGroups.isEmpty) {
      return ['Default'];
    }

    List<String> results = [''];
    for (final group in optionGroups) {
      final nextResults = <String>[];
      for (final prefix in results) {
        for (final option in group) {
          // Nối thêm option vào, cách nhau bằng dấu phẩy
          nextResults.add(prefix.isEmpty ? option : '$prefix, $option');
        }
      }
      results = nextResults;
    }
    return results;
  }
}
