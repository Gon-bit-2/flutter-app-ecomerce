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
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        title: Text('Xóa danh mục', style: AppTextStyles.h3.copyWith(fontWeight: FontWeight.w700)),
        content: Text(
          'Bạn có chắc chắn muốn xóa danh mục "$categoryName"?\n\nHành động này không thể hoàn tác.',
          style: AppTextStyles.bodyLarge,
        ),
        actionsPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(
              'Hủy',
              style: AppTextStyles.bodyLarge.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
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
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
            ),
            child: const Text('Xóa', style: TextStyle(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50, // Sạch sẽ và hiện đại hơn
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.title ?? (widget.isAdmin ? 'Quản lý danh mục' : 'Danh mục'),
          style: AppTextStyles.h3.copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: AppColors.border.withOpacity(0.3), height: 1),
        ),
      ),
      floatingActionButton: widget.isAdmin
          ? FloatingActionButton.extended(
              onPressed: _navigateToAdd,
              backgroundColor: AppColors.primaryBlue,
              foregroundColor: Colors.white,
              icon: const Icon(Icons.add_rounded),
              label: const Text('Thêm danh mục', style: TextStyle(fontWeight: FontWeight.w600)),
              elevation: 4,
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
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
              ),
            );
          }
          if (state is CategoryOperationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.success,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
                duration: const Duration(seconds: 1),
              ),
            );
            _loadCategories();
          }
        },
        builder: (context, state) {
          if (state is CategoryLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primaryBlue),
            );
          }

          if (state is CategoryLoaded) {
            final categories = state.categories;

            if (categories.isEmpty) {
              return _buildEmpty();
            }

            return RefreshIndicator(
              onRefresh: () async => _loadCategories(),
              color: AppColors.primaryBlue,
              backgroundColor: Colors.white,
              child: GridView.builder(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h).copyWith(bottom: 100.h),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3, // Giảm xuống 3 cột để thẻ to và rõ ràng hơn
                  crossAxisSpacing: 16.w,
                  mainAxisSpacing: 16.h,
                  childAspectRatio: widget.isAdmin ? 0.75 : 0.85,
                ),
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final category = categories[index];
                  return CategoryItemWidget(
                    category: category,
                    isAdmin: widget.isAdmin,
                    onTap: () {
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

          return const Center(
            child: CircularProgressIndicator(color: AppColors.primaryBlue),
          );
        },
      ),
    );
  }

  Widget _buildEmpty() {
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
            child: Icon(Icons.category_rounded, size: 64.sp, color: AppColors.primaryBlue.withOpacity(0.5)),
          ),
          SizedBox(height: 24.h),
          Text(
            'Chưa có danh mục nào',
            style: AppTextStyles.h3.copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8.h),
          Text(
            widget.isAdmin
                ? 'Nhấn nút "+" ở góc dưới để thêm danh mục mới'
                : 'Danh mục sẽ được hiển thị tại đây',
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
          if (widget.isAdmin) ...[
            SizedBox(height: 32.h),
            ElevatedButton.icon(
              onPressed: _navigateToAdd,
              icon: const Icon(Icons.add_rounded),
              label: const Text('Thêm danh mục đầu tiên', style: TextStyle(fontWeight: FontWeight.w600)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.r),
                ),
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 14.h),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
