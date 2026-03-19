// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'search_response_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SearchResponseModel _$SearchResponseModelFromJson(Map<String, dynamic> json) =>
    SearchResponseModel(
      products: (json['data'] as List<dynamic>)
          .map((e) => ProductModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      totalCount: (json['total'] as num).toInt(),
    );

Map<String, dynamic> _$SearchResponseModelToJson(
  SearchResponseModel instance,
) => <String, dynamic>{'data': instance.products, 'total': instance.totalCount};
