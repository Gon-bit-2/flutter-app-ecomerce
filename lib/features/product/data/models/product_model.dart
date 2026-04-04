import 'package:json_annotation/json_annotation.dart';
import 'dart:convert';
import '../../../../core/constants/app_constants.dart';
import '../../domain/entities/product.dart';
import 'sku_model.dart';

part 'product_model.g.dart';

@JsonSerializable(explicitToJson: true)
class ProductModel extends Product {
  @override
  final List<SKUModel> skus;

  const ProductModel({
    required super.id,
    required super.name,
    required super.basePrice,
    super.virtualPrice,
    required super.images,
    required super.brandId,
    super.brandName,
    super.categoryIds,
    super.publishedAt,
    this.skus = const [],
    super.variants,
    super.description,
    super.createdById,
    super.shopName,
    super.shopAvatar,
    super.rating,
    super.sold,
    super.isMall,
    super.isPreferred,
  }) : super(skus: skus);

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic> params = Map<String, dynamic>.from(json);

    // Helper to fix URL prefix
    String fixUrl(String url) {
      if (url.startsWith('http')) return url;
      return url.startsWith('/')
          ? '${AppConstants.baseUrl}$url'
          : '${AppConstants.baseUrl}/$url';
    }

    // Helper to extract clean URL from potentially messy strings
    String cleanUrl(dynamic input) {
      if (input == null) return '';
      String str = input.toString().trim();

      // Handle "url: " prefix
      if (str.toLowerCase().startsWith('url:')) {
        str = str.substring(4).trim();
      }

      // Handle accidentally JSON stringified values (e.g. "[\"url\"]")
      if (str.startsWith('[') || str.startsWith('{')) {
        try {
          final decoded = jsonDecode(str);
          if (decoded is List && decoded.isNotEmpty) {
            return cleanUrl(decoded.first);
          }
          if (decoded is Map && decoded.containsKey('url')) {
            return cleanUrl(decoded['url']);
          }
          if (decoded is Map && decoded.containsKey('link')) {
            return cleanUrl(decoded['link']);
          }
        } catch (_) {}
      }

      return str;
    }

    // Process images
    if (params['images'] != null) {
      dynamic rawImages = params['images'];
      List<String> parsedImages = [];

      void addImage(dynamic item) {
        String cleaned = cleanUrl(item);
        if (cleaned.isNotEmpty) {
          parsedImages.add(fixUrl(cleaned));
        }
      }

      if (rawImages is List) {
        for (var item in rawImages) {
          addImage(item);
        }
      } else if (rawImages is String) {
        // Handle case where the whole list is stringified
        try {
          final decoded = jsonDecode(rawImages);
          if (decoded is List) {
            for (var item in decoded) {
              addImage(item);
            }
          } else {
            addImage(rawImages);
          }
        } catch (_) {
          addImage(rawImages);
        }
      }

      params['images'] = parsedImages;
    }

    final model = _$ProductModelFromJson(params);

    // Fix SKU images
    List<SKUModel> fixedSkus = model.skus.map((sku) {
      if (sku.image.isNotEmpty) {
        String cleaned = cleanUrl(sku.image);
        if (cleaned.isNotEmpty) {
          return SKUModel(
            id: sku.id,
            value: sku.value,
            price: sku.price,
            stock: sku.stock,
            image: fixUrl(cleaned),
            productId: sku.productId,
          );
        }
      }
      return sku;
    }).toList();

    // Parse categories manually
    List<int>? parsedCategoryIds;
    if (params['categories'] != null && params['categories'] is List) {
      parsedCategoryIds = (params['categories'] as List)
          .map((c) => c is Map ? (c['id'] as int?) : null)
          .where((id) => id != null)
          .cast<int>()
          .toList();
    }

    // Parse brand name manually
    String? parsedBrandName;
    if (params['brand'] != null && params['brand'] is Map) {
      parsedBrandName = params['brand']['name'] as String?;
    }

    // Parse shop info from 'user' nested object (createdBy)
    int? parsedCreatedById;
    String? parsedShopName;
    String? parsedShopAvatar;
    if (params['createdById'] != null) {
      parsedCreatedById = (params['createdById'] as num).toInt();
    }
    if (params['user'] != null && params['user'] is Map) {
      final user = params['user'] as Map;
      parsedShopName = user['name'] as String?;
      parsedShopAvatar = user['avatar'] as String?;
      parsedCreatedById ??= (user['id'] as num?)?.toInt();
    }

    // Extract description from productTranslations if available
    String? parsedDescription = model.description;
    if (params['productTranslations'] != null && params['productTranslations'] is List) {
      final translations = params['productTranslations'] as List;
      var vnTrans = translations.firstWhere((t) => t is Map && t['languageId'] == 'vn', orElse: () => null);
      var enTrans = translations.firstWhere((t) => t is Map && t['languageId'] == 'en', orElse: () => null);

      if (vnTrans != null && vnTrans['description'] != null && vnTrans['description'].toString().trim().isNotEmpty) {
        parsedDescription = vnTrans['description'] as String;
      } else if (enTrans != null && enTrans['description'] != null && enTrans['description'].toString().trim().isNotEmpty) {
         parsedDescription = enTrans['description'] as String;
      }
    }

    return ProductModel(
      id: model.id,
      name: model.name,
      basePrice: model.basePrice,
      virtualPrice: model.virtualPrice,
      images: model.images,
      brandId: model.brandId,
      brandName: parsedBrandName ?? model.brandName,
      categoryIds: parsedCategoryIds ?? model.categoryIds,
      publishedAt: model.publishedAt,
      skus: fixedSkus,
      variants: model.variants,
      description: parsedDescription,
      createdById: parsedCreatedById,
      shopName: parsedShopName,
      shopAvatar: parsedShopAvatar,
      rating: model.rating,
      sold: model.sold,
      isMall: model.isMall,
      isPreferred: model.isPreferred,
    );
  }

  Map<String, dynamic> toJson() => _$ProductModelToJson(this);
}
