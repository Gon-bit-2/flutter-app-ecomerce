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

      // Xử lý đường dẫn tuyệt đối từ Backend (Ví dụ: D:/Works/app-ecomerce/app_fe_ecomerce/images/image.png)
      // Chúng ta sẽ lấy phần từ /images/, /uploads/, hoặc /public/ trở đi

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

    // Backend trả về skuPrice thay vì price
    num priceVal = 0;
    if (json['price'] != null) {
      priceVal = json['price'] as num;
    } else if (json['skuPrice'] != null) {
      priceVal = json['skuPrice'] as num;
    }

    // Thử lấy ảnh từ nhiều nguồn khác nhau
    String? imageUrl;

    // 1. Lấy từ field 'image' trực tiếp (Ưu tiên ảnh từ Cloudinary)
    if (json['image'] != null && json['image'].toString().isNotEmpty) {
      imageUrl = cleanUrl(json['image']);
    }

    // 2. Nếu vẫn trống, thử lấy từ 'product' object nested (Thường Backend sẽ join thêm thông tin này)
    if ((imageUrl == null || imageUrl.isEmpty) &&
        json['product'] != null &&
        json['product'] is Map) {
      final productMap = json['product'] as Map;
      if (productMap['images'] != null) {
        imageUrl = cleanUrl(productMap['images']);
      } else if (productMap['image'] != null) {
        imageUrl = cleanUrl(productMap['image']);
      }
    }

    // 3. Nếu vẫn trống, thử lấy từ 'productTranslations' (Nếu Backend trả về thông tin dịch)
    if ((imageUrl == null || imageUrl.isEmpty) &&
        json['productTranslations'] != null &&
        json['productTranslations'] is List &&
        (json['productTranslations'] as List).isNotEmpty) {
      final trans = (json['productTranslations'] as List).first;
      if (trans is Map && trans['image'] != null) {
        imageUrl = cleanUrl(trans['image']);
      }
    }

    // 4. Fallback cuối cùng: Nếu hoàn toàn không có ảnh, và dự án dùng Cloudinary,
    // Backend đáng lẽ phải trả về Public ID.
    // Nếu imageUrl vẫn trống ở đây, UI sẽ hiển thị Placeholder Icon chuyên nghiệp.

    // Fix URL nếu là path tương đối
    if (imageUrl != null && imageUrl.isNotEmpty) {
      imageUrl = fixUrl(imageUrl);
    }

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
