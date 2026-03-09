import 'package:app_fe_ecomerce/core/styles/app_colors.dart';
import 'package:app_fe_ecomerce/core/styles/app_text_styles.dart';
import 'package:app_fe_ecomerce/features/cart/domain/entities/cart_entity.dart';
import 'package:app_fe_ecomerce/features/order/domain/usecases/create_order_usecase.dart';
import 'package:app_fe_ecomerce/features/order/presentation/bloc/order/order_bloc.dart';
import 'package:app_fe_ecomerce/features/order/presentation/widgets/checkout_item_widget.dart';
import 'package:app_fe_ecomerce/features/payment/presentation/pages/payment_qr_page.dart';
import 'package:app_fe_ecomerce/features/address/domain/entities/address_entity.dart';
import 'package:app_fe_ecomerce/features/address/presentation/pages/address_list_page.dart';
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

  AddressEntity? _selectedAddress;
  final _noteController = TextEditingController();
  String _paymentMethod = 'COD';

  @override
  void initState() {
    super.initState();
    // TODO: Ideally context.read<AddressBloc>().add(GetAddressesEvent()) and listen to State to set default address.
    // For now we assume user will pick or we load default if possible.
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  void _submitOrder() {
    if (_selectedAddress == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng chọn địa chỉ giao hàng'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (_formKey.currentState!.validate()) {
      // Logic gom nhóm sản phẩm theo shopId
      final Map<int, List<int>> shopItems = {};

      for (var item in widget.selectedItems) {
        // Use the actual shopId from cart item
        int? shopId = item.shopId;

        // Fallback to shopId = 1 if not available (shouldn't happen with updated cart API)
        if (shopId == null) {
          print('WARNING: Cart item ${item.id} has no shopId, defaulting to 1');
          shopId = 1;
        }

        if (shopItems.containsKey(shopId)) {
          shopItems[shopId]!.add(item.id);
        } else {
          shopItems[shopId] = [item.id];
        }
      }

      final List<ShopOrderParams> orders = shopItems.entries.map((e) {
        return ShopOrderParams(
          shopId: e.key,
          userAddressId: _selectedAddress!.id,
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
                    _buildDeliverySection(),
                    _buildProductsSection(),
                    _buildPaymentMethodSection(),
                    _buildOrderSummarySection(),
                  ],
                ),
              ),
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                      'Địa chỉ nhận hàng',
                      style: AppTextStyles.bodyLarge.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                TextButton(
                  onPressed: () async {
                    // Navigate to Address list to pick
                    final selected = await Navigator.push<AddressEntity>(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            const AddressListPage(isSelecting: true),
                      ),
                    );
                    if (selected != null) {
                      setState(() {
                        _selectedAddress = selected;
                      });
                    }
                  },
                  child: Text(
                    _selectedAddress == null ? 'Chọn' : 'Thay đổi',
                    style: TextStyle(
                      color: AppColors.primaryBlue,
                      fontSize: 14.sp,
                    ),
                  ),
                ),
              ],
            ),
            if (_selectedAddress != null) ...[
              SizedBox(height: 8.h),
              Text(
                '${_selectedAddress!.name} | ${_selectedAddress!.phone}',
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                _selectedAddress!.address,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ] else ...[
              SizedBox(height: 16.h),
              Center(
                child: Text(
                  'Vui lòng chọn địa chỉ giao hàng',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.error,
                  ),
                ),
              ),
            ],
            SizedBox(height: 16.h),
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
