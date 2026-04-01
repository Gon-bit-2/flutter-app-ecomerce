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
import 'package:app_fe_ecomerce/features/discount/domain/entities/discount.dart';
import 'package:app_fe_ecomerce/features/discount/presentation/widgets/discount_selection_bottom_sheet.dart';
import 'package:app_fe_ecomerce/features/discount/presentation/bloc/discount/discount_bloc.dart';
import 'package:app_fe_ecomerce/features/discount/presentation/bloc/discount/discount_event.dart';
import 'package:app_fe_ecomerce/features/discount/presentation/bloc/discount/discount_state.dart';
import 'package:app_fe_ecomerce/features/auth/presentation/bloc/auth/auth_bloc.dart';
import 'package:get_it/get_it.dart';

class CheckoutPage extends StatefulWidget {
  // Lấy các sản phẩm đã chọn từ giỏ hàng sang
  final List<CartEntity> selectedItems;
  final num totalPrice;
  final num discountAmount;

  const CheckoutPage({
    super.key,
    required this.selectedItems,
    required this.totalPrice,
    this.discountAmount = 0,
  });

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final _formKey = GlobalKey<FormState>();

  AddressEntity? _selectedAddress;
  final _noteController = TextEditingController();
  String _paymentMethod = 'COD';

  // --- Discount State mới: tách Shop + Platform ---
  Discount? _shopDiscount;
  Discount? _platformDiscount;
  double _productDiscountAmount = 0.0;
  double _shippingDiscountAmount = 0.0;

  // Giá trị từ API preview — đóng đinh theo FRONTEND_GUIDE
  double? _finalPrice;
  double? _finalShippingFee;

  // Phí ship mặc định
  final double _shippingFee = 30000;

  // Bloc instance lưu trực tiếp để tránh lỗi Provider context
  late final DiscountBloc _discountBloc;

  double get _totalDiscountAmount =>
      _productDiscountAmount + _shippingDiscountAmount;

  // Tổng thanh toán: ưu tiên dùng giá trị từ API preview
  double get _grandTotal {
    if (_finalPrice != null || _finalShippingFee != null) {
      return (_finalPrice ?? widget.totalPrice.toDouble()) +
          (_finalShippingFee ?? _shippingFee);
    }
    return widget.totalPrice.toDouble() + _shippingFee;
  }

  @override
  void initState() {
    super.initState();
    _discountBloc = GetIt.I<DiscountBloc>();
  }

