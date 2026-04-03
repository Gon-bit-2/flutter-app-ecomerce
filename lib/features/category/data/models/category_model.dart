import 'dart:convert';
import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/category.dart';

part 'category_model.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake, createFactory: false)
class CategoryModel extends CategoryEntity {
  const CategoryModel({
    required super.id,
    required super.name,
    super.logo,
    super.parentCategoryId,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    String? logoUrl = json['logo'] as String?;
    
    if (logoUrl != null && logoUrl.isNotEmpty) {
      if (logoUrl.startsWith('{')) {
        try {
          final decoded = jsonDecode(logoUrl);
          if (decoded is Map && decoded.containsKey('data')) {
            final dataList = decoded['data'] as List;
            if (dataList.isNotEmpty && dataList.first is Map) {
              logoUrl = dataList.first['url'];
            }
          }
        } catch (e) {
          // Keep original if parse fails
        }
      } else if (logoUrl.startsWith('url: ')) {
        logoUrl = logoUrl.replaceFirst('url: ', '').trim();
      }
    }

    return CategoryModel(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      logo: logoUrl,
      parentCategoryId: (json['parent_category_id'] as num?)?.toInt(),
    );
  }

  Map<String, dynamic> toJson() => _$CategoryModelToJson(this);
}
