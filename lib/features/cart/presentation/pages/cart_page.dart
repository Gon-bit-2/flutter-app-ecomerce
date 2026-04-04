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
import 'package:app_fe_ecomerce/features/auth/presentation/bloc/auth/auth_bloc.dart';
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
  final Set<int> _selectedIds = {};
  Discount? _appliedDiscount;
  double _discountAmount = 0.0;

  @override
  void initState() {
    super.initState();
    context.read<CartBloc>().add(const CartLoadRequested(page: 1, limit: 100));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface, // Trắng xám F5F5F7
      appBar: AppBar(
        backgroundColor: Colors.white, // Trắng để sáng app
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Giỏ hàng',
          style: AppTextStyles.h2.copyWith(color: AppColors.textPrimary), // Chữ đen xám
        ),
        centerTitle: true,
        actions: [
          if (_selectedIds.isNotEmpty)
            TextButton(
              onPressed: () => _showDeleteConfirmDialog(context),
              child: Text(
                'Xóa',
                style: TextStyle(
                  color: AppColors.error,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
      body: MultiBlocListener(
        listeners: [
          BlocListener<CartBloc, CartState>(
            listener: (context, state) {
              if (state is CartFailure) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(state.message), backgroundColor: AppColors.error),
                );
              }
              if (state is CartOperationSuccess) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(state.message), backgroundColor: AppColors.success, duration: const Duration(seconds: 1)),
                );
              }
              if (state is CartLoaded) {
                _previewDiscount(state.items);
              }
            },
          ),
          BlocListener<DiscountBloc, DiscountState>(
            listener: (context, state) {
              if (state is DiscountError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(state.message), backgroundColor: AppColors.error),
                );
                setState(() {
                  _discountAmount = 0.0;
                });
              }
              if (state is DiscountPreviewLoaded) {
                setState(() {
                  _discountAmount = (state.previewData['discountValue'] ?? 0.0).toDouble();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Áp dụng mã giảm thành công: -$_discountAmountđ'),
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
          buildWhen: (previous, current) {
            if (current is CartOperationSuccess) return false;
            return true;
          },
          builder: (context, state) {
            if (state is CartLoading || state is CartInitial) {
              return const Center(child: CircularProgressIndicator(color: AppColors.primaryBlue));
            }

            List<CartEntity> items = [];
            if (state is CartLoaded) {
              items = state.items;
            }

            if (items.isEmpty) {
              return _buildEmptyCart();
            }

            return Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.symmetric(vertical: 8.h),
                    physics: const BouncingScrollPhysics(),
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
                          context.read<CartBloc>().add(CartItemUpdated(id: item.id, quantity: item.quantity + 1));
                        },
                        onDecrease: () {
                          if (item.quantity > 1) {
                            context.read<CartBloc>().add(CartItemUpdated(id: item.id, quantity: item.quantity - 1));
                          }
                        },
                        onRemove: () {
                          _showDeleteSingleConfirmDialog(context, item);
                        },
                      );
                    },
                  ),
                ),

                _buildDiscountSection(context, items),

                CartSummaryWidget(
                  isAllSelected: items.isNotEmpty && _selectedIds.length == items.length,
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
                    final checkoutItems = items.where((e) => _selectedIds.contains(e.id)).toList();
                    if (checkoutItems.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Vui lòng chọn ít nhất 1 sản phẩm để thanh toán'), backgroundColor: AppColors.error),
                      );
                      return;
                    }

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => app_fe_ecomerce_order.CheckoutPage(
                          selectedItems: checkoutItems,
                          totalPrice: _calculateTotalPrice(items) + _discountAmount,
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

  Widget _buildDiscountSection(BuildContext context, List<CartEntity> items) {
    return InkWell(
      onTap: () {
        DiscountSelectionBottomSheet.show(
          context,
          currentSelectedDiscount: _appliedDiscount,
          onDiscountSelected: (discount) {
            setState(() => _appliedDiscount = discount);
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
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: Colors.white, // Khối độc lập màu trắng
          border: Border(
            top: BorderSide(color: AppColors.border.withOpacity(0.5)),
          ),
        ),
        child: Row(
          children: [
            Icon(Icons.local_activity, color: AppColors.primaryBlue, size: 24.sp),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                _appliedDiscount != null ? 'Đã áp dụng mã: ${_appliedDiscount!.code}' : 'App Voucher / Chọn hoặc Nhập Mã',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: _appliedDiscount != null ? AppColors.success : AppColors.textPrimary,
                  fontWeight: _appliedDiscount != null ? FontWeight.bold : FontWeight.w500,
                ),
              ),
            ),
            Icon(Icons.chevron_right, color: AppColors.textSecondary, size: 20.sp),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyCart() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(24.w),
            decoration: BoxDecoration(
              color: AppColors.primaryBlue.withOpacity(0.05),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.shopping_cart_outlined, size: 80.sp, color: AppColors.primaryBlue),
          ),
          SizedBox(height: 24.h),
          Text('Giỏ hàng trống', style: AppTextStyles.h2.copyWith(color: AppColors.textPrimary)),
          SizedBox(height: 8.h),
          Text('Hãy thêm sản phẩm vào giỏ hàng nhé!', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
          SizedBox(height: 32.h),
          ElevatedButton(
            onPressed: () => Navigator.popUntil(context, (route) => route.isFirst), // Trở về trang chủ
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBlue,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: EdgeInsets.symmetric(horizontal: 40.w, vertical: 14.h),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
            ),
            child: Text('Mua sắm ngay', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

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

  void _previewDiscount(List<CartEntity> items) {
    if (_appliedDiscount == null || _selectedIds.isEmpty) {
      setState(() => _discountAmount = 0.0);
      return;
    }

    final selectedItems = items.where((e) => _selectedIds.contains(e.id)).toList();
    num subTotal = 0;
    for (final item in selectedItems) {
      subTotal += (item.price ?? 0) * item.quantity;
    }

    int currentUserId = 1;
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthSuccess) {
      currentUserId = authState.user.id;
    }

    context.read<DiscountBloc>().add(
      DoPreviewDiscount(
        code: _appliedDiscount!.code,
        orderValue: subTotal.toDouble(),
        userId: currentUserId,
        shopId: _appliedDiscount!.shopId ?? 0,
        items: selectedItems.map((e) => {"productId": e.productId, "price": e.price, "quantity": e.quantity}).toList(),
      ),
    );
  }

  void _showDeleteConfirmDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        title: const Text('Xóa sản phẩm'),
        content: Text('Bạn có chắc muốn xóa ${_selectedIds.length} sản phẩm đã chọn?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy', style: TextStyle(color: Colors.grey))),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<CartBloc>().add(CartItemsRemoved(cartItemIds: _selectedIds.toList()));
              setState(() => _selectedIds.clear());
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r))),
            child: const Text('Xóa', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showDeleteSingleConfirmDialog(BuildContext context, CartEntity item) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        title: const Text('Xóa sản phẩm'),
        content: Text('Bạn có chắc muốn xóa "${item.productName ?? 'sản phẩm này'}" khỏi giỏ hàng?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy', style: TextStyle(color: Colors.grey))),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<CartBloc>().add(CartItemsRemoved(cartItemIds: [item.id]));
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r))),
            child: const Text('Xóa', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
