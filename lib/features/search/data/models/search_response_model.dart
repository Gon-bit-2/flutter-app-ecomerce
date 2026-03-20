import 'package:json_annotation/json_annotation.dart';
import '../../../product/data/models/product_model.dart';

part 'search_response_model.g.dart';

@JsonSerializable()
class SearchResponseModel {
  @JsonKey(name: 'data')
  final List<ProductModel> products;
  
  @JsonKey(name: 'total')
  final int totalCount;

  SearchResponseModel({
    required this.products,
    required this.totalCount,
  });

  factory SearchResponseModel.fromJson(Map<String, dynamic> json) {
    if (json.containsKey('data') && json['data'] is List) {
      return SearchResponseModel(
        products: (json['data'] as List)
            .map((e) => ProductModel.fromJson(e as Map<String, dynamic>))
            .toList(),
        totalCount: json['total'] ?? (json['data'] as List).length,
      );
    }
    // Fallback if the response is just a list
    if (json['data'] == null && json is List) {
       return SearchResponseModel(
        products: (json as List)
            .map((e) => ProductModel.fromJson(e as Map<String, dynamic>))
            .toList(),
        totalCount: (json as List).length,
      );
    }
    
    return SearchResponseModel(
      products: [],
      totalCount: 0,
    );
  }

  Map<String, dynamic> toJson() => _$SearchResponseModelToJson(this);
}
