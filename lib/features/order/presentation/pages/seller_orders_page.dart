import 'package:app_fe_ecomerce/core/styles/app_colors.dart';
import 'package:app_fe_ecomerce/core/styles/app_text_styles.dart';
import 'package:app_fe_ecomerce/features/order/domain/entities/order_entity.dart';
import 'package:app_fe_ecomerce/features/order/presentation/bloc/seller_order/seller_order_bloc.dart';
import 'package:app_fe_ecomerce/features/order/presentation/pages/order_detail_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:app_fe_ecomerce/core/common/widgets/app_network_image.dart';

class SellerOrdersPage extends StatefulWidget {
  const SellerOrdersPage({super.key});

  @override
  State<SellerOrdersPage> createState() => _SellerOrdersPageState();
}

class _SellerOrdersPageState extends State<SellerOrdersPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late SellerOrderBloc _bloc;
  final ScrollController _scrollController = ScrollController();

  int _currentPage = 1;
  final int _limit = 10;
  String? _currentStatus;
  bool _isFetchingMore = false;

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
    _bloc = GetIt.I<SellerOrderBloc>();
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
    if (refresh) _currentPage = 1;
    _bloc.add(
      SellerOrdersLoadRequested(
        page: _currentPage,
        limit: _limit,
        status: _currentStatus,
      ),
    );
  }

  void _onScroll() {
    if (_isBottom && !_isFetchingMore) {
      final state = _bloc.state;
      if (state is SellerOrdersLoaded && !state.hasReachedMax) {
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

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    _bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _bloc,
      child: Scaffold(
        backgroundColor: AppColors.inputBackground,
        appBar: AppBar(
          backgroundColor: AppColors.primaryBlue,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            'Đơn hàng',
            style: AppTextStyles.h3.copyWith(color: Colors.white),
          ),
          centerTitle: true,
          bottom: TabBar(
            controller: _tabController,
            isScrollable: true,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            indicatorColor: Colors.white,
            tabs: _tabs.map((tab) => Tab(text: tab['title'])).toList(),
          ),
        ),
        body: BlocConsumer<SellerOrderBloc, SellerOrderState>(
          listener: (context, state) {
            if (state is SellerOrderFailure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: AppColors.error,
                ),
              );
              setState(() {
                _isFetchingMore = false;
              });
            } else if (state is SellerOrdersLoaded) {
              setState(() {
                _isFetchingMore = false;
              });
            } else if (state is SellerOrderStatusUpdated) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Cập nhật trạng thái thành công'),
                  backgroundColor: AppColors.success,
                ),
              );
            }
          },
          builder: (context, state) {
            if (state is SellerOrderLoading && _currentPage == 1) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.primaryBlue),
              );
            }

            if (state is SellerOrdersLoaded) {
              if (state.orders.isEmpty) {
                return _buildEmptyState();
              }

              return RefreshIndicator(
                onRefresh: () async => _loadOrders(refresh: true),
                color: AppColors.primaryBlue,
                child: ListView.builder(
                  controller: _scrollController,
                  padding: EdgeInsets.all(12.w),
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
                    return _buildOrderCard(state.orders[index]);
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
          Icon(Icons.receipt_long, size: 80.sp, color: AppColors.border),
          SizedBox(height: 16.h),
          Text(
            'Chưa có đơn hàng nào',
            style: AppTextStyles.h3.copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderCard(OrderEntity order) {
    final firstItem = (order.items != null && order.items!.isNotEmpty)
        ? order.items!.first
        : null;
    final int itemLength = order.items?.length ?? 0;
    final formatter = NumberFormat('#,###', 'vi_VN');

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OrderDetailPage(orderId: order.id),
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          children: [
            // Header
            Padding(
              padding: EdgeInsets.all(12.w),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Đơn #${order.id}',
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  _buildStatusBadge(order.status),
                ],
              ),
            ),
            const Divider(height: 1),

            // Receiver info
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
              child: Row(
                children: [
                  Icon(
                    Icons.person_outline,
                    size: 16.sp,
                    color: AppColors.textSecondary,
                  ),
                  SizedBox(width: 6.w),
                  Text(
                    '${order.receiverName ?? "N/A"} - ${order.receiverPhone ?? ""}',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 12.sp,
                    ),
                  ),
                ],
              ),
            ),

            // Product preview
            if (firstItem != null)
              Padding(
                padding: EdgeInsets.fromLTRB(12.w, 0, 12.w, 8.h),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4.r),
                      child: (firstItem.image != null && firstItem.image!.isNotEmpty)
                        ? AppNetworkImage(
                            imageUrl: firstItem.image!,
                            width: 48.w,
                            height: 48.w,
                            fit: BoxFit.cover,
                          )
                        : Container(
                            width: 48.w,
                            height: 48.w,
                            color: Colors.grey[200],
                            child: Icon(Icons.image, size: 20.sp, color: Colors.grey),
                          ),
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            firstItem.productName ?? 'Sản phẩm',
                            style: AppTextStyles.bodyMedium,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            'x${firstItem.quantity}',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.textSecondary,
                              fontSize: 12.sp,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '${formatter.format(firstItem.price)} đ',
                      style: AppTextStyles.bodyMedium,
                    ),
                  ],
                ),
              ),

            // Footer
            const Divider(height: 1),
            Padding(
              padding: EdgeInsets.all(12.w),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '$itemLength sản phẩm',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 12.sp,
                    ),
                  ),
                  Row(
                    children: [
                      Text('Tổng: ', style: AppTextStyles.bodyMedium),
                      Text(
                        '${formatter.format(order.totalAmount ?? 0)} đ',
                        style: AppTextStyles.bodyLarge.copyWith(
                          color: AppColors.error,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Action buttons for seller
            if (_canUpdateStatus(order.status)) ...[
              const Divider(height: 1),
              Padding(
                padding: EdgeInsets.all(8.w),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: _buildActionButtons(order),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  bool _canUpdateStatus(String? status) {
    return status == 'UNPAID' ||
        status == 'READY_TO_SHIP' ||
        status == 'SHIPPED';
  }

  List<Widget> _buildActionButtons(OrderEntity order) {
    final buttons = <Widget>[];

    // Seller xác nhận đơn COD (chuyển từ UNPAID → READY_TO_SHIP)
    if (order.status == 'UNPAID') {
      buttons.add(
        ElevatedButton.icon(
          onPressed: () => _confirmStatusUpdate(
            order.id,
            'READY_TO_SHIP',
            'Xác nhận đơn hàng COD và chuẩn bị hàng?',
          ),
          icon: Icon(Icons.inventory_2_outlined, size: 16.sp),
          label: const Text('Xác nhận đơn'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange,
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
            textStyle: TextStyle(fontSize: 12.sp),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6.r),
            ),
          ),
        ),
      );
    }

    if (order.status == 'READY_TO_SHIP') {
      buttons.add(
        ElevatedButton.icon(
          onPressed: () => _confirmStatusUpdate(
            order.id,
            'SHIPPED',
            'Xác nhận giao cho vận chuyển?',
          ),
          icon: Icon(Icons.local_shipping_outlined, size: 16.sp),
          label: const Text('Giao hàng'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryBlue,
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
            textStyle: TextStyle(fontSize: 12.sp),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6.r),
            ),
          ),
        ),
      );
    }

    if (order.status == 'SHIPPED') {
      buttons.add(
        ElevatedButton.icon(
          onPressed: () => _confirmStatusUpdate(
            order.id,
            'COMPLETED',
            'Xác nhận đơn hàng đã giao thành công?',
          ),
          icon: Icon(Icons.check_circle_outline, size: 16.sp),
          label: const Text('Đã giao'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.success,
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
            textStyle: TextStyle(fontSize: 12.sp),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6.r),
            ),
          ),
        ),
      );
    }

    return buttons;
  }

  void _confirmStatusUpdate(int orderId, String newStatus, String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
        title: Text('Xác nhận', style: AppTextStyles.h3),
        content: Text(message, style: AppTextStyles.bodyLarge),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Hủy',
              style: AppTextStyles.bodyLarge.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              _bloc.add(
                SellerOrderStatusUpdateRequested(
                  orderId: orderId,
                  status: newStatus,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBlue,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
            child: const Text('Xác nhận'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String? status) {
    Color bgColor;
    Color textColor;
    String text;

    switch (status) {
      case 'UNPAID':
        bgColor = Colors.orange.shade50;
        textColor = Colors.orange.shade700;
        text = 'Chờ thanh toán';
        break;
      case 'READY_TO_SHIP':
        bgColor = Colors.blue.shade50;
        textColor = Colors.blue.shade700;
        text = 'Chờ lấy hàng';
        break;
      case 'SHIPPED':
        bgColor = Colors.indigo.shade50;
        textColor = Colors.indigo.shade700;
        text = 'Đang giao';
        break;
      case 'COMPLETED':
        bgColor = Colors.green.shade50;
        textColor = Colors.green.shade700;
        text = 'Đã giao';
        break;
      case 'CANCELLED':
        bgColor = Colors.red.shade50;
        textColor = Colors.red.shade700;
        text = 'Đã hủy';
        break;
      case 'TO_RETURN':
        bgColor = Colors.purple.shade50;
        textColor = Colors.purple.shade700;
        text = 'Trả hàng';
        break;
      default:
        bgColor = Colors.grey.shade100;
        textColor = Colors.grey.shade700;
        text = status ?? 'Không rõ';
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(4.r),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: textColor,
          fontSize: 12.sp,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
