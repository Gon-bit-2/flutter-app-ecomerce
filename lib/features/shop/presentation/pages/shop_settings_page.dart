import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:app_fe_ecomerce/injection_container.dart';
import 'package:app_fe_ecomerce/features/common/domain/repositories/common_repository.dart';
import 'package:app_fe_ecomerce/features/shop/presentation/bloc/shop_settings_cubit.dart';
import 'package:app_fe_ecomerce/features/shop/presentation/bloc/shop_settings_state.dart';

class ShopSettingsPage extends StatelessWidget {
  final String shopName;
  final String? shopDescription;
  final String? shopAvatar;

  const ShopSettingsPage({
    super.key,
    required this.shopName,
    this.shopDescription,
    this.shopAvatar,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<ShopSettingsCubit>(),
      child: ShopSettingsView(
        shopName: shopName,
        shopDescription: shopDescription,
        shopAvatar: shopAvatar,
      ),
    );
  }
}

class ShopSettingsView extends StatefulWidget {
  final String shopName;
  final String? shopDescription;
  final String? shopAvatar;

  const ShopSettingsView({
    super.key,
    required this.shopName,
    this.shopDescription,
    this.shopAvatar,
  });

  @override
  State<ShopSettingsView> createState() => _ShopSettingsViewState();
}

class _ShopSettingsViewState extends State<ShopSettingsView> {
  late TextEditingController _shopNameController;
  late TextEditingController _descriptionController;
  String? _avatarUrl;
  bool _isUploadingAvatar = false;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _shopNameController = TextEditingController(text: widget.shopName);
    _descriptionController = TextEditingController(
      text: widget.shopDescription ?? '',
    );
    _avatarUrl = widget.shopAvatar;
  }

  @override
  void dispose() {
    _shopNameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickAvatar() async {
    final image = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 80,
    );
    if (image == null || !mounted) return;

    setState(() => _isUploadingAvatar = true);
    try {
      final commonRepo = GetIt.I<CommonRepository>();
      final result = await commonRepo.uploadFile(image);
      result.fold(
        (failure) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Lỗi tải ảnh: ${failure.message}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        (url) {
          if (mounted) {
            setState(() => _avatarUrl = url);
          }
        },
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi tải ảnh: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isUploadingAvatar = false);
    }
  }

  void _saveSettings() {
    if (_shopNameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Vui lòng nhập tên shop')));
      return;
    }

    context.read<ShopSettingsCubit>().updateShopSettings(
          name: _shopNameController.text.trim(),
          avatar: _avatarUrl,
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ShopSettingsCubit, ShopSettingsState>(
      listener: (context, state) {
        if (state is ShopSettingsSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
          Navigator.pop(context, true);
        } else if (state is ShopSettingsError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      builder: (context, state) {
        final isLoading = state is ShopSettingsLoading;
        return Scaffold(
          appBar: AppBar(
            title: const Text('Thiết lập Shop'),
            centerTitle: true,
          ),
          body: SingleChildScrollView(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar Section
                Center(
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: _isUploadingAvatar ? null : _pickAvatar,
                        child: Stack(
                          children: [
                            CircleAvatar(
                              radius: 50.r,
                              backgroundColor: Colors.blue.shade50,
                              backgroundImage:
                                  _avatarUrl != null && _avatarUrl!.isNotEmpty
                                      ? CachedNetworkImageProvider(_avatarUrl!)
                                      : null,
                              child:
                                  _avatarUrl == null || _avatarUrl!.isEmpty
                                      ? Icon(
                                          Icons.storefront,
                                          size: 50.r,
                                          color: Colors.blue,
                                        )
                                      : null,
                            ),
                            if (_isUploadingAvatar)
                              Positioned.fill(
                                child: CircleAvatar(
                                  radius: 50.r,
                                  backgroundColor: Colors.black38,
                                  child: const CircularProgressIndicator(
                                    color: Colors.white,
                                  ),
                                ),
                              )
                            else
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: Container(
                                  padding: EdgeInsets.all(6.w),
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF1A94FF),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.camera_alt,
                                    size: 16.sp,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        'Nhấn để đổi ảnh shop',
                        style: TextStyle(fontSize: 12.sp, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 32.h),

                // Shop Name Field
                Text(
                  'Tên shop',
                  style:
                      TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
                ),
                SizedBox(height: 8.h),
                TextField(
                  controller: _shopNameController,
                  decoration: InputDecoration(
                    hintText: 'Nhập tên shop',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 12.h,
                    ),
                  ),
                  maxLength: 100,
                ),
                SizedBox(height: 24.h),

                // Description Field
                Text(
                  'Mô tả shop',
                  style:
                      TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
                ),
                SizedBox(height: 8.h),
                TextField(
                  controller: _descriptionController,
                  decoration: InputDecoration(
                    hintText: 'Nhập mô tả chi tiết về shop của bạn',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 12.h,
                    ),
                  ),
                  maxLines: 4,
                  maxLength: 500,
                ),
                SizedBox(height: 32.h),

                // Info Section
                Container(
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ℹ️ Thông tin chung',
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.blue.shade900,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        '• Tên shop sẽ được hiển thị cho khách hàng trên trang sản phẩm\n'
                        '• Mô tả shop giúp khách hàng hiểu rõ hơn về shop của bạn\n'
                        '• Hình ảnh shop nên là logo hoặc ảnh đại diện chuyên nghiệp\n'
                        '• Cập nhật thường xuyên để tăng độ tin cậy của khách',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.blue.shade800,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 32.h),

                // Save Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: (isLoading || _isUploadingAvatar)
                        ? null
                        : _saveSettings,
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                      backgroundColor: Colors.blue,
                      disabledBackgroundColor: Colors.grey.shade300,
                    ),
                    child: isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        : Text(
                            'Lưu thay đổi',
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
