import 'dart:convert';
import 'package:json_annotation/json_annotation.dart';
import '../../../../core/constants/app_constants.dart';
import '../../domain/entities/order_entity.dart';

part 'order_model.g.dart';

@JsonSerializable(explicitToJson: true, createFactory: false)
class OrderModel extends OrderEntity {
  @override
  final List<OrderItemModel>? items;

  const OrderModel({
    required super.id,
    super.shopId,
    super.status,
    super.totalAmount,
    super.receiverName,
    super.receiverPhone,
    super.receiverAddress,
    super.paymentMethod,
    super.paymentId,
    this.items,
    super.createdAt,
  }) : super(items: items);

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    num? totalAmountVal = json['totalAmount'] as num?;
    if (totalAmountVal == null && json['totalPrice'] != null) {
      totalAmountVal = json['totalPrice'] as num?;
    }

    String? rName = json['receiverName'] as String?;
    String? rPhone = json['receiverPhone'] as String?;
    String? rAddress = json['receiverAddress'] as String?;

    if (json['receiver'] != null && json['receiver'] is Map) {
      final receiverMap = json['receiver'] as Map;
      rName ??= receiverMap['name'] as String?;
      rPhone ??= receiverMap['phone'] as String?;
      rAddress ??= receiverMap['address'] as String?;
    } else if (json['userAddress'] != null && json['userAddress'] is Map) {
      final addressMap = json['userAddress'] as Map;
      rName ??= addressMap['name'] as String?;
      rPhone ??= addressMap['phoneNumber'] as String?;
      rAddress ??= addressMap['address'] as String?;
    }

    // Fallback: Lấy thông tin từ user object nếu các field trên tiếp tục null
    if (json['user'] != null && json['user'] is Map) {
      final userMap = json['user'] as Map;
      rName ??= userMap['name'] as String?;
      rPhone ??= userMap['phoneNumber'] ?? userMap['phone'] as String?;
    }

    // Nếu Total Amount = 0 hoặc null, tự động tính tổng tiền từ danh sách sản phẩm
    if (totalAmountVal == null || totalAmountVal == 0) {
      final itemsList = json['items'] as List<dynamic>?;
      if (itemsList != null) {
        num calculated = 0;
        for (var item in itemsList) {
          final price = item['price'] ?? item['skuPrice'] ?? 0;
          final quantity = item['quantity'] ?? 0;
          calculated += (price * quantity);
        }
        totalAmountVal = calculated;
      }
    }

    String? pMethod = json['paymentMethod'] as String?;
    if (pMethod == null && json['paymentId'] != null) {
      pMethod = 'SEPAY';
    }

