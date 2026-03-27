import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:app_fe_ecomerce/core/common/widgets/app_network_image.dart';

class ShopSettingsPage extends StatefulWidget {
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
  State<ShopSettingsPage> createState() => _ShopSettingsPageState();
}

class _ShopSettingsPageState extends State<ShopSettingsPage> {
  late TextEditingController _shopNameController;
  late TextEditingController _descriptionController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _shopNameController = TextEditingController(text: widget.shopName);
    _descriptionController = TextEditingController(
      text: widget.shopDescription ?? '',
    );
  }

  @override
  void dispose() {
    _shopNameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _saveSettings() {
    if (_shopNameController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Vui lòng nhập tên shop')));
      return;
    }

    setState(() => _isLoading = true);

    // TODO: Implement API call to update shop settings
    // For now, just simulate saving
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Cập nhật thành công')));
        Navigator.pop(context, {
          'name': _shopNameController.text,
          'description': _descriptionController.text,
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Thiết lập Shop'), centerTitle: true),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Avatar Section
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50.r,
                    backgroundColor: Colors.blue.shade50,
                    child: widget.shopAvatar != null
                        ? AppNetworkImage(imageUrl: widget.shopAvatar!,  fit: BoxFit.cover)
                        : Icon(
                            Icons.storefront,
                            size: 50.r,
                            color: Colors.blue,
                          ),
                  ),
                  SizedBox(height: 12.h),
                  ElevatedButton.icon(
                    onPressed: () {
                      // TODO: Implement image upload
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Tính năng upload ảnh sắp ra mắt'),
                        ),
                      );
                    },
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Thay đổi avatar'),
                  ),
                ],
              ),
            ),
            SizedBox(height: 32.h),

            // Shop Name Field
            Text(
              'Tên shop',
              style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
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
              style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
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
                onPressed: _isLoading ? null : _saveSettings,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  backgroundColor: Colors.blue,
                  disabledBackgroundColor: Colors.grey.shade300,
                ),
                child: _isLoading
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
  }
}
