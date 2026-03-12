import 'package:app_fe_ecomerce/core/styles/app_colors.dart';
import 'package:app_fe_ecomerce/core/styles/app_text_styles.dart';
import 'package:app_fe_ecomerce/features/cart/domain/entities/cart_entity.dart';
import 'package:app_fe_ecomerce/features/cart/presentation/bloc/cart/cart_bloc.dart';
import 'package:app_fe_ecomerce/features/cart/presentation/widgets/cart_item_widget.dart';
import 'package:app_fe_ecomerce/features/cart/presentation/widgets/cart_summary_widget.dart';
import 'package:app_fe_ecomerce/features/order/presentation/pages/checkout_page.dart'
    as app_fe_ecomerce_order;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:app_fe_ecomerce/features/discount/domain/entities/discount.dart';
import 'package:app_fe_ecomerce/features/discount/presentation/widgets/discount_selection_bottom_sheet.dart';
import 'package:app_fe_ecomerce/features/discount/presentation/bloc/discount/discount_bloc.dart';
import 'package:app_fe_ecomerce/features/discount/presentation/bloc/discount/discount_event.dart';
import 'package:app_fe_ecomerce/features/discount/presentation/bloc/discount/discount_state.dart';
import 'package:get_it/get_it.dart';

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => GetIt.I<DiscountBloc>(),
      child: const CartView(),
    );
  }
}

class CartView extends StatefulWidget {
  const CartView({super.key});

  @override
  State<CartView> createState() => _CartViewState();
}

class _CartViewState extends State<CartView> {
  // Danh sách ID các sản phẩm đã chọn (để xóa hàng loạt / tính tổng tiền)
  final Set<int> _selectedIds = {};

  // Voucher đang được chọn ở giỏ hàng
  Discount? _appliedDiscount;
  double _discountAmount = 0.0; // Số tiền được giảm

