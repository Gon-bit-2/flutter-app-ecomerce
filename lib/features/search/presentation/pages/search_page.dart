import 'package:app_fe_ecomerce/core/styles/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../injection_container.dart';
import '../../../home/presentation/widgets/product_card.dart';
import '../bloc/search_bloc.dart';
import '../bloc/search_event.dart';
import '../bloc/search_state.dart';
import '../../../category/presentation/bloc/category/category_bloc.dart';

class SearchPage extends StatelessWidget {
  final String? initialCategoryId;
  
  const SearchPage({super.key, this.initialCategoryId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) {
        final bloc = getIt<SearchBloc>()..add(SearchInitRequested());
        if (initialCategoryId != null) {
          // Tự động filter category ngay khi mở trang
          // Chúng ta dùng future delay để tránh bị ghi đè bởi SearchInitRequested 
          Future.microtask(() => 
            bloc.add(SearchFilterChanged(categoryId: initialCategoryId))
          );
        }
        return bloc;
      },
      child: const _SearchPageBody(),
    );
  }
}

class _SearchPageBody extends StatefulWidget {
  const _SearchPageBody();

  @override
  State<_SearchPageBody> createState() => _SearchPageBodyState();
}

class _SearchPageBodyState extends State<_SearchPageBody> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_isBottom) {
      context.read<SearchBloc>().add(SearchLoadMore());
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.9);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: AppColors.primaryBlue,
        elevation: 0,
        titleSpacing: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white, size: 24.sp),
          onPressed: () => Navigator.pop(context),
        ),
        title: Container(
          height: 36.h,
          margin: EdgeInsets.only(right: 12.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20.r),
          ),
          child: TextField(
            controller: _searchController,
            autofocus: true,
            style: TextStyle(fontSize: 14.sp),
            decoration: InputDecoration(
              hintText: 'Tìm kiếm trên Tiki',
              hintStyle: TextStyle(color: Colors.grey, fontSize: 14.sp),
              border: InputBorder.none,
              prefixIcon: Icon(Icons.search, color: Colors.grey, size: 20.sp),
              contentPadding: EdgeInsets.symmetric(
                vertical: 8.h,
              ),
              suffixIcon: BlocBuilder<SearchBloc, SearchState>(
                builder: (context, state) {
                  if (_searchController.text.isNotEmpty) {
                    return IconButton(
                      icon: Icon(Icons.clear, size: 18.sp, color: Colors.grey),
                      onPressed: () {
                        _searchController.clear();
                        context.read<SearchBloc>().add(SearchCleared());
                      },
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
            onChanged: (query) {
              context.read<SearchBloc>().add(SearchQueryChanged(query));
            },
            onSubmitted: (query) {
              if (query.trim().isNotEmpty) {
                 context.read<SearchBloc>().add(SearchQueryChanged(query));
              }
            },
          ),
        ),
      ),
      body: Column(
        children: [
          _buildFilterBar(),
          Expanded(
            child: BlocConsumer<SearchBloc, SearchState>(
              listener: (context, state) {
                if (state is SearchLoaded && _searchController.text != state.query) {
                  // If history item selected, update text field
                  _searchController.text = state.query;
                  // Move cursor to end
                  _searchController.selection = TextSelection.fromPosition(
                    TextPosition(offset: state.query.length),
                  );
                }
              },
              builder: (context, state) {
                if (state is SearchInitial) {
                  return _buildInitialView(state.history);
                }

                if (state is SearchLoading) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (state is SearchError) {
                  return _buildErrorView(state.message);
                }

                if (state is SearchLoaded) {
                  if (state.products.isEmpty) {
                    return _buildEmptyView();
                  }
                  return _buildResultsView(state);
                }

                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBar() {
    return BlocBuilder<SearchBloc, SearchState>(
      builder: (context, state) {
        if (state is SearchInitial && _searchController.text.isEmpty) {
          return const SizedBox.shrink();
        }
        
        return Container(
          height: 44.h,
          padding: EdgeInsets.symmetric(horizontal: 12.w),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(
              bottom: BorderSide(color: Colors.grey[200]!),
            ),
          ),
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              _buildFilterChip(
                label: 'Giá',
                icon: Icons.keyboard_arrow_down,
                isSelected: state.minPrice != null || state.maxPrice != null,
                onTap: () => _showPriceFilter(context),
              ),
              _buildFilterChip(
                label: _getSortLabel(state.sortBy),
                icon: Icons.swap_vert,
                isSelected: state.sortBy != null,
                onTap: () => _showSortFilter(context),
              ),
              _buildFilterChip(
                label: 'Danh mục',
                icon: Icons.grid_view,
                isSelected: state.categoryId != null,
                onTap: () => _showCategoryFilter(context),
              ),
            ],
          ),
        );
      },
    );
  }

  String _getSortLabel(String? sortBy) {
    switch (sortBy) {
      case 'price_asc': return 'Giá thấp';
      case 'price_desc': return 'Giá cao';
      case 'newest': return 'Mới nhất';
      case 'best_seller': return 'Bán chạy';
      default: return 'Sắp xếp';
    }
  }

  Widget _buildFilterChip({
    required String label,
    IconData? icon,
    bool isSelected = false,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(right: 8.w, top: 8.h, bottom: 8.h),
        padding: EdgeInsets.symmetric(horizontal: 12.w),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.secondary : Colors.grey[100],
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: isSelected ? AppColors.primaryBlue : Colors.transparent,
          ),
        ),
        child: Row(
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 13.sp,
                color: isSelected ? AppColors.primaryBlue : Colors.black87,
                fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
              ),
            ),
            if (icon != null) ...[
              SizedBox(width: 4.w),
              Icon(
                icon,
                size: 16.sp,
                color: isSelected ? AppColors.primaryBlue : Colors.grey[600],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInitialView(List<String> history) {
    if (history.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search, size: 80.sp, color: Colors.grey[200]),
            SizedBox(height: 16.h),
            Text(
              'Tìm kiếm hàng ngàn sản phẩm',
              style: TextStyle(color: Colors.grey, fontSize: 14.sp),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Lịch sử tìm kiếm',
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () {
                  context.read<SearchBloc>().add(SearchHistoryCleared());
                },
                child: Text(
                  'Xóa tất cả',
                  style: TextStyle(color: AppColors.primaryBlue, fontSize: 13.sp),
                ),
              ),
            ],
          ),
          Wrap(
            spacing: 8.w,
            runSpacing: 0,
            children: history.map((query) => InputChip(
              label: Text(query, style: TextStyle(fontSize: 13.sp)),
              backgroundColor: Colors.grey[100],
              shape: const StadiumBorder(),
              side: BorderSide.none,
              onPressed: () {
                context.read<SearchBloc>().add(SearchHistorySelected(query));
              },
              onDeleted: () {
                context.read<SearchBloc>().add(SearchHistoryDeleted(query));
              },
              deleteIcon: Icon(Icons.close, size: 14.sp),
            )).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 80.sp,
            color: Colors.grey[300],
          ),
          SizedBox(height: 16.h),
          Text(
            'Rất tiếc, không tìm thấy sản phẩm phù hợp',
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey[800],
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Hãy thử điều chỉnh bộ lọc hoặc từ khóa tìm kiếm',
            style: TextStyle(
              fontSize: 13.sp,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorView(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 60.sp, color: Colors.red[300]),
          SizedBox(height: 16.h),
          Text(
            message,
            style: TextStyle(fontSize: 14.sp, color: Colors.grey[700]),
            textAlign: TextAlign.center,
          ),
          TextButton(
            onPressed: () {
              final query = _searchController.text;
              if (query.isNotEmpty) {
                context.read<SearchBloc>().add(SearchQueryChanged(query));
              }
            },
            child: const Text('Thử lại'),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsView(SearchLoaded state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 8.h),
          child: Row(
            children: [
              Text(
                'Tìm thấy ',
                style: TextStyle(fontSize: 13.sp, color: Colors.grey[600]),
              ),
              Text(
                '${state.totalCount}',
                style: TextStyle(
                  fontSize: 13.sp,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                ' sản phẩm',
                style: TextStyle(fontSize: 13.sp, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
        Expanded(
          child: GridView.builder(
            controller: _scrollController,
            padding: EdgeInsets.symmetric(horizontal: 12.w),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12.h,
              crossAxisSpacing: 12.w,
              childAspectRatio: 0.65,
            ),
            itemCount: state.products.length + (state.isLoadingMore ? 2 : 0),
            itemBuilder: (context, index) {
              if (index >= state.products.length) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                );
              }
              return ProductCard(product: state.products[index]);
            },
          ),
        ),
      ],
    );
  }

  void _showPriceFilter(BuildContext context) {
    final bloc = context.read<SearchBloc>();
    final state = bloc.state;
    double? minPrice = state.minPrice;
    double? maxPrice = state.maxPrice;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 16.w,
          right: 16.w,
          top: 16.h,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Khoảng giá',
              style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16.h),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: 'Từ',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12.w),
                    ),
                    onChanged: (val) => minPrice = double.tryParse(val),
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: TextField(
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: 'Đến',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12.w),
                    ),
                    onChanged: (val) => maxPrice = double.tryParse(val),
                  ),
                ),
              ],
            ),
            SizedBox(height: 24.h),
            SizedBox(
              width: double.infinity,
              height: 44.h,
              child: ElevatedButton(
                onPressed: () {
                  bloc.add(SearchFilterChanged(
                    minPrice: minPrice,
                    maxPrice: maxPrice,
                    sortBy: state.sortBy,
                    categoryId: state.categoryId,
                  ));
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                ),
                child: const Text(
                  'Áp dụng',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
            SizedBox(height: 16.h),
          ],
        ),
      ),
    );
  }

  void _showSortFilter(BuildContext context) {
    final bloc = context.read<SearchBloc>();
    final state = bloc.state;

    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
      ),
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildSortOption(context, bloc, 'Phổ biến', null, state.sortBy == null),
          _buildSortOption(context, bloc, 'Bán chạy', 'best_seller', state.sortBy == 'best_seller'),
          _buildSortOption(context, bloc, 'Mới nhất', 'newest', state.sortBy == 'newest'),
          _buildSortOption(context, bloc, 'Giá thấp đến cao', 'price_asc', state.sortBy == 'price_asc'),
          _buildSortOption(context, bloc, 'Giá cao đến thấp', 'price_desc', state.sortBy == 'price_desc'),
          SizedBox(height: 16.h),
        ],
      ),
    );
  }

  Widget _buildSortOption(
    BuildContext context,
    SearchBloc bloc,
    String label,
    String? value,
    bool isSelected,
  ) {
    return ListTile(
      title: Text(
        label,
        style: TextStyle(
          color: isSelected ? AppColors.primaryBlue : Colors.black87,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      trailing: isSelected ? const Icon(Icons.check, color: AppColors.primaryBlue) : null,
      onTap: () {
        bloc.add(SearchFilterChanged(
          sortBy: value,
          minPrice: bloc.state.minPrice,
          maxPrice: bloc.state.maxPrice,
          categoryId: bloc.state.categoryId,
        ));
        Navigator.pop(context);
      },
    );
  }

  void _showCategoryFilter(BuildContext context) {
    final searchBloc = context.read<SearchBloc>();
    final searchState = searchBloc.state;
    
    final categoryBloc = context.read<CategoryBloc>();
    if (categoryBloc.state is CategoryInitial || categoryBloc.state is CategoryFailure) {
      categoryBloc.add(const CategoryLoadRequested());
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.5,
        minChildSize: 0.3,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => Column(
          children: [
            Padding(
              padding: EdgeInsets.all(16.w),
              child: Text(
                'Chọn danh mục',
                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: BlocBuilder<CategoryBloc, CategoryState>(
                builder: (context, catState) {
                  if (catState is CategoryLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  
                  if (catState is CategoryLoaded) {
                    final categories = catState.categories;
                    return ListView(
                      controller: scrollController,
                      children: [
                        ListTile(
                          title: Text(
                            'Tất cả danh mục',
                            style: TextStyle(
                              color: searchState.categoryId == null ? AppColors.primaryBlue : Colors.black87,
                              fontWeight: searchState.categoryId == null ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                          trailing: searchState.categoryId == null ? const Icon(Icons.check, color: AppColors.primaryBlue) : null,
                          onTap: () {
                            searchBloc.add(SearchFilterChanged(
                              categoryId: null,
                              minPrice: searchState.minPrice,
                              maxPrice: searchState.maxPrice,
                              sortBy: searchState.sortBy,
                            ));
                            Navigator.pop(context);
                          },
                        ),
                        ...categories.map((cat) {
                          final isSelected = searchState.categoryId == cat.id.toString();
                          return ListTile(
                            title: Text(
                              cat.name,
                              style: TextStyle(
                                color: isSelected ? AppColors.primaryBlue : Colors.black87,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                            trailing: isSelected ? const Icon(Icons.check, color: AppColors.primaryBlue) : null,
                            onTap: () {
                              searchBloc.add(SearchFilterChanged(
                                categoryId: cat.id.toString(),
                                minPrice: searchState.minPrice,
                                maxPrice: searchState.maxPrice,
                                sortBy: searchState.sortBy,
                              ));
                              Navigator.pop(context);
                            },
                          );
                        }),
                      ],
                    );
                  }
                  
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Không thể tải danh mục'),
                        SizedBox(height: 8.h),
                        ElevatedButton(
                          onPressed: () {
                            categoryBloc.add(const CategoryLoadRequested());
                          },
                          child: const Text('Thử lại'),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
