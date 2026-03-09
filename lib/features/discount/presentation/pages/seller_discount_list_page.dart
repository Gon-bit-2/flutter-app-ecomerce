import 'package:app_fe_ecomerce/core/styles/app_colors.dart';
import 'package:app_fe_ecomerce/core/styles/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';

import '../bloc/seller_discount/seller_discount_bloc.dart';
import '../bloc/seller_discount/seller_discount_event.dart';
import '../bloc/seller_discount/seller_discount_state.dart';
import 'add_edit_discount_page.dart';

class SellerDiscountListPage extends StatefulWidget {
  final int? shopId; // Nếu là Shop, truyền shopId. Nếu Admin thì null.

  const SellerDiscountListPage({super.key, this.shopId});

  @override
  State<SellerDiscountListPage> createState() => _SellerDiscountListPageState();
}

class _SellerDiscountListPageState extends State<SellerDiscountListPage> {
  late SellerDiscountBloc _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = GetIt.I<SellerDiscountBloc>();
    _loadDiscounts();
  }

  void _loadDiscounts() {
    _bloc.add(FetchSellerDiscounts(page: 1, limit: 20, shopId: widget.shopId));
  }

  void _confirmDelete(BuildContext context, int discountId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xác nhận xoá'),
        content: const Text('Bạn có chắc chắn muốn xoá mã giảm giá này?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Huỷ', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () {
              Navigator.pop(ctx);
              _bloc.add(DeleteExistingDiscount(discountId: discountId));
            },
            child: const Text('Xoá', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _bloc,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.primaryBlue,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            'Quản lý Khuyến Mãi',
            style: AppTextStyles.h3.copyWith(color: Colors.white),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.add, color: Colors.white),
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AddEditDiscountPage(),
                  ),
                );
                if (result == true) {
                  _loadDiscounts(); // reload
                }
              },
            ),
          ],
        ),
        body: BlocConsumer<SellerDiscountBloc, SellerDiscountState>(
          listener: (context, state) {
            if (state is SellerDiscountError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: AppColors.error,
                ),
              );
            } else if (state is SellerDiscountOperationSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: AppColors.success,
                ),
              );
              _loadDiscounts();
            }
          },
          buildWhen: (previous, current) =>
              current is SellerDiscountsLoaded ||
              current is SellerDiscountLoading,
          builder: (context, state) {
            if (state is SellerDiscountLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is SellerDiscountsLoaded) {
              final discounts = state.discounts;
              if (discounts.isEmpty) {
                return Center(
                  child: Text(
                    'Chưa có mã giảm giá nào.',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: () async => _loadDiscounts(),
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: discounts.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final discount = discounts[index];
                    final formatCurrency = NumberFormat.currency(
                      locale: 'vi_VN',
                      symbol: 'đ',
                    );
                    final valueStr = discount.type == 'PERCENTAGE'
                        ? '${discount.value}%'
                        : formatCurrency.format(discount.value);

                    return Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(12),
                        leading: CircleAvatar(
                          backgroundColor: discount.isActive
                              ? AppColors.primaryBlue.withOpacity(0.1)
                              : Colors.grey.withOpacity(0.1),
                          child: Icon(
                            Icons.local_offer,
                            color: discount.isActive
                                ? AppColors.primaryBlue
                                : Colors.grey,
                          ),
                        ),
                        title: Text(
                          discount.name,
                          style: AppTextStyles.bodyLarge.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text(
                              'Mã: ${discount.code}',
                              style: AppTextStyles.bodyMedium,
                            ),
                            Text(
                              'Giảm: $valueStr',
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.error,
                              ),
                            ),
                            Text(
                              'HSD: ${DateFormat('dd/MM/yyyy HH:mm').format(discount.endDate)}',
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.textSecondary,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(
                                Icons.edit,
                                color: AppColors.primaryBlue,
                              ),
                              onPressed: () async {
                                final result = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        AddEditDiscountPage(discount: discount),
                                  ),
                                );
                                if (result == true) {
                                  _loadDiscounts();
                                }
                              },
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.delete,
                                color: AppColors.error,
                              ),
                              onPressed: () =>
                                  _confirmDelete(context, discount.id),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}