    return OrderModel(
      id: (json['id'] as num).toInt(),
      shopId: (json['shopId'] as num?)?.toInt(),
      status: json['status'] as String?,
      totalAmount: totalAmountVal,
      receiverName: rName,
      receiverPhone: rPhone,
      receiverAddress: rAddress,
      paymentMethod: pMethod,
      paymentId: (json['paymentId'] as num?)?.toInt(),
      items: (json['items'] as List<dynamic>?)
          ?.map((e) => OrderItemModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.tryParse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() => _$OrderModelToJson(this);
}

class OrderItemModel extends OrderItemEntity {
  const OrderItemModel({
    required super.id,
    required super.skuId,
    super.productId,
    super.productName,
    super.skuValue,
    super.image,
    required super.price,
    required super.quantity,
    super.isReviewed = false,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    // Debug: In ra toàn bộ keys để biết backend trả về gì
    print('🔍 [OrderItem] JSON keys: ${json.keys.toList()}');
    print('🔍 [OrderItem] image field: ${json['image']}');
    if (json['product'] != null) print('🔍 [OrderItem] product: ${json['product']}');
    if (json['sku'] != null) print('🔍 [OrderItem] sku: ${json['sku']}');
    if (json['productSku'] != null) print('🔍 [OrderItem] productSku: ${json['productSku']}');

    // Helper to fix URL prefix
    String fixUrl(String url) {
      if (url.isEmpty || url.startsWith('http')) return url;
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
          if (decoded is Map) {
            if (decoded.containsKey('url')) return cleanUrl(decoded['url']);
            if (decoded.containsKey('link')) return cleanUrl(decoded['link']);
            if (decoded.containsKey('data') && decoded['data'] is List) {
              final dataList = decoded['data'] as List;
              if (dataList.isNotEmpty) return cleanUrl(dataList.first);
            }
          }
        } catch (_) {}
      }

      return str;
    }

    // Helper to extract first image URL from a list or string
    String? extractFirstImage(dynamic rawImages) {
      if (rawImages == null) return null;
      if (rawImages is List && rawImages.isNotEmpty) {
        final cleaned = cleanUrl(rawImages.first);
        if (cleaned.isNotEmpty) return cleaned;
      } else if (rawImages is String && rawImages.isNotEmpty) {
        // Có thể là JSON stringified list
        try {
          final decoded = jsonDecode(rawImages);
          if (decoded is List && decoded.isNotEmpty) {
            final cleaned = cleanUrl(decoded.first);
            if (cleaned.isNotEmpty) return cleaned;
          }
        } catch (_) {
          final cleaned = cleanUrl(rawImages);
          if (cleaned.isNotEmpty) return cleaned;
        }
      }
      return null;
    }

    // Backend trả về skuPrice thay vì price
    num priceVal = 0;
    if (json['price'] != null) {
      priceVal = json['price'] as num;
    } else if (json['skuPrice'] != null) {
      priceVal = json['skuPrice'] as num;
    }

    // Thử lấy ảnh từ nhiều nguồn khác nhau
    String? imageUrl;

    // 1. Lấy từ field 'image' trực tiếp
    if (json['image'] != null && json['image'].toString().isNotEmpty) {
      imageUrl = cleanUrl(json['image']);
    }

    // 2. Thử lấy từ 'sku' object nested (sku.image)
    if ((imageUrl == null || imageUrl.isEmpty) &&
        json['sku'] != null &&
        json['sku'] is Map) {
      final skuMap = json['sku'] as Map;
      if (skuMap['image'] != null && skuMap['image'].toString().isNotEmpty) {
        imageUrl = cleanUrl(skuMap['image']);
      }
      // Nếu sku có product nested
      if ((imageUrl == null || imageUrl.isEmpty) &&
          skuMap['product'] != null &&
          skuMap['product'] is Map) {
        final skuProduct = skuMap['product'] as Map;
        imageUrl = extractFirstImage(skuProduct['images']);
        imageUrl ??= extractFirstImage(skuProduct['image']);
        // Thử lấy từ productTranslations bên trong sku.product
        if ((imageUrl == null || imageUrl.isEmpty) &&
            skuProduct['productTranslations'] != null &&
            skuProduct['productTranslations'] is List &&
            (skuProduct['productTranslations'] as List).isNotEmpty) {
          for (final trans in (skuProduct['productTranslations'] as List)) {
            if (trans is Map && trans['image'] != null && trans['image'].toString().isNotEmpty) {
              imageUrl = cleanUrl(trans['image']);
              break;
            }
          }
        }
      }
    }

    // 3. Thử lấy từ 'productSku' object nested
    if ((imageUrl == null || imageUrl.isEmpty) &&
        json['productSku'] != null &&
        json['productSku'] is Map) {
      final productSkuMap = json['productSku'] as Map;
      if (productSkuMap['image'] != null && productSkuMap['image'].toString().isNotEmpty) {
        imageUrl = cleanUrl(productSkuMap['image']);
      }
      if ((imageUrl == null || imageUrl.isEmpty) &&
          productSkuMap['product'] != null &&
          productSkuMap['product'] is Map) {
        final pMap = productSkuMap['product'] as Map;
        imageUrl = extractFirstImage(pMap['images']);
        imageUrl ??= extractFirstImage(pMap['image']);
      }
    }

    // 4. Thử lấy từ 'product' object nested
    if ((imageUrl == null || imageUrl.isEmpty) &&
        json['product'] != null &&
        json['product'] is Map) {
      final productMap = json['product'] as Map;
      imageUrl = extractFirstImage(productMap['images']);
      imageUrl ??= extractFirstImage(productMap['image']);
      // Thử productTranslations bên trong product
      if ((imageUrl == null || imageUrl.isEmpty) &&
          productMap['productTranslations'] != null &&
          productMap['productTranslations'] is List &&
          (productMap['productTranslations'] as List).isNotEmpty) {
        for (final trans in (productMap['productTranslations'] as List)) {
          if (trans is Map && trans['image'] != null && trans['image'].toString().isNotEmpty) {
            imageUrl = cleanUrl(trans['image']);
            break;
          }
        }
      }
    }

    // 5. Thử lấy từ 'productTranslations' trực tiếp trên order item
    if ((imageUrl == null || imageUrl.isEmpty) &&
        json['productTranslations'] != null &&
        json['productTranslations'] is List &&
        (json['productTranslations'] as List).isNotEmpty) {
      for (final trans in (json['productTranslations'] as List)) {
        if (trans is Map && trans['image'] != null && trans['image'].toString().isNotEmpty) {
          imageUrl = cleanUrl(trans['image']);
          break;
        }
      }
    }

    // 6. Thử lấy từ 'productImages' trực tiếp trên order item
    if ((imageUrl == null || imageUrl.isEmpty) && json['productImages'] != null) {
      imageUrl = extractFirstImage(json['productImages']);
    }

    // Fix URL nếu là path tương đối
    if (imageUrl != null && imageUrl.isNotEmpty) {
      imageUrl = fixUrl(imageUrl);
    }

    print('🔍 [OrderItem] Final imageUrl: $imageUrl');

    return OrderItemModel(
      id: (json['id'] as num).toInt(),
      skuId: (json['skuId'] as num).toInt(),
      productId: (json['productId'] as num?)?.toInt(),
      productName: json['productName'] as String?,
      skuValue: json['skuValue'] as String?,
      image: (imageUrl != null && imageUrl.isNotEmpty) ? imageUrl : null,
      price: priceVal,
      quantity: (json['quantity'] as num).toInt(),
      isReviewed: json['isReviewed'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'skuId': skuId,
    'productId': productId,
    'productName': productName,
    'skuValue': skuValue,
    'image': image,
    'price': price,
    'quantity': quantity,
    'isReviewed': isReviewed,
  };
}