  @override
  void initState() {
    super.initState();
    // Tải giỏ hàng khi mở trang
    context.read<CartBloc>().add(const CartLoadRequested(page: 1, limit: 100));
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
          'Giỏ hàng',
          style: AppTextStyles.h3.copyWith(color: Colors.white),
        ),
        centerTitle: true,
        actions: [
          // Nút xóa các sản phẩm đã chọn
          if (_selectedIds.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.white),
              onPressed: () => _showDeleteConfirmDialog(context),
            ),
        ],
      ),
      body: MultiBlocListener(
        listeners: [
          BlocListener<CartBloc, CartState>(
            listener: (context, state) {
              if (state is CartFailure) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: AppColors.error,
                  ),
                );
              }
              if (state is CartOperationSuccess) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: AppColors.success,
                    duration: const Duration(seconds: 1),
                  ),
                );
              }
              if (state is CartLoaded) {
                // Giỏ hàng thay đổi -> tính lại voucher nếu có
                _previewDiscount(state.items);
              }
            },
          ),
          BlocListener<DiscountBloc, DiscountState>(
            listener: (context, state) {
              if (state is DiscountPreviewLoading) {
                // Có thể show dialog loading
              }
              if (state is DiscountError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: AppColors.error,
                  ),
                );
                setState(() {
                  // _appliedDiscount = null;
                  _discountAmount = 0.0;
                });
              }
              if (state is DiscountPreviewLoaded) {
                setState(() {
                  // data từ backend preview, ví dụ: { "discountValue": 15000, "finalPrice": ... }
                  // Tuỳ format APi, giả định backend trả về field `discountValue`
                  _discountAmount = (state.previewData['discountValue'] ?? 0.0)
                      .toDouble();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Áp dụng mã giảm thành công: -$_discountAmountđ',
                      ),
                      backgroundColor: AppColors.success,
                      duration: const Duration(seconds: 1),
                    ),
                  );
                });
              }
            },
          ),
        ],
        child: BlocBuilder<CartBloc, CartState>(
          builder: (context, state) {
            // Đang tải
            if (state is CartLoading) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.primaryBlue),
              );
            }

            // Lấy danh sách items từ state
            List<CartEntity> items = [];
            if (state is CartLoaded) {
              items = state.items;
            }

            // Giỏ hàng trống
            if (items.isEmpty) {
              return _buildEmptyCart();
            }

            return Column(
              children: [
                // Danh sách sản phẩm
                Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.only(top: 8.h, bottom: 8.h),
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];
                      return CartItemWidget(
                        item: item,
                        isSelected: _selectedIds.contains(item.id),
                        onSelected: (selected) {
                          setState(() {
                            if (selected == true) {
                              _selectedIds.add(item.id);
                            } else {
                              _selectedIds.remove(item.id);
                            }
                          });
                        },
                        onIncrease: () {
                          context.read<CartBloc>().add(
                            CartItemUpdated(
                              id: item.id,
                              quantity: item.quantity + 1,
                            ),
                          );
                        },
                        onDecrease: () {
                          if (item.quantity > 1) {
                            context.read<CartBloc>().add(
                              CartItemUpdated(
                                id: item.id,
                                quantity: item.quantity - 1,
                              ),
                            );
                          }
                        },
                        onRemove: () {
                          _showDeleteSingleConfirmDialog(context, item);
                        },
                      );
                    },
                  ),
                ),

                // Khối Voucher / Mã giảm giá
                _buildDiscountSection(context, items),

                // Thanh tổng kết
                CartSummaryWidget(
                  isAllSelected:
                      items.isNotEmpty && _selectedIds.length == items.length,
                  onSelectAll: (selected) {
                    setState(() {
                      if (selected == true) {
                        _selectedIds.addAll(items.map((e) => e.id));
                      } else {
                        _selectedIds.clear();
                      }
                    });
                  },
                  selectedCount: _selectedIds.length,
                  totalPrice: _calculateTotalPrice(items),
                  onCheckout: () {
                    final checkoutItems = items
                        .where((e) => _selectedIds.contains(e.id))
                        .toList();
                    if (checkoutItems.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Vui lòng chọn ít nhất 1 sản phẩm để thanh toán',
                          ),
                          backgroundColor: AppColors.error,
                        ),
                      );
                      return;
                    }

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            app_fe_ecomerce_order.CheckoutPage(
                              selectedItems: checkoutItems,
                              totalPrice:
                                  _calculateTotalPrice(items) +
                                  _discountAmount, // Pass subtotal
                              discountAmount: _discountAmount,
                            ),
                      ),
                    );
                  },
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  // Khối Voucher UI
  Widget _buildDiscountSection(BuildContext context, List<CartEntity> items) {
    return InkWell(
      onTap: () {
        DiscountSelectionBottomSheet.show(
          context,
          currentSelectedDiscount: _appliedDiscount,
          onDiscountSelected: (discount) {
            setState(() {
              _appliedDiscount = discount;
            });
            _previewDiscount(items);
          },
          onClearDiscount: () {
            setState(() {
              _appliedDiscount = null;
              _discountAmount = 0.0;
            });
          },
        );
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            bottom: BorderSide(
              color: AppColors.border.withOpacity(0.5),
              width: 1,
            ),
            top: BorderSide(color: AppColors.border.withOpacity(0.5), width: 1),
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.local_activity,
              color: Theme.of(context).primaryColor,
              size: 24.sp,
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                _appliedDiscount != null
                    ? 'Đã áp dụng mã: ${_appliedDiscount!.code}'
                    : 'Shopee Voucher / Chọn hoặc Nhập Mã',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: _appliedDiscount != null
                      ? Colors.green
                      : AppColors.textPrimary,
                  fontWeight: _appliedDiscount != null
                      ? FontWeight.bold
                      : FontWeight.normal,
                ),
              ),
            ),
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

  // Widget giỏ hàng trống
  Widget _buildEmptyCart() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_cart_outlined,
            size: 80.sp,
            color: AppColors.border,
          ),
          SizedBox(height: 16.h),
          Text(
            'Giỏ hàng trống',
            style: AppTextStyles.h3.copyWith(color: AppColors.textSecondary),
          ),
          SizedBox(height: 8.h),
          Text(
            'Hãy thêm sản phẩm vào giỏ hàng nhé!',
            style: AppTextStyles.bodyMedium,
          ),
          SizedBox(height: 24.h),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBlue,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 12.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
            child: Text('Mua sắm ngay', style: AppTextStyles.buttonText),
          ),
        ],
      ),
    );
  }

  // Tính tổng tiền các sản phẩm đã chọn (Sau khi đã trừ discount)
  num _calculateTotalPrice(List<CartEntity> items) {
    num total = 0;
    for (final item in items) {
      if (_selectedIds.contains(item.id)) {
        total += (item.price ?? 0) * item.quantity;
      }
    }
    num finalPrice = total - _discountAmount;
    return finalPrice > 0 ? finalPrice : 0;
  }

  // Helper trigger preview
  void _previewDiscount(List<CartEntity> items) {
    if (_appliedDiscount == null || _selectedIds.isEmpty) {
      setState(() {
        _discountAmount = 0.0;
      });
      return;
    }

    final selectedItems = items
        .where((e) => _selectedIds.contains(e.id))
        .toList();
    num subTotal = 0;
    for (final item in selectedItems) {
      subTotal += (item.price ?? 0) * item.quantity;
    }

    context.read<DiscountBloc>().add(
      DoPreviewDiscount(
        code: _appliedDiscount!.code,
        orderValue: subTotal.toDouble(),
        userId: 1, // Optional: backend handle from token
        shopId: _appliedDiscount!.shopId ?? 0,
        items: selectedItems
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

  // Dialog xác nhận xóa nhiều sản phẩm
  void _showDeleteConfirmDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xóa sản phẩm'),
        content: Text(
          'Bạn có chắc muốn xóa ${_selectedIds.length} sản phẩm đã chọn?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<CartBloc>().add(
                CartItemsRemoved(cartItemIds: _selectedIds.toList()),
              );
              setState(() => _selectedIds.clear());
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Xóa', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // Dialog xác nhận xóa 1 sản phẩm
  void _showDeleteSingleConfirmDialog(BuildContext context, CartEntity item) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xóa sản phẩm'),
        content: Text(
          'Bạn có chắc muốn xóa "${item.productName ?? 'sản phẩm này'}" khỏi giỏ hàng?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<CartBloc>().add(
                CartItemsRemoved(cartItemIds: [item.id]),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Xóa', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
