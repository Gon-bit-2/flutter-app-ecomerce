import 'package:app_fe_ecomerce/core/styles/app_colors.dart';
import 'package:app_fe_ecomerce/core/styles/app_text_styles.dart';
import 'package:app_fe_ecomerce/features/discount/domain/entities/discount.dart';
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
  final bool isAdmin; // true = Admin quản lý mã toàn sàn

  const SellerDiscountListPage({
    super.key,
    this.shopId,
    this.isAdmin = false,
  });

  @override
  State<SellerDiscountListPage> createState() => _SellerDiscountListPageState();
}

class _SellerDiscountListPageState extends State<SellerDiscountListPage>
    with SingleTickerProviderStateMixin {
  late SellerDiscountBloc _bloc;
  late TabController? _tabController;

  @override
  void initState() {
    super.initState();
    _bloc = GetIt.I<SellerDiscountBloc>();

    // Admin có 3 tab: Tất cả, Toàn sàn, Shop
    if (widget.isAdmin) {
      _tabController = TabController(length: 3, vsync: this);
      _tabController!.addListener(_onTabChanged);
    } else {
      _tabController = null;
    }

    _loadDiscounts();
  }

  @override
  void dispose() {
    _tabController?.removeListener(_onTabChanged);
    _tabController?.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    if (_tabController!.indexIsChanging) return;
    _loadDiscounts();
  }

  void _loadDiscounts() {
    String? scopeFilter;
    if (widget.isAdmin && _tabController != null) {
      switch (_tabController!.index) {
        case 1:
          scopeFilter = 'PLATFORM';
          break;
        case 2:
          scopeFilter = 'SHOP';
          break;
        default:
          scopeFilter = null;
      }
    }

    _bloc.add(FetchSellerDiscounts(
      page: 1,
      limit: 50,
      shopId: widget.isAdmin ? null : widget.shopId,
      scope: scopeFilter,
    ));
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
    final Color themeColor = AppColors.primaryBlue;
    final String pageTitle =
        widget.isAdmin ? 'Quản Lý Voucher Toàn Sàn' : 'Quản lý Khuyến Mãi';

    return BlocProvider.value(
      value: _bloc,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: themeColor,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            pageTitle,
            style: AppTextStyles.h3.copyWith(color: Colors.white),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.add, color: Colors.white),
              tooltip: widget.isAdmin ? 'Tạo mã toàn sàn' : 'Tạo mã shop',
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AddEditDiscountPage(
                      shopId: widget.shopId,
                      isAdmin: widget.isAdmin,
                    ),
                  ),
                );
                if (result == true) {
                  _loadDiscounts(); // reload
                }
              },
            ),
          ],
          bottom: widget.isAdmin
              ? TabBar(
                  controller: _tabController,
                  indicatorColor: Colors.white,
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.white70,
                  tabs: const [
                    Tab(text: 'Tất cả'),
                    Tab(text: '🌐  Toàn sàn'),
                    Tab(text: '🏪  Shop'),
                  ],
                )
              : null,
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
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.local_offer_outlined,
                        size: 64,
                        color: Colors.grey.shade300,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Chưa có mã giảm giá nào.',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.isAdmin
                            ? 'Bấm + để tạo mã giảm giá toàn sàn'
                            : 'Bấm + để tạo mã giảm giá cho shop',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
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
                    return _buildDiscountCard(context, discount);
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

  Widget _buildDiscountCard(BuildContext context, Discount discount) {
    final formatCurrency = NumberFormat.currency(
      locale: 'vi_VN',
      symbol: 'đ',
    );
    final valueStr = discount.type == DiscountType.PERCENTAGE
        ? '${discount.value}%'
        : formatCurrency.format(discount.value);

    final bool isPlatform = discount.scope == DiscountScope.PLATFORM;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isPlatform
              ? Colors.red.shade100
              : Colors.blue.shade100,
          width: 1,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AddEditDiscountPage(
                discount: discount,
                shopId: widget.shopId,
                isAdmin: widget.isAdmin,
              ),
            ),
          );
          if (result == true) {
            _loadDiscounts();
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row: scope badge + name + actions
              Row(
                children: [
                  // Scope badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: isPlatform
                          ? Colors.red.shade50
                          : Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color: isPlatform
                            ? Colors.red.shade200
                            : Colors.blue.shade200,
                      ),
                    ),
                    child: Text(
                      isPlatform ? 'Toàn sàn' : 'Shop',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: isPlatform
                            ? Colors.red.shade700
                            : Colors.blue.shade700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Type badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      _getTypeLabel(discount.type),
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ),
                  const Spacer(),
                  // Active indicator
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: discount.isActive ? Colors.green : Colors.grey,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    discount.isActive ? 'Đang hoạt động' : 'Tắt',
                    style: TextStyle(
                      fontSize: 11,
                      color: discount.isActive ? Colors.green : Colors.grey,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              // Name
              Text(
                discount.name,
                style: AppTextStyles.bodyLarge.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 6),
              // Code + Value row
              Row(
                children: [
                  // Code chip
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.warning.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: AppColors.warning.withOpacity(0.4)),
                    ),
                    child: Text(
                      discount.code,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: AppColors.warning,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Giảm $valueStr',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.error,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Date range + actions
              Row(
                children: [
                  Icon(
                    Icons.schedule,
                    size: 14,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${DateFormat('dd/MM/yyyy').format(discount.startDate)} - ${DateFormat('dd/MM/yyyy').format(discount.endDate)}',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const Spacer(),
                  // Edit button
                  InkWell(
                    onTap: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AddEditDiscountPage(
                            discount: discount,
                            shopId: widget.shopId,
                            isAdmin: widget.isAdmin,
                          ),
                        ),
                      );
                      if (result == true) {
                        _loadDiscounts();
                      }
                    },
                    borderRadius: BorderRadius.circular(4),
                    child: Padding(
                      padding: const EdgeInsets.all(4),
                      child: Icon(
                        Icons.edit_outlined,
                        size: 20,
                        color: AppColors.primaryBlue,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Delete button
                  InkWell(
                    onTap: () => _confirmDelete(context, discount.id),
                    borderRadius: BorderRadius.circular(4),
                    child: Padding(
                      padding: const EdgeInsets.all(4),
                      child: Icon(
                        Icons.delete_outline,
                        size: 20,
                        color: AppColors.error,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getTypeLabel(DiscountType type) {
    switch (type) {
      case DiscountType.PERCENTAGE:
        return 'Giảm %';
      case DiscountType.FIXED_AMOUNT:
        return 'Giảm tiền';
      case DiscountType.SHIPPING:
        return 'Freeship';
      case DiscountType.COIN_CASHBACK:
        return 'Hoàn xu';
    }
  }
}
