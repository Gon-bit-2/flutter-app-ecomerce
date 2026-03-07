import 'package:app_fe_ecomerce/core/styles/app_colors.dart';
import 'package:app_fe_ecomerce/core/styles/app_text_styles.dart';
import 'package:app_fe_ecomerce/features/cart/domain/entities/cart_entity.dart';
import 'package:app_fe_ecomerce/features/order/domain/usecases/create_order_usecase.dart';
import 'package:app_fe_ecomerce/features/order/presentation/bloc/order/order_bloc.dart';
import 'package:app_fe_ecomerce/features/order/presentation/widgets/checkout_item_widget.dart';
import 'package:app_fe_ecomerce/features/payment/presentation/pages/payment_qr_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CheckoutPage extends StatefulWidget {
  // Lấy các sản phẩm đã chọn từ giỏ hàng sang
  final List<CartEntity> selectedItems;
  final num totalPrice;

  const CheckoutPage({
    super.key,
    required this.selectedItems,
    required this.totalPrice,
  });

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final _formKey = GlobalKey<FormState>();

  // Controllers cho thông tin giao hàng
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _noteController = TextEditingController();

  // Phương thức thanh toán (mặc định COD)
  String _paymentMethod = 'COD';

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _submitOrder() {
    if (_formKey.currentState!.validate()) {
      // Logic gom nhóm sản phẩm theo shopId
      // Ở đây giả định model Product/CartEntity gửi về có chứa shopId
      // Tạm thời nếu api chưa cung cấp shopId cho CartEntity, ta mock một shopId = 1 cho demo
      // Trong thực tế CartEntity cần có trường shopId để group:

      final Map<int, List<int>> shopItems = {};

      for (var item in widget.selectedItems) {
        // FIXME: Ở bước entity entity.dart chưa có trường shopId, nên tạm hardcode shopId = 1
        // Hãy thêm trường shopId vào CartEntity nếu backend có trả về
        int shopId = 1;

        if (shopItems.containsKey(shopId)) {
          shopItems[shopId]!.add(item.id);
        } else {
          shopItems[shopId] = [item.id];
        }
      }

      final receiver = ReceiverInfoParams(
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        address: _addressController.text.trim(),
      );

      final List<ShopOrderParams> orders = shopItems.entries.map((e) {
        return ShopOrderParams(
          shopId: e.key,
          receiver: receiver,
          cartItemIds: e.value,
        );
      }).toList();

      context.read<OrderBloc>().add(OrderCreateRequested(orders: orders));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.inputBackground,
      appBar: AppBar(
        backgroundColor: AppColors.primaryBlue,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Thanh toán',
          style: AppTextStyles.h3.copyWith(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: BlocConsumer<OrderBloc, OrderState>(
        listener: (context, state) {
          if (state is OrderFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
              ),
            );
          } else if (state is OrderCreated) {
            if (_paymentMethod == 'SEPAY') {
              // Bỏ qua tất cả màn hình trên stack và đến trang QR
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => PaymentQRPage(
                    paymentId: state.result.paymentId ?? 0,
                    totalAmount: widget.totalPrice + 30000,
                  ),
                ),
              );
            } else {
              _showSuccessDialog();
            }
          }
        },
        builder: (context, state) {
          return Stack(
            children: [
              SingleChildScrollView(
                padding: EdgeInsets.only(bottom: 100.h),
                child: Column(
                  children: [
                    // Phần thông tin giao hàng
                    _buildDeliverySection(),

                    // Phần danh sách sản phẩm
                    _buildProductsSection(),

                    // Phương thức thanh toán
                    _buildPaymentMethodSection(),

                    // Tổng quan đơn hàng
                    _buildOrderSummarySection(),
                  ],
                ),
              ),

              // Nút đặt hàng ở dưới cùng
              _buildBottomBar(state is OrderLoading),
            ],
          );
        },
      ),
    );
  }

  Widget _buildDeliverySection() {
    return Container(
      margin: EdgeInsets.only(top: 8.h),
      padding: EdgeInsets.all(16.w),
      color: Colors.white,
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.location_on,
                  color: AppColors.primaryBlue,
                  size: 20.sp,
                ),
                SizedBox(width: 8.w),
                Text(
                  'Thông tin nhận hàng',
                  style: AppTextStyles.bodyLarge.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Họ tên người nhận',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16.w,
                  vertical: 12.h,
                ),
              ),
              validator: (value) =>
                  value!.isEmpty ? 'Vui lòng nhập họ tên' : null,
            ),
            SizedBox(height: 12.h),
            TextFormField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: 'Số điện thoại',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16.w,
                  vertical: 12.h,
                ),
              ),
              validator: (value) => value!.isEmpty ? 'Vui lòng nhập SDT' : null,
            ),
            SizedBox(height: 12.h),
            TextFormField(
              controller: _addressController,
              maxLines: 2,
              decoration: InputDecoration(
                labelText: 'Địa chỉ giao hàng chi tiết',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16.w,
                  vertical: 12.h,
                ),
              ),
              validator: (value) =>
                  value!.isEmpty ? 'Vui lòng nhập địa chỉ' : null,
            ),
            SizedBox(height: 12.h),
            TextFormField(
              controller: _noteController,
              decoration: InputDecoration(
                labelText: 'Ghi chú cho người giao hàng (Tùy chọn)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16.w,
                  vertical: 12.h,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductsSection() {
    return Container(
      margin: EdgeInsets.only(top: 8.h),
      padding: EdgeInsets.all(16.w),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.shopping_bag_outlined,
                color: AppColors.primaryBlue,
                size: 20.sp,
              ),
              SizedBox(width: 8.w),
              Text(
                'Sản phẩm (${widget.selectedItems.length})',
                style: AppTextStyles.bodyLarge.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: widget.selectedItems.length,
            itemBuilder: (context, index) {
              return CheckoutItemWidget(item: widget.selectedItems[index]);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodSection() {
    return Container(
      margin: EdgeInsets.only(top: 8.h),
      padding: EdgeInsets.all(16.w),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.payment, color: AppColors.primaryBlue, size: 20.sp),
              SizedBox(width: 8.w),
              Text(
                'Phương thức thanh toán',
                style: AppTextStyles.bodyLarge.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.primaryBlue),
              borderRadius: BorderRadius.circular(8.r),
              color: AppColors.primaryBlue.withOpacity(0.05),
            ),
            child: Column(
              children: [
                RadioListTile(
                  title: Text(
                    'Thanh toán chuyển khoản (SePay)',
                    style: AppTextStyles.bodyMedium,
                  ),
                  value: 'SEPAY',
                  groupValue: _paymentMethod,
                  onChanged: (value) {
                    setState(() => _paymentMethod = value.toString());
                  },
                  activeColor: AppColors.primaryBlue,
                ),
                const Divider(),
                RadioListTile(
                  title: Text(
                    'Thanh toán khi nhận hàng (COD)',
                    style: AppTextStyles.bodyMedium,
                  ),
                  value: 'COD',
                  groupValue: _paymentMethod,
                  onChanged: (value) {
                    setState(() => _paymentMethod = value.toString());
                  },
                  activeColor: AppColors.primaryBlue,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderSummarySection() {
    // Phí ship mock
    num shippingFee = 30000;
    num total = widget.totalPrice + shippingFee;

    return Container(
      margin: EdgeInsets.only(top: 8.h, bottom: 20.h),
      padding: EdgeInsets.all(16.w),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.receipt_long,
                color: AppColors.primaryBlue,
                size: 20.sp,
              ),
              SizedBox(width: 8.w),
              Text(
                'Chi tiết thanh toán',
                style: AppTextStyles.bodyLarge.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Tổng tiền hàng', style: AppTextStyles.bodyMedium),
              Text('${widget.totalPrice} đ', style: AppTextStyles.bodyMedium),
            ],
          ),
          SizedBox(height: 8.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Phí vận chuyển', style: AppTextStyles.bodyMedium),
              Text('$shippingFee đ', style: AppTextStyles.bodyMedium),
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
                '$total đ',
                style: AppTextStyles.h3.copyWith(color: AppColors.error),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(bool isLoading) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              offset: const Offset(0, -4),
              blurRadius: 10,
            ),
          ],
        ),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        child: SafeArea(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Tổng cộng', style: AppTextStyles.bodyMedium),
                  Text(
                    '${widget.totalPrice + 30000} đ',
                    style: AppTextStyles.h3.copyWith(color: AppColors.error),
                  ),
                ],
              ),
              ElevatedButton(
                onPressed: isLoading ? null : _submitOrder,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  padding: EdgeInsets.symmetric(
                    horizontal: 32.w,
                    vertical: 12.h,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                ),
                child: isLoading
                    ? SizedBox(
                        width: 20.w,
                        height: 20.w,
                        child: const CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text('Đặt hàng', style: AppTextStyles.buttonText),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle, color: AppColors.success, size: 60.sp),
            SizedBox(height: 16.h),
            Text(
              'Đặt hàng thành công!',
              style: AppTextStyles.h3,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8.h),
            Text(
              'Đơn hàng của bạn đang được xử lý.',
              style: AppTextStyles.bodyMedium,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24.h),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // Đóng dialog
                  Navigator.pop(context);
                  // Trở về trang chủ
                  Navigator.of(context).popUntil((route) => route.isFirst);
                  // TODO: Bật sang tab lịch sử đơn hàng nếu đã có Bottom Navigation (Tùy chọn)
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                ),
                child: Text(
                  'Tiếp tục mua sắm',
                  style: AppTextStyles.buttonText,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
