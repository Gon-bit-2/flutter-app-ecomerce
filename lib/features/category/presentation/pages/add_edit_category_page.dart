import 'package:app_fe_ecomerce/core/styles/app_colors.dart';
import 'package:app_fe_ecomerce/core/styles/app_text_styles.dart';
import 'package:app_fe_ecomerce/features/category/domain/entities/category.dart';
import 'package:app_fe_ecomerce/features/category/presentation/bloc/category/category_bloc.dart';
import 'package:app_fe_ecomerce/features/common/domain/repositories/common_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get_it/get_it.dart';
import 'package:image_picker/image_picker.dart';
import 'package:app_fe_ecomerce/core/common/widgets/app_network_image.dart';

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

  String? _logoUrl; // URL ảnh đã upload hoặc ảnh cũ
  bool _isUploadingImage = false;

  bool get _isEditing => widget.category != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.category?.name ?? '');
    _logoUrl = widget.category?.logo;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _pickAndUploadImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 85,
    );
    if (pickedFile == null) return;

    setState(() => _isUploadingImage = true);

    final commonRepo = GetIt.I<CommonRepository>();
    final result = await commonRepo.uploadFile(pickedFile);

    result.fold(
      (failure) {
        setState(() => _isUploadingImage = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Tải ảnh thất bại: ${failure.message}'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      },
      (url) {
        setState(() {
          _logoUrl = url;
          _isUploadingImage = false;
        });
      },
    );
  }

  void _removeImage() {
    setState(() => _logoUrl = null);
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final name = _nameController.text.trim();

    if (_isEditing) {
      context.read<CategoryBloc>().add(
        CategoryUpdated(
          id: widget.category!.id,
          name: name,
          logo: _logoUrl,
          parentCategoryId: widget.category!.parentCategoryId,
        ),
      );
    } else {
      context.read<CategoryBloc>().add(
        CategoryCreated(
          name: name,
          logo: _logoUrl,
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

                // Logo upload
                _buildLabel('Logo', isRequired: false),
                SizedBox(height: 8.h),
                _buildImagePicker(),

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

  Widget _buildImagePicker() {
    if (_isUploadingImage) {
      return Container(
        height: 120.w,
        decoration: BoxDecoration(
          color: AppColors.inputBackground,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: AppColors.border),
        ),
        child: const Center(
          child: CircularProgressIndicator(color: AppColors.primaryBlue),
        ),
      );
    }

    if (_logoUrl != null && _logoUrl!.isNotEmpty) {
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
              child: AppNetworkImage(
                imageUrl: _logoUrl!,
                width: 80.w,
                height: 80.w,
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Logo đã tải lên', style: AppTextStyles.bodyMedium),
                  SizedBox(height: 8.h),
                  Row(
                    children: [
                      _actionButton(
                        icon: Icons.refresh,
                        label: 'Đổi ảnh',
                        onTap: _pickAndUploadImage,
                      ),
                      SizedBox(width: 8.w),
                      _actionButton(
                        icon: Icons.delete_outline,
                        label: 'Xóa',
                        onTap: _removeImage,
                        color: AppColors.error,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return InkWell(
      onTap: _pickAndUploadImage,
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        height: 120.w,
        decoration: BoxDecoration(
          color: AppColors.inputBackground,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: AppColors.border, style: BorderStyle.solid),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.cloud_upload_outlined,
              size: 36.sp,
              color: AppColors.textSecondary,
            ),
            SizedBox(height: 8.h),
            Text(
              'Nhấn để chọn ảnh',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              'JPG, PNG, WEBP (tối đa 5MB)',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
                fontSize: 11.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _actionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color? color,
  }) {
    final c = color ?? AppColors.primaryBlue;
    return InkWell(
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16.sp, color: c),
          SizedBox(width: 4.w),
          Text(
            label,
            style: AppTextStyles.bodyMedium.copyWith(color: c, fontSize: 12.sp),
          ),
        ],
      ),
    );
  }
}
