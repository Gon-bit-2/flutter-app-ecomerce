import 'package:app_fe_ecomerce/core/styles/app_colors.dart';
import 'package:app_fe_ecomerce/core/styles/app_text_styles.dart';
import 'package:app_fe_ecomerce/features/order/presentation/bloc/order/order_bloc.dart';
import 'package:app_fe_ecomerce/features/order/presentation/widgets/order_card_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get_it/get_it.dart';

class OrderHistoryPage extends StatefulWidget {
  const OrderHistoryPage({super.key});

  @override
  State<OrderHistoryPage> createState() => _OrderHistoryPageState();
}

class _OrderHistoryPageState extends State<OrderHistoryPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late OrderBloc _orderBloc;
  final ScrollController _scrollController = ScrollController();

  int _currentPage = 1;
  final int _limit = 10;
  String? _currentStatus; // null means "All"

  final List<Map<String, String?>> _tabs = [
    {'title': 'Tất cả', 'status': null},
    {'title': 'Chờ TT', 'status': 'UNPAID'},
    {'title': 'Chờ lấy', 'status': 'READY_TO_SHIP'},
    {'title': 'Đang giao', 'status': 'SHIPPED'},
    {'title': 'Đã giao', 'status': 'COMPLETED'},
    {'title': 'Đã hủy', 'status': 'CANCELLED'},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _tabController.addListener(_handleTabSelection);

    _orderBloc = GetIt.I<OrderBloc>();
    _loadOrders(refresh: true);

    _scrollController.addListener(_onScroll);
  }

  void _handleTabSelection() {
    if (_tabController.indexIsChanging) {
      _currentStatus = _tabs[_tabController.index]['status'];
      _loadOrders(refresh: true);
    }
  }

  void _loadOrders({bool refresh = false}) {
    if (refresh) {
      _currentPage = 1;
    }
    _orderBloc.add(
      OrdersLoadRequested(
        page: _currentPage,
        limit: _limit,
        status: _currentStatus,
      ),
    );
  }

  void _onScroll() {
    if (_isBottom && !_isFetchingMore) {
      final state = _orderBloc.state;
      if (state is OrdersLoaded && !state.hasReachedMax) {
        setState(() {
          _isFetchingMore = true;
        });
        _currentPage++;
        _loadOrders();
      }
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll - 200);
  }

  bool _isFetchingMore = false;

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    _orderBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _orderBloc,
      child: Scaffold(
        backgroundColor: AppColors.inputBackground,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text('Đơn hàng của tôi', style: AppTextStyles.h3),
          centerTitle: true,
          bottom: TabBar(
            controller: _tabController,
            isScrollable: true,
            labelColor: AppColors.primaryBlue,
            unselectedLabelColor: AppColors.textSecondary,
            indicatorColor: AppColors.primaryBlue,
            tabs: _tabs.map((tab) => Tab(text: tab['title'])).toList(),
          ),
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
              setState(() {
                _isFetchingMore = false;
              });
            } else if (state is OrdersLoaded) {
              setState(() {
                _isFetchingMore = false;
              });
            }
          },
          builder: (context, state) {
            if (state is OrderLoading && _currentPage == 1) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.primaryBlue),
              );
            }

            if (state is OrdersLoaded) {
              if (state.orders.isEmpty) {
                return _buildEmptyState();
              }

              return RefreshIndicator(
                onRefresh: () async {
                  _loadOrders(refresh: true);
                },
                child: ListView.builder(
                  controller: _scrollController,
                  padding: EdgeInsets.all(16.w),
                  itemCount: state.hasReachedMax
                      ? state.orders.length
                      : state.orders.length + 1,
                  itemBuilder: (context, index) {
                    if (index >= state.orders.length) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.primaryBlue,
                          ),
                        ),
                      );
                    }
                    return OrderCardWidget(order: state.orders[index]);
                  },
                ),
              );
            }
            return const SizedBox();
          },
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.receipt_long, size: 80.sp, color: Colors.grey[300]),
          SizedBox(height: 16.h),
          Text(
            'Chưa có đơn hàng nào',
            style: AppTextStyles.h3.copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}
