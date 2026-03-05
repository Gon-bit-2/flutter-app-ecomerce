import 'package:app_fe_ecomerce/core/styles/app_colors.dart';
import 'package:app_fe_ecomerce/core/styles/app_text_styles.dart';
import 'package:app_fe_ecomerce/features/category/domain/entities/category.dart';
import 'package:app_fe_ecomerce/features/category/presentation/bloc/category/category_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Trang thêm/sửa danh mục.
/// - `category != null` → Chế độ sửa (pre-fill dữ liệu)
/// - `category == null` → Chế độ tạo mới
class AddEditCategoryPage extends StatefulWidget {
  final CategoryEntity? category;
  final int? parentCategoryId;

  const AddEditCategoryPage({super.key, this.category, this.parentCategoryId});

  @override
  State<AddEditCategoryPage> createState() => _AddEditCategoryPageState();
}

class _AddEditCategoryPageState extends State<AddEditCategoryPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _logoController;

  bool get _isEditing => widget.category != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.category?.name ?? '');
    _logoController = TextEditingController(text: widget.category?.logo ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _logoController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final name = _nameController.text.trim();
    final logo = _logoController.text.trim();

    if (_isEditing) {
      context.read<CategoryBloc>().add(
        CategoryUpdated(
          id: widget.category!.id,
          name: name,
          logo: logo.isNotEmpty ? logo : null,
          parentCategoryId: widget.category!.parentCategoryId,
        ),
      );
    } else {
      context.read<CategoryBloc>().add(
        CategoryCreated(
          name: name,
          logo: logo.isNotEmpty ? logo : null,
          parentCategoryId: widget.parentCategoryId,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CategoryBloc, CategoryState>(
      listener: (context, state) {
        if (state is CategoryOperationSuccess) {
          Navigator.pop(context, true);
        }
        if (state is CategoryFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.error,
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.primaryBlue,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            _isEditing ? 'Sửa danh mục' : 'Thêm danh mục',
            style: AppTextStyles.h3.copyWith(color: Colors.white),
          ),
          centerTitle: true,
          actions: [
            BlocBuilder<CategoryBloc, CategoryState>(
              builder: (context, state) {
                final isLoading = state is CategoryLoading;
                return TextButton(
                  onPressed: isLoading ? null : _submit,
                  child: isLoading
                      ? SizedBox(
                          width: 20.w,
                          height: 20.w,
                          child: const CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          'Lưu',
                          style: AppTextStyles.buttonText.copyWith(
                            fontSize: 16.sp,
                          ),
                        ),
                );
              },
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(20.w),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Tên danh mục
                _buildLabel('Tên danh mục', isRequired: true),
                SizedBox(height: 8.h),
                TextFormField(
                  controller: _nameController,
                  decoration: _inputDecoration(
                    hintText: 'Nhập tên danh mục',
                    prefixIcon: Icons.category_outlined,
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'Vui lòng nhập tên danh mục';
                    }
                    return null;
                  },
                ),

                SizedBox(height: 24.h),

                // Logo URL
                _buildLabel('Logo (URL)', isRequired: false),
                SizedBox(height: 8.h),
                TextFormField(
                  controller: _logoController,
                  decoration: _inputDecoration(
                    hintText: 'https://example.com/logo.png',
                    prefixIcon: Icons.image_outlined,
                  ),
                ),

                SizedBox(height: 16.h),

                // Preview logo
                if (_logoController.text.trim().isNotEmpty) _buildLogoPreview(),

                SizedBox(height: 32.h),

                // Nút submit full-width
                SizedBox(
                  width: double.infinity,
                  height: 50.h,
                  child: BlocBuilder<CategoryBloc, CategoryState>(
                    builder: (context, state) {
                      final isLoading = state is CategoryLoading;
                      return ElevatedButton(
                        onPressed: isLoading ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryBlue,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          elevation: 0,
                        ),
                        child: isLoading
                            ? SizedBox(
                                width: 24.w,
                                height: 24.w,
                                child: const CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Text(
                                _isEditing
                                    ? 'Cập nhật danh mục'
                                    : 'Tạo danh mục',
                                style: AppTextStyles.buttonText,
                              ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text, {bool isRequired = false}) {
    return Row(
      children: [
        Text(
          text,
          style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.w600),
        ),
        if (isRequired)
          Text(
            ' *',
            style: TextStyle(
              color: AppColors.error,
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
      ],
    );
  }

  InputDecoration _inputDecoration({
    required String hintText,
    required IconData prefixIcon,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: AppTextStyles.inputHint,
      prefixIcon: Icon(prefixIcon, color: AppColors.textSecondary, size: 22.sp),
      filled: true,
      fillColor: AppColors.inputBackground,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: const BorderSide(color: AppColors.primaryBlue, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: const BorderSide(color: AppColors.error, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: const BorderSide(color: AppColors.error, width: 1.5),
      ),
      contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
    );
  }

  Widget _buildLogoPreview() {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: AppColors.inputBackground,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8.r),
            child: Image.network(
              _logoController.text.trim(),
              width: 56.w,
              height: 56.w,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                width: 56.w,
                height: 56.w,
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(
                  Icons.broken_image_outlined,
                  color: AppColors.error,
                  size: 28.sp,
                ),
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Text('Xem trước logo', style: AppTextStyles.bodyMedium),
          ),
        ],
      ),
    );
  }
}
