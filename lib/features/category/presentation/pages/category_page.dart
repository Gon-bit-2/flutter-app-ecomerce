import 'package:app_fe_ecomerce/core/styles/app_colors.dart';
import 'package:app_fe_ecomerce/core/styles/app_text_styles.dart';
import 'package:app_fe_ecomerce/features/category/domain/entities/category.dart';
import 'package:app_fe_ecomerce/features/category/presentation/bloc/category/category_bloc.dart';
import 'package:app_fe_ecomerce/features/category/presentation/pages/add_edit_category_page.dart';
import 'package:app_fe_ecomerce/features/category/presentation/widgets/category_item_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CategoryPage extends StatelessWidget {
  final int? parentCategoryId;
  final String? title;
  final bool isAdmin;

  const CategoryPage({
    super.key,
    this.parentCategoryId,
    this.title,
    this.isAdmin = false,
  });

  @override
  Widget build(BuildContext context) {
    return CategoryView(
      parentCategoryId: parentCategoryId,
      title: title,
      isAdmin: isAdmin,
    );
  }
}

class CategoryView extends StatefulWidget {
  final int? parentCategoryId;
  final String? title;
  final bool isAdmin;

  const CategoryView({
    super.key,
    this.parentCategoryId,
    this.title,
    this.isAdmin = false,
  });

  @override
  State<CategoryView> createState() => _CategoryViewState();
}

class _CategoryViewState extends State<CategoryView> {
  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  void _loadCategories() {
    context.read<CategoryBloc>().add(
      CategoryLoadRequested(parentCategoryId: widget.parentCategoryId),
    );
  }

  void _navigateToAdd() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: context.read<CategoryBloc>(),
          child: AddEditCategoryPage(parentCategoryId: widget.parentCategoryId),
        ),
      ),
    );
    if (result == true) _loadCategories();
  }

  void _navigateToEdit(CategoryEntity category) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: context.read<CategoryBloc>(),
          child: AddEditCategoryPage(category: category),
        ),
      ),
    );
    if (result == true) _loadCategories();
  }

  void _confirmDelete(int categoryId, String categoryName) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        title: Text('Xóa danh mục', style: AppTextStyles.h3),
        content: Text(
          'Bạn có chắc chắn muốn xóa danh mục "$categoryName"?\n\nHành động này không thể hoàn tác.',
          style: AppTextStyles.bodyLarge,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(
              'Hủy',
              style: AppTextStyles.bodyLarge.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<CategoryBloc>().add(CategoryDeleted(id: categoryId));
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
          widget.title ?? (widget.isAdmin ? 'Quản lý danh mục' : 'Danh mục'),
          style: AppTextStyles.h3.copyWith(color: Colors.white),
        ),
        centerTitle: true,
      ),
      floatingActionButton: widget.isAdmin
          ? FloatingActionButton.extended(
              onPressed: _navigateToAdd,
              backgroundColor: AppColors.primaryBlue,
              foregroundColor: Colors.white,
              icon: const Icon(Icons.add),
              label: const Text('Thêm'),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.r),
              ),
            )
          : null,
      body: BlocConsumer<CategoryBloc, CategoryState>(
        listener: (context, state) {
          if (state is CategoryFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
              ),
            );
          }
          if (state is CategoryOperationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.success,
                duration: const Duration(seconds: 1),
              ),
            );
            // Reload danh sách sau thao tác CRUD
            _loadCategories();
          }
        },
        builder: (context, state) {
          // Đang tải
          if (state is CategoryLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primaryBlue),
            );
          }

          // Tải thành công
          if (state is CategoryLoaded) {
            final categories = state.categories;

            if (categories.isEmpty) {
              return _buildEmpty();
            }

            return RefreshIndicator(
              onRefresh: () async => _loadCategories(),
              color: AppColors.primaryBlue,
              child: GridView.builder(
                padding: EdgeInsets.fromLTRB(16.w, 16.w, 16.w, 80.h),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  crossAxisSpacing: 12.w,
                  mainAxisSpacing: 12.h,
                  childAspectRatio: widget.isAdmin ? 0.7 : 0.8,
                ),
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final category = categories[index];
                  return CategoryItemWidget(
                    category: category,
                    isAdmin: widget.isAdmin,
                    onTap: () {
                      // Điều hướng vào xem danh mục con
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => BlocProvider.value(
                            value: context.read<CategoryBloc>(),
                            child: CategoryPage(
                              parentCategoryId: category.id,
                              title: category.name,
                              isAdmin: widget.isAdmin,
                            ),
                          ),
                        ),
                      );
                    },
                    onEdit: () => _navigateToEdit(category),
                    onDelete: () => _confirmDelete(category.id, category.name),
                  );
                },
              ),
            );
          }

          // Mặc định: Trạng thái ban đầu
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primaryBlue),
          );
        },
      ),
    );
  }

  // Widget danh mục trống
  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.category_outlined, size: 80.sp, color: AppColors.border),
          SizedBox(height: 16.h),
          Text(
            'Chưa có danh mục nào',
            style: AppTextStyles.h3.copyWith(color: AppColors.textSecondary),
          ),
          SizedBox(height: 8.h),
          Text(
            widget.isAdmin
                ? 'Nhấn nút "+" để thêm danh mục mới'
                : 'Danh mục sẽ được hiển thị tại đây',
            style: AppTextStyles.bodyMedium,
          ),
          if (widget.isAdmin) ...[
            SizedBox(height: 24.h),
            ElevatedButton.icon(
              onPressed: _navigateToAdd,
              icon: const Icon(Icons.add),
              label: const Text('Thêm danh mục đầu tiên'),
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
        ],
      ),
    );
  }
}
