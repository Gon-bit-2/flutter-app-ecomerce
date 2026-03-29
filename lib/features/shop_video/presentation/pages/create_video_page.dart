import 'dart:typed_data';
import 'package:app_fe_ecomerce/core/styles/app_colors.dart';
import 'package:app_fe_ecomerce/core/styles/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get_it/get_it.dart';

import '../bloc/seller_video/seller_video_bloc.dart';
import '../bloc/seller_video/seller_video_event.dart';
import '../bloc/seller_video/seller_video_state.dart';
import '../../../product/domain/entities/product.dart';
import '../../../product/presentation/pages/my_products_page.dart';

class CreateVideoPage extends StatelessWidget {
  const CreateVideoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<SellerVideoBloc>(
      create: (context) => GetIt.I<SellerVideoBloc>(),
      child: const CreateVideoView(),
    );
  }
}

class CreateVideoView extends StatefulWidget {
  const CreateVideoView({super.key});

  @override
  State<CreateVideoView> createState() => _CreateVideoViewState();
}

class _CreateVideoViewState extends State<CreateVideoView> {
  Uint8List? _videoBytes;
  String? _videoFileName;
  int? _videoFileSize;
  final TextEditingController _captionController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  Product? _selectedProduct;

  Future<void> _pickVideo() async {
    final XFile? video = await _picker.pickVideo(source: ImageSource.gallery);
    if (video != null) {
      final bytes = await video.readAsBytes();
      setState(() {
        _videoBytes = bytes;
        _videoFileName = video.name;
        _videoFileSize = bytes.length;
      });
    }
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  void _submit() {
    if (_videoBytes == null || _videoFileName == null) return;

    context.read<SellerVideoBloc>().add(
      CreateSellerVideoEvent(
        videoBytes: _videoBytes!,
        fileName: _videoFileName!,
        caption: _captionController.text.isNotEmpty
            ? _captionController.text
            : null,
        productIds: _selectedProduct != null ? [_selectedProduct!.id] : null,
      ),
    );
  }

  @override
  void dispose() {
    _captionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SellerVideoBloc, SellerVideoState>(
      listener: (context, state) {
        if (state is CreateSellerVideoSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Đăng video thành công!'),
              backgroundColor: AppColors.success,
            ),
          );
          Navigator.pop(context);
        } else if (state is SellerVideoError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Lỗi: ${state.message}'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      },
      builder: (context, state) {
        final isLoading = state is SellerVideoActionLoading;

        return Scaffold(
          backgroundColor: AppColors.surface,
          appBar: AppBar(
            backgroundColor: AppColors.primaryBlue,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              'Đăng Video Sản Phẩm',
              style: AppTextStyles.h3.copyWith(color: Colors.white),
            ),
          ),
          body: SingleChildScrollView(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // === Phần chọn video ===
                _buildSectionTitle('Video', isRequired: true),
                SizedBox(height: 8.h),
                GestureDetector(
                  onTap: isLoading ? null : _pickVideo,
                  child: Container(
                    width: double.infinity,
                    height: 200.h,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(
                        color: _videoBytes != null
                            ? AppColors.primaryBlue
                            : AppColors.border,
                        width: _videoBytes != null ? 2 : 1,
                      ),
                    ),
                    child: _videoBytes != null
                        ? _buildVideoPreview()
                        : _buildVideoPlaceholder(),
                  ),
                ),

                SizedBox(height: 24.h),

                // === Mô tả video ===
                _buildSectionTitle('Mô tả video'),
                SizedBox(height: 8.h),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: TextField(
                    controller: _captionController,
                    enabled: !isLoading,
                    maxLines: 4,
                    maxLength: 2000,
                    decoration: InputDecoration(
                      hintText: 'Nhập nội dung mô tả, quảng bá sản phẩm...',
                      hintStyle: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14.sp,
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.all(16.w),
                      counterStyle: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12.sp,
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 24.h),

                // === Gắn sản phẩm ===
                _buildSectionTitle('Gắn sản phẩm liên quan'),
                SizedBox(height: 8.h),
                InkWell(
                  onTap: isLoading
                      ? null
                      : () async {
                          final Product? selected =
                              await Navigator.push<Product?>(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  const MyProductsPage(isSelectionMode: true),
                            ),
                          );
                          if (selected != null) {
                            setState(() {
                              _selectedProduct = selected;
                            });
                          }
                        },
                  borderRadius: BorderRadius.circular(12.r),
                  child: Container(
                    padding: EdgeInsets.all(16.w),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _selectedProduct != null
                              ? Icons.shopping_bag
                              : Icons.shopping_bag_outlined,
                          color: _selectedProduct != null
                              ? AppColors.primaryBlue
                              : AppColors.textSecondary,
                          size: 24.sp,
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _selectedProduct != null
                                    ? _selectedProduct!.name
                                    : 'Chạm để chọn sản phẩm',
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  color: _selectedProduct != null
                                      ? Colors.black
                                      : AppColors.textSecondary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              if (_selectedProduct != null)
                                Text(
                                  'Chạm để thay đổi',
                                  style: TextStyle(
                                    fontSize: 11.sp,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        if (_selectedProduct != null)
                          IconButton(
                            icon: Icon(Icons.close,
                                size: 18.sp, color: AppColors.textSecondary),
                            onPressed: () {
                              setState(() {
                                _selectedProduct = null;
                              });
                            },
                          )
                        else
                          Icon(
                            Icons.arrow_forward_ios,
                            size: 14.sp,
                            color: AppColors.textSecondary,
                          ),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: 32.h),

                // === Lưu ý ===
                Container(
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.info_outline,
                          size: 16.sp, color: AppColors.warning),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: Text(
                          'Hỗ trợ MP4, WebM, AVI, MKV. Dung lượng tối đa 100MB.',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: AppColors.warning,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 24.h),

                // === Nút đăng ===
                SizedBox(
                  width: double.infinity,
                  height: 48.h,
                  child: ElevatedButton(
                    onPressed: (isLoading || _videoBytes == null)
                        ? null
                        : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: AppColors.primaryBlue.withOpacity(0.4),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    child: isLoading
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              ),
                              SizedBox(width: 12.w),
                              const Text('Đang tải lên...'),
                            ],
                          )
                        : Text(
                            'ĐĂNG VIDEO',
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),

                SizedBox(height: 20.h),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSectionTitle(String title, {bool isRequired = false}) {
    return Row(
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 15.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        if (isRequired)
          Text(
            ' *',
            style: TextStyle(
              fontSize: 15.sp,
              color: AppColors.error,
            ),
          ),
      ],
    );
  }

  Widget _buildVideoPlaceholder() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: AppColors.secondary,
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.video_library_rounded,
            size: 36.sp,
            color: AppColors.primaryBlue,
          ),
        ),
        SizedBox(height: 12.h),
        Text(
          'Chạm để chọn video',
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          'Từ thư viện • MP4, WebM, AVI',
          style: TextStyle(
            fontSize: 12.sp,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildVideoPreview() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: EdgeInsets.all(14.w),
          decoration: BoxDecoration(
            color: AppColors.success.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.check_circle,
            size: 36.sp,
            color: AppColors.success,
          ),
        ),
        SizedBox(height: 12.h),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Text(
            _videoFileName ?? 'video',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          _videoFileSize != null ? _formatFileSize(_videoFileSize!) : '',
          style: TextStyle(
            fontSize: 12.sp,
            color: AppColors.textSecondary,
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          'Chạm để chọn video khác',
          style: TextStyle(
            fontSize: 11.sp,
            color: AppColors.primaryBlue,
          ),
        ),
      ],
    );
  }
}