  @override
  void dispose() {
    _noteController.dispose();
    _discountBloc.close();
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
      // Show confirm dialog before submitting order
      _showConfirmOrderDialog();
    }
  }

  void _showConfirmOrderDialog() {
    num totalAmount = _grandTotal;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        title: Text('Xác nhận đặt hàng', style: AppTextStyles.h3),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Items count
              Text(
                'Số lượng sản phẩm: ${widget.selectedItems.length}',
                style: AppTextStyles.bodyMedium,
              ),
              SizedBox(height: 12.h),

              // Delivery address
              Text(
                'Địa chỉ giao hàng:',
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                '${_selectedAddress!.name} - ${_selectedAddress!.phone}\n${_selectedAddress!.address}',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              SizedBox(height: 12.h),

              // Price breakdown
              Divider(height: 16.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Tổng tiền hàng:', style: AppTextStyles.bodyMedium),
                  Text(
                    '${widget.totalPrice} đ',
                    style: AppTextStyles.bodyMedium,
                  ),
                ],
              ),
              SizedBox(height: 8.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Phí vận chuyển:', style: AppTextStyles.bodyMedium),
                  Text('$_shippingFee đ', style: AppTextStyles.bodyMedium),
                ],
              ),
              if (_totalDiscountAmount > 0) ...[
                SizedBox(height: 8.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Giảm giá:', style: AppTextStyles.bodyMedium),
                    Text(
                      '- $_totalDiscountAmount đ',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
              ],
              Divider(height: 16.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Tổng thanh toán:',
                    style: AppTextStyles.bodyLarge.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '$totalAmount đ',
                    style: AppTextStyles.h3.copyWith(color: AppColors.error),
                  ),
                ],
              ),
              SizedBox(height: 8.h),

              // Payment method info
              Text(
                'Phương thức thanh toán: ${_paymentMethod == 'COD' ? 'Thanh toán khi nhận hàng' : 'Chuyển khoản (SePay)'}',
                style: AppTextStyles.bodyMedium.copyWith(
                  fontStyle: FontStyle.italic,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Hủy',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _performCreateOrder();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBlue,
              padding: EdgeInsets.symmetric(horizontal: 24.w),
            ),
            child: Text('Xác nhận đặt hàng', style: AppTextStyles.buttonText),
          ),
        ],
      ),
    );
  }

  void _performCreateOrder() {
    // Logic gom nhóm sản phẩm theo shopId
    final Map<int, List<int>> shopItems = {};

    for (var item in widget.selectedItems) {
      int? shopId = item.shopId;
      shopId ??= 1;
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
        paymentMethod: _paymentMethod,
        shopDiscountCode: _shopDiscount?.code,
        platformDiscountCode: _platformDiscount?.code,
        shippingFee: _shippingFee,
      );
    }).toList();

    context.read<OrderBloc>().add(OrderCreateRequested(orders: orders));
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _discountBloc,
      child: Builder(
        builder: (context) {
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
            body: MultiBlocListener(
              listeners: [
                BlocListener<OrderBloc, OrderState>(
                  listener: (context, state) {
                    if (state is OrderFailure) {
                      String errorMessage = state.message;
                      String errorTitle = 'Lỗi';

                      // Phân loại lỗi dựa trên message
                      if (state.message.toLowerCase().contains('stock') ||
                          state.message.toLowerCase().contains('hết hàng')) {
                        errorTitle = 'Sản phẩm hết hàng';
                        errorMessage =
                            'Một hoặc nhiều sản phẩm trong đơn hàng của bạn đã hết hàng.\nVui lòng quay lại giỏ hàng và kiểm tra lại.';
                      } else if (state.message.toLowerCase().contains(
                            'network',
                          ) ||
                          state.message.toLowerCase().contains('timeout') ||
                          state.message.toLowerCase().contains('connection')) {
                        errorTitle = 'Lỗi kết nối';
                        errorMessage =
                            'Không thể kết nối đến máy chủ. Vui lòng kiểm tra kết nối internet và thử lại.';
                      } else if (state.message.toLowerCase().contains(
                            'payment',
                          ) ||
                          state.message.toLowerCase().contains('thanh toán')) {
                        errorTitle = 'Lỗi thanh toán';
                        errorMessage =
                            '${state.message}\nVui lòng chọn phương thức thanh toán khác hoặc thử lại.';
                      } else if (state.message.toLowerCase().contains(
                            'address',
                          ) ||
                          state.message.toLowerCase().contains('địa chỉ')) {
                        errorTitle = 'Lỗi địa chỉ giao hàng';
                        errorMessage = state.message;
                      } else {
                        errorMessage = state.message.isEmpty
                            ? 'Đã xảy ra lỗi khi đặt hàng. Vui lòng thử lại.'
                            : state.message;
                      }

                      _showErrorDialog(errorTitle, errorMessage);
                    } else if (state is OrderCreated) {
                      if (_paymentMethod == 'SEPAY') {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) => PaymentQRPage(
                              paymentId: state.result.paymentId ?? 0,
                              totalAmount: _grandTotal,
                              orderId: state.result.orders.isNotEmpty ? state.result.orders.first.id : null,
                            ),
                          ),
                        );
                      } else {
                        _showSuccessDialog();
                      }
                    }
                  },
                ),
                BlocListener<DiscountBloc, DiscountState>(
                  bloc: _discountBloc,
                  listener: (context, state) {
                    if (state is DiscountError) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(state.message),
                          backgroundColor: AppColors.error,
                        ),
                      );
                      setState(() {
                        _productDiscountAmount = 0.0;
                        _shippingDiscountAmount = 0.0;
                      });
                    }
                    if (state is DiscountPreviewLoaded) {
                      setState(() {
                        // Đóng đinh 4 giá trị từ API preview (theo FRONTEND_GUIDE mục g)
                        _productDiscountAmount =
                            (state.previewData['discountAmount'] ?? 0.0)
                                .toDouble();
                        _shippingDiscountAmount =
                            (state.previewData['shippingDiscount'] ?? 0.0)
                                .toDouble();
                        _finalPrice =
                            (state.previewData['finalPrice'] as num?)?.toDouble();
                        _finalShippingFee =
                            (state.previewData['finalShippingFee'] as num?)?.toDouble();
                      });

                      if (_totalDiscountAmount > 0) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Áp dụng mã giảm thành công: -${_totalDiscountAmount.toStringAsFixed(0)}đ',
                            ),
                            backgroundColor: AppColors.success,
                            duration: const Duration(seconds: 1),
                          ),
                        );
                      }
                    }
                  },
                ),
              ],
              child: BlocBuilder<OrderBloc, OrderState>(
                builder: (context, state) {
                  return Stack(
                    children: [
                      SingleChildScrollView(
                        padding: EdgeInsets.only(bottom: 100.h),
                        child: Column(
                          children: [
                            _buildDeliverySection(),
                            _buildProductsSection(),
                            _buildDiscountSection(context),
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
            ),
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
    // Check stock availability for all items
    final invalidStockItems = widget.selectedItems.where((item) {
      // Nếu availableStock được cung cấp, kiểm tra xem quantity có vượt quá không
      if (item.availableStock != null && item.quantity > item.availableStock!) {
        return true;
      }
      return false;
    }).toList();

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

          // Stock warning if any item exceeds available quantity
          if (invalidStockItems.isNotEmpty) ...[
            SizedBox(height: 12.h),
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                border: Border.all(color: Colors.orange),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    color: Colors.orange,
                    size: 20.sp,
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      '${invalidStockItems.length} sản phẩm không đủ hàng. Vui lòng điều chỉnh số lượng.',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: Colors.orange.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          SizedBox(height: 16.h),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: widget.selectedItems.length,
            itemBuilder: (context, index) {
              final item = widget.selectedItems[index];
              final isOutOfStock =
                  item.availableStock != null &&
                  item.quantity > item.availableStock!;

              return Column(
                children: [
                  Stack(
                    children: [
                      CheckoutItemWidget(item: item),
                      if (isOutOfStock)
                        Positioned(
                          right: 8.w,
                          top: 8.w,
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8.w,
                              vertical: 4.h,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(4.r),
                            ),
                            child: Text(
                              'Vượt quá hàng',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  if (isOutOfStock) ...[
                    SizedBox(height: 4.h),
                    Text(
                      'Chỉ còn ${item.availableStock} sản phẩm, bạn đang chọn ${item.quantity}',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: Colors.red,
                      ),
                    ),
                  ],
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  // ============ DISCOUNT SECTION — hiển thị 2 dòng Shop + Platform ============
  Widget _buildDiscountSection(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 8.h),
      color: Colors.white,
      child: Column(
        children: [
          // --- Voucher Shop ---
          _buildVoucherRow(
            context,
            icon: Icons.storefront,
            iconColor: Colors.orange,
            label: 'Voucher Shop',
            discount: _shopDiscount,
            onTap: () => _openDiscountSheet(context, DiscountScope.SHOP),
            onClear: () {
              setState(() {
                _shopDiscount = null;
              });
              _previewAllDiscounts();
            },
          ),
          Divider(height: 1, indent: 16.w, endIndent: 16.w),
          // --- Voucher Sàn (Platform) ---
          _buildVoucherRow(
            context,
            icon: Icons.local_activity,
            iconColor: AppColors.primaryBlue,
            label: 'Voucher Sàn',
            discount: _platformDiscount,
            onTap: () => _openDiscountSheet(context, DiscountScope.PLATFORM),
            onClear: () {
              setState(() {
                _platformDiscount = null;
              });
              _previewAllDiscounts();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildVoucherRow(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String label,
    required Discount? discount,
    required VoidCallback onTap,
    required VoidCallback onClear,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        child: Row(
          children: [
            Icon(icon, color: iconColor, size: 24.sp),
            SizedBox(width: 12.w),
            Expanded(
              child: discount != null
                  ? Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Đã áp dụng: ${discount.code}',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        GestureDetector(
                          onTap: onClear,
                          child: Icon(
                            Icons.close,
                            size: 18.sp,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    )
                  : Text(
                      '$label / Chọn hoặc Nhập Mã',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
            ),
            SizedBox(width: 4.w),
            Icon(
              Icons.chevron_right,
              color: AppColors.textSecondary,
              size: 20.sp,
            ),
          ],
        ),
      ),
    );
  }

  // Mở bottom sheet lọc theo scope
  void _openDiscountSheet(BuildContext context, DiscountScope scope) {
    final currentDiscount = scope == DiscountScope.SHOP
        ? _shopDiscount
        : _platformDiscount;

    DiscountSelectionBottomSheet.show(
      context,
      currentSelectedDiscount: currentDiscount,
      filterScope: scope,
      onDiscountSelected: (discount) {
        setState(() {
          if (scope == DiscountScope.SHOP) {
            _shopDiscount = discount;
          } else {
            _platformDiscount = discount;
          }
        });
        _previewAllDiscounts();
      },
      onClearDiscount: () {
        setState(() {
          if (scope == DiscountScope.SHOP) {
            _shopDiscount = null;
          } else {
            _platformDiscount = null;
          }
        });
        _previewAllDiscounts();
      },
    );
  }

  // Preview tổng: gửi cả shop + platform discount code
  void _previewAllDiscounts() {
    final items = widget.selectedItems;
    if (items.isEmpty) {
      setState(() {
        _productDiscountAmount = 0.0;
        _shippingDiscountAmount = 0.0;
        _finalPrice = null;
        _finalShippingFee = null;
      });
      return;
    }

    // Nếu không có discount nào thì reset
    if (_shopDiscount == null && _platformDiscount == null) {
      setState(() {
        _productDiscountAmount = 0.0;
        _shippingDiscountAmount = 0.0;
        _finalPrice = null;
        _finalShippingFee = null;
      });
      return;
    }

    num subTotal = 0;
    for (final item in items) {
      subTotal += (item.price ?? 0) * item.quantity;
    }

    int currentUserId = 1;
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthSuccess) {
      currentUserId = authState.user.id;
    }

    // Preview cho shop discount
    if (_shopDiscount != null) {
      _discountBloc.add(
        DoPreviewDiscount(
          code: _shopDiscount!.code,
          orderValue: subTotal.toDouble(),
          shippingFee: _shippingFee,
          userId: currentUserId,
          shopId: _shopDiscount!.shopId ?? 0,
          items: items
              .map(
                (e) => {
                  "productId": e.productId,
                  "price": e.price,
                  "quantity": e.quantity,
                },
              )
              .toList(),
        ),
      );
    }

    // Preview cho platform discount
    if (_platformDiscount != null) {
      _discountBloc.add(
        DoPreviewDiscount(
          code: _platformDiscount!.code,
          orderValue: subTotal.toDouble(),
          shippingFee: _shippingFee,
          userId: currentUserId,
          shopId: 0,
          items: items
              .map(
                (e) => {
                  "productId": e.productId,
                  "price": e.price,
                  "quantity": e.quantity,
                },
              )
              .toList(),
        ),
      );
    }
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
              Text('${_shippingFee.toStringAsFixed(0)} đ', style: AppTextStyles.bodyMedium),
            ],
          ),
          if (_productDiscountAmount > 0) ...[
            SizedBox(height: 8.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Giảm giá sản phẩm', style: AppTextStyles.bodyMedium),
                Text(
                  '- ${_productDiscountAmount.toStringAsFixed(0)} đ',
                  style: AppTextStyles.bodyMedium.copyWith(color: Colors.green),
                ),
              ],
            ),
          ],
          if (_shippingDiscountAmount > 0) ...[
            SizedBox(height: 8.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Giảm phí vận chuyển', style: AppTextStyles.bodyMedium),
                Text(
                  '- ${_shippingDiscountAmount.toStringAsFixed(0)} đ',
                  style: AppTextStyles.bodyMedium.copyWith(color: Colors.blue),
                ),
              ],
            ),
          ],
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
                '${_grandTotal.toStringAsFixed(0)} đ',
                style: AppTextStyles.h3.copyWith(color: AppColors.error),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(bool isLoading) {
    // Check if any item has invalid stock
    final hasInvalidStock = widget.selectedItems.any((item) {
      return item.availableStock != null &&
          item.quantity > item.availableStock!;
    });

    final isButtonDisabled = isLoading || hasInvalidStock;

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
                    '${_grandTotal.toStringAsFixed(0)} đ',
                    style: AppTextStyles.h3.copyWith(color: AppColors.error),
                  ),
                ],
              ),
              ElevatedButton(
                onPressed: isButtonDisabled ? null : _submitOrder,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  disabledBackgroundColor: Colors.grey.withOpacity(0.5),
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
                    : Text(
                        hasInvalidStock ? 'Kiểm tra lại' : 'Đặt hàng',
                        style: AppTextStyles.buttonText,
                      ),
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
                  Navigator.pop(context);
                  Navigator.of(context).popUntil((route) => route.isFirst);
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

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        title: Text(
          title,
          style: AppTextStyles.h3.copyWith(color: AppColors.error),
        ),
        content: Text(message, style: AppTextStyles.bodyMedium),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK', style: TextStyle(color: AppColors.primaryBlue)),
          ),
          if (title.toLowerCase().contains('hết hàng'))
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context); // Quay lại giỏ hàng
              },
              child: Text(
                'Quay lại giỏ hàng',
                style: TextStyle(color: AppColors.primaryBlue),
              ),
            ),
        ],
      ),
    );
  }
}
