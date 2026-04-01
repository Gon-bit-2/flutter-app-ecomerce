import 'dart:convert';
import 'package:json_annotation/json_annotation.dart';
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
    // Backend trả về skuPrice thay vì price
    // Cần phải parse 'price' từ 'skuPrice'
    num priceVal = 0;
    if (json['price'] != null) {
      priceVal = json['price'] as num;
    } else if (json['skuPrice'] != null) {
      priceVal = json['skuPrice'] as num;
    }

    // Backend trả hình ảnh (có thể) dưới dạng String JSON: '{"data":[{"url":"..."}]}'
    String? imageUrl;
    if (json['image'] != null) {
      final imgDynamic = json['image'];
      if (imgDynamic is String) {
        if (imgDynamic.startsWith('{')) {
          try {
            final decoded = jsonDecode(imgDynamic);
            if (decoded is Map && decoded.containsKey('data')) {
              final dataList = decoded['data'] as List;
              if (dataList.isNotEmpty && dataList.first is Map) {
                imageUrl = dataList.first['url'];
              }
            }
          } catch (e) {
            imageUrl = imgDynamic; // Nếu lỗi parse json, coi như nó là URL
          }
        } else {
          imageUrl = imgDynamic;
        }
      }
    } else if (json['product'] != null && json['product'] is Map) {
      // Fallback lấy ảnh từ object product nếu có
      final productMap = json['product'] as Map;
      if (productMap['images'] != null && productMap['images'] is List && (productMap['images'] as List).isNotEmpty) {
        final imgRaw = (productMap['images'] as List).first.toString();
        imageUrl = imgRaw.startsWith('url: ') ? imgRaw.replaceFirst('url: ', '').trim() : imgRaw;
      } else if (productMap['image'] != null) {
        imageUrl = productMap['image'] as String?;
      }
    }

    return OrderItemModel(
      id: (json['id'] as num).toInt(),
      skuId: (json['skuId'] as num).toInt(),
      productId: (json['productId'] as num?)?.toInt(),
      productName: json['productName'] as String?,
      skuValue: json['skuValue'] as String?,
      image: imageUrl,
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
