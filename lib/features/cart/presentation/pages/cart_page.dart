import 'package:app_fe_ecomerce/core/styles/app_colors.dart';
import 'package:app_fe_ecomerce/core/styles/app_text_styles.dart';
import 'package:app_fe_ecomerce/features/cart/domain/entities/cart_entity.dart';
import 'package:app_fe_ecomerce/features/cart/presentation/bloc/cart/cart_bloc.dart';
import 'package:app_fe_ecomerce/features/cart/presentation/widgets/cart_item_widget.dart';
import 'package:app_fe_ecomerce/features/cart/presentation/widgets/cart_summary_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:app_fe_ecomerce/features/order/presentation/pages/checkout_page.dart'
    as app_fe_ecomerce_order;

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const CartView();
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
      body: BlocConsumer<CartBloc, CartState>(
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
        },
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
                      builder: (context) => app_fe_ecomerce_order.CheckoutPage(
                        selectedItems: checkoutItems,
                        totalPrice: _calculateTotalPrice(items),
                      ),
                    ),
                  );
                },
              ),
            ],
          );
        },
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

  // Tính tổng tiền các sản phẩm đã chọn
  num _calculateTotalPrice(List<CartEntity> items) {
    num total = 0;
    for (final item in items) {
      if (_selectedIds.contains(item.id)) {
        total += (item.price ?? 0) * item.quantity;
      }
    }
    return total;
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
