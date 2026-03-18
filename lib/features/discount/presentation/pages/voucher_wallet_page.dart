import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/discount/discount_bloc.dart';
import '../bloc/discount/discount_event.dart';
import '../bloc/discount/discount_state.dart';
import '../widgets/discount_card_widget.dart';
import 'package:get_it/get_it.dart';

class VoucherWalletPage extends StatefulWidget {
  const VoucherWalletPage({super.key});

  @override
  State<VoucherWalletPage> createState() => _VoucherWalletPageState();
}

class _VoucherWalletPageState extends State<VoucherWalletPage>
    with SingleTickerProviderStateMixin {
  late DiscountBloc _discountBloc;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _discountBloc = GetIt.I<DiscountBloc>();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_onTabChanged);
    // Mặc định load tab "Voucher của tôi"
    _discountBloc.add(const FetchMyVouchers());
  }

  void _onTabChanged() {
    if (_tabController.indexIsChanging) return;
    if (_tabController.index == 0) {
      _discountBloc.add(const FetchMyVouchers());
    } else {
      _discountBloc.add(const FetchAvailableDiscounts());
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    _discountBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            const Text('Kho Voucher', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.black),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Theme.of(context).primaryColor,
          unselectedLabelColor: Colors.grey.shade600,
          indicatorColor: Theme.of(context).primaryColor,
          indicatorWeight: 2.5,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold),
          unselectedLabelStyle:
              const TextStyle(fontWeight: FontWeight.normal),
          tabs: const [
            Tab(text: 'Voucher của tôi'),
            Tab(text: 'Có thể lưu'),
          ],
        ),
      ),
      backgroundColor: const Color(0xFFF5F5F5),
      body: BlocConsumer<DiscountBloc, DiscountState>(
        bloc: _discountBloc,
        listener: (context, state) {
          if (state is SaveVoucherSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Lưu voucher thành công!'),
                backgroundColor: Colors.green,
              ),
            );
            // Chuyển về tab "Voucher của tôi" sau khi lưu
            _tabController.animateTo(0);
          } else if (state is DiscountError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is DiscountLoading || state is SaveVoucherLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          // Tab "Voucher của tôi"
          if (state is MyVouchersLoaded && _tabController.index == 0) {
            return _buildMyVouchersList(state);
          }

          // Tab "Có thể lưu"
          if (state is AvailableDiscountsLoaded &&
              _tabController.index == 1) {
            return _buildAvailableVouchersList(state);
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildMyVouchersList(MyVouchersLoaded state) {
    final vouchers = state.vouchers;

    if (vouchers.isEmpty) {
      return _buildEmptyState(
        icon: Icons.local_activity_outlined,
        message: 'Bạn chưa có mã giảm giá nào',
        actionLabel: 'Xem voucher có thể lưu',
        onAction: () => _tabController.animateTo(1),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        _discountBloc.add(const FetchMyVouchers());
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: vouchers.length,
        itemBuilder: (context, index) {
          return DiscountCardWidget(
            discount: vouchers[index],
            onTap: () {
              // Có thể mở rộng: xem chi tiết voucher
            },
          );
        },
      ),
    );
  }

  Widget _buildAvailableVouchersList(AvailableDiscountsLoaded state) {
    final vouchers = state.vouchers;

    if (vouchers.isEmpty) {
      return _buildEmptyState(
        icon: Icons.search_off,
        message: 'Không có voucher nào để lưu lúc này',
        actionLabel: 'Tiếp tục mua sắm',
        onAction: () => Navigator.pop(context),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        _discountBloc.add(const FetchAvailableDiscounts());
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: vouchers.length,
        itemBuilder: (context, index) {
          final discount = vouchers[index];
          return DiscountCardWidget(
            discount: discount,
            showSaveButton: true,
            onSave: () {
              _discountBloc
                  .add(SaveVoucherRequested(discountId: discount.id));
            },
            onTap: () {},
          );
        },
      ),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String message,
    required String actionLabel,
    required VoidCallback onAction,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 80, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: onAction,
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
            ),
            child: Text(
              actionLabel,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
