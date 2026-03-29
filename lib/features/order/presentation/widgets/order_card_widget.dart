import 'package:app_fe_ecomerce/core/styles/app_colors.dart';
import 'package:app_fe_ecomerce/core/styles/app_text_styles.dart';
import 'package:app_fe_ecomerce/features/order/domain/entities/order_entity.dart';
import 'package:app_fe_ecomerce/features/order/presentation/pages/order_detail_page.dart';
import 'package:app_fe_ecomerce/features/payment/presentation/pages/payment_qr_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class OrderCardWidget extends StatelessWidget {
  final OrderEntity order;

  const OrderCardWidget({super.key, required this.order});

  // Helper hàm convert status sang Text/Color
  Widget _buildStatusBadge(String? status) {
    Color bgColor;
    Color textColor;
    String text;

    switch (status) {
      case 'UNPAID':
        bgColor = Colors.orange.shade50;
        textColor = Colors.orange.shade700;
        text = 'Chờ thanh toán';
        break;
      case 'READY_TO_SHIP':
        bgColor = Colors.blue.shade50;
        textColor = Colors.blue.shade700;
        text = 'Chờ lấy hàng';
        break;
      case 'SHIPPED':
        bgColor = Colors.blue.shade50;
        textColor = Colors.blue.shade700;
        text = 'Đang giao hàng';
        break;
      case 'COMPLETED':
        bgColor = Colors.green.shade50;
        textColor = Colors.green.shade700;
        text = 'Đã giao';
        break;
      case 'CANCELLED':
        bgColor = Colors.red.shade50;
        textColor = Colors.red.shade700;
        text = 'Đã hủy';
        break;
      case 'TO_RETURN':
        bgColor = Colors.purple.shade50;
        textColor = Colors.purple.shade700;
        text = 'Trả hàng';
        break;
      default:
        bgColor = Colors.grey.shade100;
        textColor = Colors.grey.shade700;
        text = status ?? 'Không rõ';
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(4.r),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: textColor,
          fontSize: 12.sp,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final firstItem = (order.items != null && order.items!.isNotEmpty)
        ? order.items!.first
        : null;
    final int itemLength = order.items?.length ?? 0;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OrderDetailPage(orderId: order.id),
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          children: [
            // Header: Shop Name & Status
            Padding(
              padding: EdgeInsets.all(12.w),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.storefront, size: 20.sp, color: Colors.grey),
                      SizedBox(width: 8.w),
                      Text(
                        'Shop ID ${order.shopId}',
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  _buildStatusBadge(order.status),
                ],
              ),
            ),
            const Divider(height: 1),

            // Item Preview
            if (firstItem != null)
              Padding(
                padding: EdgeInsets.all(12.w),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Ảnh sản phẩm
                    Container(
                      width: 60.w,
                      height: 60.w,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(4.r),
                        image: DecorationImage(
                          image: NetworkImage(
                            firstItem.image ?? 'https://via.placeholder.com/60',
                          ),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    // Tên và phân loại
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            firstItem.productName ?? 'Sản phẩm',
                            style: AppTextStyles.bodyMedium.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 4.h),
                          if (firstItem.skuValue != null)
                            Text(
                              'Phân loại: ${firstItem.skuValue}',
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: Colors.grey,
                                fontSize: 12.sp,
                              ),
                            ),
                          SizedBox(height: 4.h),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${firstItem.price} đ',
                                style: AppTextStyles.bodyMedium,
                              ),
                              Text(
                                'x${firstItem.quantity}',
                                style: AppTextStyles.bodyMedium,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

            // Footer: Total
            const Divider(height: 1),
            Padding(
              padding: EdgeInsets.all(12.w),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '$itemLength sản phẩm',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: Colors.grey,
                    ),
                  ),
                  Row(
                    children: [
                      Text('Thành tiền: ', style: AppTextStyles.bodyMedium),
                      Text(
                        '${order.totalAmount ?? 0} đ',
                        style: AppTextStyles.bodyLarge.copyWith(
                          color: AppColors.error,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // Action Buttons
            if (order.status == 'UNPAID' || order.status == 'READY_TO_SHIP' || order.status == 'SHIPPED' || order.status == 'COMPLETED') ...[
              const Divider(height: 1),
              Padding(
                padding: EdgeInsets.all(12.w),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (order.status == 'UNPAID') ...[
                      OutlinedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => OrderDetailPage(orderId: order.id),
                            ),
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.error,
                          side: const BorderSide(color: AppColors.error),
                          minimumSize: Size(80.w, 36.h),
                          padding: EdgeInsets.symmetric(horizontal: 16.w),
                        ),
                        child: const Text('Hủy đơn'),
                      ),
                      if (DateTime.now().difference(order.createdAt ?? DateTime.now()).inHours < 24) ...[
                        SizedBox(width: 8.w),
                        ElevatedButton(
                          onPressed: () {
                            if (order.paymentId == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Đơn hàng thiếu Payment ID từ máy chủ!')),
                              );
                              return;
                            }
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PaymentQRPage(
                                  paymentId: order.paymentId!,
                                  totalAmount: order.totalAmount?.toDouble() ?? 0.0,
                                ),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryBlue,
                            minimumSize: Size(100.w, 36.h),
                            padding: EdgeInsets.symmetric(horizontal: 16.w),
                          ),
                          child: const Text('Thanh toán', style: TextStyle(color: Colors.white)),
                        ),
                      ],
                    ],
                    if (order.status == 'SHIPPED')
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => OrderDetailPage(orderId: order.id),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryBlue,
                          minimumSize: Size(100.w, 36.h),
                          padding: EdgeInsets.symmetric(horizontal: 16.w),
                        ),
                        child: const Text('Đã nhận được hàng', style: TextStyle(color: Colors.white)),
                      ),
                    // Nút đánh giá cho đơn đã giao thành công
                    if (order.status == 'COMPLETED')
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => OrderDetailPage(orderId: order.id),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.amber.shade600,
                          minimumSize: Size(100.w, 36.h),
                          padding: EdgeInsets.symmetric(horizontal: 16.w),
                        ),
                        icon: const Icon(Icons.star_border, color: Colors.white, size: 16),
                        label: const Text('Đánh giá', style: TextStyle(color: Colors.white)),
                      ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
