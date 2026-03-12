import 'package:app_fe_ecomerce/core/styles/app_colors.dart';
import 'package:app_fe_ecomerce/core/styles/app_text_styles.dart';
import 'package:app_fe_ecomerce/features/product/domain/entities/product.dart';
import 'package:app_fe_ecomerce/features/product/presentation/bloc/my_products/my_products_bloc.dart';
import 'package:app_fe_ecomerce/features/product/presentation/pages/add_product_page.dart';
import 'package:app_fe_ecomerce/features/auth/presentation/bloc/auth/auth_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';

class MyProductsPage extends StatefulWidget {
  const MyProductsPage({super.key});

  @override
  State<MyProductsPage> createState() => _MyProductsPageState();
}

class _MyProductsPageState extends State<MyProductsPage> {
  late MyProductsBloc _bloc;
  final ScrollController _scrollController = ScrollController();
  int _currentPage = 1;
  final int _limit = 10;
  bool _isFetchingMore = false;

  int get _userId {
    try {
      final authState = context.read<AuthBloc>().state;
      if (authState is AuthSuccess) {
        return authState.user.id;
      }
    } catch (_) {}
    return 0;
  }

  @override
  void initState() {
    super.initState();
    _bloc = GetIt.I<MyProductsBloc>();
    _scrollController.addListener(_onScroll);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Chỉ load lần đầu
    if (_currentPage == 1 && _bloc.state is MyProductsInitial) {
      _loadProducts(refresh: true);
    }
  }

  void _loadProducts({bool refresh = false}) {
    if (refresh) _currentPage = 1;
    _bloc.add(
      MyProductsLoadRequested(
        page: _currentPage,
        limit: _limit,
        createdById: _userId,
      ),
    );
  }

  void _onScroll() {
    if (_isBottom && !_isFetchingMore) {
      final state = _bloc.state;
      if (state is MyProductsLoaded && !state.hasReachedMax) {
        _isFetchingMore = true;
        _currentPage++;
        _loadProducts();
      }
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll - 200);
  }

  void _navigateToAdd() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const AddProductPage()),
    );
    if (result == true) _loadProducts(refresh: true);
  }

  void _navigateToEdit(Product product) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => AddProductPage(product: product)),
    );
    if (result == true) _loadProducts(refresh: true);
  }

  void _confirmDelete(Product product) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        title: Text('Xóa sản phẩm', style: AppTextStyles.h3),
        content: Text(
          'Bạn có chắc chắn muốn xóa "${product.name}"?\n\nHành động này không thể hoàn tác.',
          style: AppTextStyles.bodyLarge,
        ),
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
              _bloc.add(MyProductsDeleteRequested(productId: product.id));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
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
            'Sản phẩm của tôi',
            style: AppTextStyles.h3.copyWith(color: Colors.white),
          ),
          centerTitle: true,
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _navigateToAdd,
          backgroundColor: AppColors.primaryBlue,
          child: const Icon(Icons.add, color: Colors.white),
        ),
        body: BlocConsumer<MyProductsBloc, MyProductsState>(
          listener: (context, state) {
            if (state is MyProductsFailure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: AppColors.error,
                ),
              );
              _isFetchingMore = false;
            } else if (state is MyProductsLoaded) {
              _isFetchingMore = false;
            } else if (state is MyProductsDeleteSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Xóa sản phẩm thành công'),
                  backgroundColor: AppColors.success,
                ),
              );
            }
          },
          builder: (context, state) {
            if (state is MyProductsLoading && _currentPage == 1) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.primaryBlue),
              );
            }

            if (state is MyProductsLoaded) {
              if (state.products.isEmpty) {
                return _buildEmpty();
              }

              return RefreshIndicator(
                onRefresh: () async => _loadProducts(refresh: true),
                color: AppColors.primaryBlue,
                child: ListView.builder(
                  controller: _scrollController,
                  padding: EdgeInsets.all(12.w),
                  itemCount: state.hasReachedMax
                      ? state.products.length
                      : state.products.length + 1,
                  itemBuilder: (context, index) {
                    if (index >= state.products.length) {
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
                    return _buildProductCard(state.products[index]);
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

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inventory_2_outlined,
            size: 80.sp,
            color: AppColors.border,
          ),
          SizedBox(height: 16.h),
          Text(
            'Chưa có sản phẩm nào',
            style: AppTextStyles.h3.copyWith(color: AppColors.textSecondary),
          ),
          SizedBox(height: 8.h),
          Text(
            'Nhấn nút "+" để thêm sản phẩm mới',
            style: AppTextStyles.bodyMedium,
          ),
          SizedBox(height: 24.h),
          ElevatedButton.icon(
            onPressed: _navigateToAdd,
            icon: const Icon(Icons.add),
            label: const Text('Thêm sản phẩm'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBlue,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(Product product) {
    final formatter = NumberFormat('#,###', 'vi_VN');
    final firstImage = product.images.isNotEmpty ? product.images.first : null;

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          // Product info row
          Padding(
            padding: EdgeInsets.all(12.w),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image
                ClipRRect(
                  borderRadius: BorderRadius.circular(8.r),
                  child: firstImage != null
                      ? Image.network(
                          firstImage,
                          width: 80.w,
                          height: 80.w,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _imagePlaceholder(),
                        )
                      : _imagePlaceholder(),
                ),
                SizedBox(width: 12.w),
                // Name, price, stock
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        style: AppTextStyles.bodyLarge.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 6.h),
                      Text(
                        '${formatter.format(product.basePrice)} đ',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.error,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (product.virtualPrice != null &&
                          product.virtualPrice! > product.basePrice)
                        Text(
                          '${formatter.format(product.virtualPrice)} đ',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                            fontSize: 12.sp,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                      SizedBox(height: 4.h),
                      Row(
                        children: [
                          Icon(
                            Icons.inventory,
                            size: 14.sp,
                            color: AppColors.textSecondary,
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            'SKU: ${product.skus.length}',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.textSecondary,
                              fontSize: 12.sp,
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Icon(
                            Icons.storage,
                            size: 14.sp,
                            color: AppColors.textSecondary,
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            'Kho: ${_totalStock(product)}',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.textSecondary,
                              fontSize: 12.sp,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Action buttons
          Container(
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: AppColors.border)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => _navigateToEdit(product),
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 10.h),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.edit_outlined,
                            size: 18.sp,
                            color: AppColors.primaryBlue,
                          ),
                          SizedBox(width: 6.w),
                          Text(
                            'Sửa',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.primaryBlue,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Container(width: 1, height: 36.h, color: AppColors.border),
                Expanded(
                  child: InkWell(
                    onTap: () => _confirmDelete(product),
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 10.h),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.delete_outline,
                            size: 18.sp,
                            color: AppColors.error,
                          ),
                          SizedBox(width: 6.w),
                          Text(
                            'Xóa',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.error,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _imagePlaceholder() {
    return Container(
      width: 80.w,
      height: 80.w,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Icon(Icons.image_outlined, size: 32.sp, color: Colors.grey[400]),
    );
  }

  int _totalStock(Product product) {
    return product.skus.fold(0, (sum, sku) => sum + sku.stock);
  }
}
