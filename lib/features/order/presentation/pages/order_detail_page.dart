import 'package:app_fe_ecomerce/core/styles/app_colors.dart';
import 'package:app_fe_ecomerce/core/styles/app_text_styles.dart';
import 'package:app_fe_ecomerce/features/order/domain/entities/order_entity.dart';
import 'package:app_fe_ecomerce/features/order/presentation/bloc/order/order_bloc.dart';
import 'package:app_fe_ecomerce/features/product/domain/entities/product.dart';
import 'package:app_fe_ecomerce/features/review/presentation/bloc/create_review/create_review_bloc.dart';
import 'package:app_fe_ecomerce/features/review/presentation/widgets/create_review_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:app_fe_ecomerce/core/common/widgets/app_network_image.dart';
import 'package:app_fe_ecomerce/features/product/presentation/pages/product_detail_page.dart';
import 'package:app_fe_ecomerce/features/payment/presentation/pages/payment_qr_page.dart';

class OrderDetailPage extends StatefulWidget {
  final int orderId;

  const OrderDetailPage({super.key, required this.orderId});

  @override
  State<OrderDetailPage> createState() => _OrderDetailPageState();
}

class _OrderDetailPageState extends State<OrderDetailPage> {
  // Track reviewed items locally (by orderItemId)
  final Set<int> _reviewedItemIds = {};

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          GetIt.I<OrderBloc>()
            ..add(OrderDetailRequested(orderId: widget.orderId)),
      child: Scaffold(
        backgroundColor: AppColors.inputBackground,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text('Chi tiết đơn hàng', style: AppTextStyles.h3),
          centerTitle: true,
        ),
        body: BlocConsumer<OrderBloc, OrderState>(
          listener: (context, state) {
            if (state is OrderCancelled || state is OrderStatusUpdated) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    state is OrderCancelled
                        ? 'Hủy đơn hàng thành công'
                        : 'Đã cập nhật trạng thái',
                  ),
                  backgroundColor: AppColors.success,
                ),
              );
              context.read<OrderBloc>().add(
                OrderDetailRequested(orderId: widget.orderId),
              );
            } else if (state is OrderFailure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: AppColors.error,
                ),
              );
            }
          },
          builder: (context, state) {
            if (state is OrderLoading) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.primaryBlue),
              );
            }

            if (state is OrderDetailLoaded) {
              final order = state.order;
              return SingleChildScrollView(
                padding: EdgeInsets.only(bottom: 24.h),
                child: Column(
                  children: [
                    _buildOrderHeader(order),
                    _buildDeliveryInfo(order),
                    _buildOrderItems(order),
                    _buildOrderSummary(order),

                    if (order.status == 'UNPAID')
                      _buildUnpaidActions(context, order),

                    // Nút xác nhận đã nhận hàng
                    if (order.status == 'SHIPPED')
                      _buildReceivedButton(context, order),

                    // Section đánh giá sau khi đơn hoàn thành
                    if (order.status == 'COMPLETED')
                      _buildReviewSection(context, order),
                  ],
                ),
              );
            }

            return const Center(child: Text('Lỗi tải đơn hàng.'));
          },
        ),
      ),
    );
  }

  Widget _buildOrderHeader(OrderEntity order) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.all(16.w),
      margin: EdgeInsets.only(bottom: 8.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Mã đơn hàng: ${order.id}',
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                _getFriendlyStatus(order.status),
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.primaryBlue,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Text(
            'Ngày đặt: ${order.createdAt != null ? DateFormat('dd/MM/yyyy HH:mm').format(order.createdAt!) : 'N/A'}',
            style: AppTextStyles.bodyMedium.copyWith(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildDeliveryInfo(OrderEntity order) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.all(16.w),
      margin: EdgeInsets.only(bottom: 8.h),
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.location_on,
                size: 20.sp,
                color: AppColors.primaryBlue,
              ),
              SizedBox(width: 8.w),
              Text(
                'Địa chỉ nhận hàng',
                style: AppTextStyles.bodyLarge.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Text(
            '${order.receiverName ?? 'Khách hàng'}  |  ${order.receiverPhone ?? 'Chưa cập nhật'}',
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            order.receiverAddress ?? 'Chưa có địa chỉ',
            style: AppTextStyles.bodyMedium.copyWith(color: Colors.grey[700]),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderItems(OrderEntity order) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.all(16.w),
      margin: EdgeInsets.only(bottom: 8.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.storefront, size: 20.sp, color: AppColors.primaryBlue),
              SizedBox(width: 8.w),
              Text(
                'Sản phẩm (${order.items?.length ?? 0})',
                style: AppTextStyles.bodyLarge.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: order.items?.length ?? 0,
            separatorBuilder: (context, index) => const Divider(),
            itemBuilder: (context, index) {
              final item = order.items![index];
              return GestureDetector(
                onTap: () {
                  if (item.productId == null) return;
                  // Tạo Product minimal — ProductDetailPage tự fetch chi tiết đầy đủ
                  final minimalProduct = Product(
                    id: item.productId!,
                    name: item.productName ?? 'Sản phẩm',
                    basePrice: item.price.toDouble(),
                    images: item.image != null ? [item.image!] : [],
                    brandId: 0,
                  );
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          ProductDetailPage(product: minimalProduct),
                    ),
                  );
                },
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4.r),
                      child: AppNetworkImage(
                        imageUrl: item.image ?? '',
                        width: 60.w,
                        height: 60.w,
                        fit: BoxFit.cover,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  item.productName ?? 'Sản phẩm',
                                  style: AppTextStyles.bodyMedium,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Icon(
                                Icons.chevron_right,
                                size: 16.sp,
                                color: Colors.grey,
                              ),
                            ],
                          ),
                          if (item.skuValue != null) ...[
                            SizedBox(height: 4.h),
                            Text(
                              'Phân loại: ${item.skuValue}',
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: Colors.grey,
                                fontSize: 12.sp,
                              ),
                            ),
                          ],
                          SizedBox(height: 8.h),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${item.price} đ',
                                style: AppTextStyles.bodyMedium,
                              ),
                              Text(
                                'x${item.quantity}',
                                style: AppTextStyles.bodyMedium,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildOrderSummary(OrderEntity order) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.all(16.w),
      margin: EdgeInsets.only(bottom: 8.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.payment, size: 20.sp, color: AppColors.primaryBlue),
              SizedBox(width: 8.w),
              Text(
                'Thông tin thanh toán',
                style: AppTextStyles.bodyLarge.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Phương thức', style: AppTextStyles.bodyMedium),
              Text(
                order.paymentMethod == 'SEPAY'
                    ? 'Chuyển khoản (SePay)'
                    : (order.paymentMethod ?? 'Thanh toán tiền mặt / COD'),
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Tạm tính', style: AppTextStyles.bodyMedium),
              Text(
                '${order.totalAmount ?? 0} đ',
                style: AppTextStyles.bodyMedium,
              ),
            ],
          ),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Tổng thanh toán',
                style: AppTextStyles.bodyLarge.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${order.totalAmount ?? 0} đ',
                style: AppTextStyles.h3.copyWith(color: AppColors.error),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUnpaidActions(BuildContext context, OrderEntity order) {
    final bool isSepay = order.paymentMethod?.contains('SEPAY') == true;
    final bool hasPaymentId = order.paymentId != null;
    
    // Check if within 24 hours
    final now = DateTime.now();
    final createdAt = order.createdAt ?? now;
    final bool isExpired = now.difference(createdAt).inHours >= 24;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 24.h),
      child: Column(
        children: [
          // DEBUG INFO TRÊN UI ĐỂ TÌM NGUYÊN NHÂN:
          if (!isSepay || !hasPaymentId)
            Text(
              'Debug: isSepay=$isSepay (method=${order.paymentMethod}), hasPaymentId=$hasPaymentId (id=${order.paymentId}), isExpired=$isExpired (createdAt=${order.createdAt})',
              style: TextStyle(color: Colors.red, fontSize: 10.sp),
            ),
          
          // Nút Thanh toán lại
          if ((isSepay || order.paymentMethod == null) && (!isExpired)) ...[
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (order.paymentId == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Không tìm thấy paymentId, API Backend đang thiếu!')),
                    );
                    return;
                  }
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PaymentQRPage(
                        paymentId: order.paymentId!,
                        totalAmount: order.totalAmount?.toDouble() ?? 0.0,
                        orderId: order.id,
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                ),
                child: Text(
                  'Thanh toán ngay',
                  style: AppTextStyles.buttonText.copyWith(color: Colors.white),
                ),
              ),
            ),
            SizedBox(height: 12.h),
          ],
          // Nút Hủy đơn
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {
                _showCancelConfirmDialog(context, order.id);
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.error,
                side: const BorderSide(color: AppColors.error),
                padding: EdgeInsets.symmetric(vertical: 12.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
              ),
              child: Text(
                'Hủy đơn hàng',
                style: AppTextStyles.buttonText.copyWith(color: AppColors.error),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showCancelConfirmDialog(BuildContext context, int orderId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hủy đơn hàng'),
        content: const Text('Bạn có chắc chắn muốn hủy đơn hàng này không?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Không'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<OrderBloc>().add(
                OrderCancelRequested(orderId: orderId),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Có, hủy', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  String _getFriendlyStatus(String? status) {
    switch (status) {
      case 'UNPAID':
        return 'Chờ thanh toán';
      case 'READY_TO_SHIP':
        return 'Chờ lấy hàng';
      case 'SHIPPED':
        return 'Đang giao hàng';
      case 'COMPLETED':
        return 'Đã giao thành công';
      case 'TO_RETURN':
        return 'Trả hàng';
      case 'CANCELLED':
        return 'Đã hủy';
      default:
        return status ?? 'N/A';
    }
  }

  Widget _buildReceivedButton(BuildContext context, OrderEntity order) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: ElevatedButton(
        onPressed: () {
          context.read<OrderBloc>().add(
            OrderUpdateStatusRequested(orderId: order.id, status: 'COMPLETED'),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryBlue,
          padding: EdgeInsets.symmetric(vertical: 12.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.r),
          ),
        ),
        child: Text(
          'Đã nhận được hàng',
          style: AppTextStyles.buttonText.copyWith(color: Colors.white),
        ),
      ),
    );
  }

  // Section đánh giá cho đơn hàng đã hoàn thành
  Widget _buildReviewSection(BuildContext context, OrderEntity order) {
    final items = order.items ?? [];
    if (items.isEmpty) return const SizedBox.shrink();

    return Container(
      color: Colors.white,
      margin: EdgeInsets.only(top: 8.h),
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.star_rate_rounded, size: 20.sp, color: Colors.amber),
              SizedBox(width: 8.w),
              Text(
                'Đánh giá sản phẩm',
                style: AppTextStyles.bodyLarge.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 4.h),
          Text(
            'Hãy chia sẻ cảm nhận của bạn về sản phẩm đã mua',
            style: AppTextStyles.bodyMedium.copyWith(color: Colors.grey[600]),
          ),
          SizedBox(height: 12.h),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: items.length,
            separatorBuilder: (context, index) => SizedBox(height: 8.h),
            itemBuilder: (context, index) {
              final item = items[index];
              // Kiểm tra đã đánh giá chưa: từ backend (isReviewed) hoặc vừa đánh giá trong session này
              final alreadyReviewed =
                  item.isReviewed || _reviewedItemIds.contains(item.id);

              return Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[200]!),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Row(
                  children: [
                    // Ảnh sản phẩm
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4.r),
                      child: AppNetworkImage(
                        imageUrl:
                            item.image ?? 'https://via.placeholder.com/48',
                        width: 48.w,
                        height: 48.w,
                        fit: BoxFit.cover,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    // Tên sản phẩm
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.productName ?? 'Sản phẩm',
                            style: AppTextStyles.bodyMedium.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (item.skuValue != null)
                            Text(
                              'Phân loại: ${item.skuValue}',
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: Colors.grey[600],
                              ),
                            ),
                        ],
                      ),
                    ),
                    SizedBox(width: 8.w),
                    // Nút đánh giá hoặc badge đã đánh giá
                    if (alreadyReviewed)
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 10.w,
                          vertical: 6.h,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          borderRadius: BorderRadius.circular(20.r),
                          border: Border.all(color: Colors.green.shade200),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.check_circle_outline,
                              size: 14.sp,
                              color: Colors.green.shade700,
                            ),
                            SizedBox(width: 4.w),
                            Text(
                              'Đã đánh giá',
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: Colors.green.shade700,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      OutlinedButton(
                        onPressed: () => _openReviewSheet(context, order, item),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primaryBlue,
                          side: const BorderSide(color: AppColors.primaryBlue),
                          padding: EdgeInsets.symmetric(
                            horizontal: 12.w,
                            vertical: 6.h,
                          ),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.r),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.star_border, size: 14.sp),
                            SizedBox(width: 4.w),
                            Text('Đánh giá', style: TextStyle(fontSize: 12.sp)),
                          ],
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  void _openReviewSheet(
    BuildContext context,
    OrderEntity order,
    OrderItemEntity item,
  ) {
    // ProductId cần thiết để gửi review
    final productId = item.productId;
    if (productId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Không thể xác định sản phẩm để đánh giá'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => BlocProvider(
        create: (_) => GetIt.I<CreateReviewBloc>(),
        child: CreateReviewBottomSheet(
          productId: productId,
          orderId: order.id,
          productName: item.productName,
          productImage: item.image,
          onReviewCreated: () {
            // Đánh dấu item này đã được review trong session hiện tại
            setState(() {
              _reviewedItemIds.add(item.id);
            });
          },
        ),
      ),
    );
  }
}
