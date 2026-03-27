import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/styles/app_colors.dart';
import '../../../../core/styles/app_text_styles.dart';
import '../bloc/shop_registration_bloc.dart';
import '../bloc/shop_registration_event.dart';
import '../bloc/shop_registration_state.dart';
import '../../../../injection_container.dart';

class RegisterShopPage extends StatelessWidget {
  const RegisterShopPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<ShopRegistrationBloc>()..add(CheckShopStatus()),
      child: const RegisterShopView(),
    );
  }
}

class RegisterShopView extends StatefulWidget {
  const RegisterShopView({super.key});

  @override
  State<RegisterShopView> createState() => _RegisterShopViewState();
}

class _RegisterShopViewState extends State<RegisterShopView> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<ShopRegistrationBloc>().add(
        RegisterShopSubmitted(
          name: _nameController.text.trim(),
          description: _descController.text.trim(),
          phoneNumber: _phoneController.text.trim(),
          address: _addressController.text.trim(),
          email: _emailController.text.trim(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: const Text('Đăng ký trở thành Seller'),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: AppColors.textPrimary,
      ),
      body: BlocConsumer<ShopRegistrationBloc, ShopRegistrationState>(
        listener: (context, state) {
          if (state is ShopRegistrationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Đăng ký thành công, vui lòng chờ Admin phê duyệt!'),
                backgroundColor: Colors.green,
              ),
            );
            // Refresh status immediately
            context.read<ShopRegistrationBloc>().add(CheckShopStatus());
          } else if (state is ShopRegistrationFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is ShopRegistrationInitial || state is ShopStatusLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is ShopStatusLoaded) {
            if (state.shop != null) {
              if (state.shop!.status == 'PENDING') {
                return _buildPendingUI();
              } else if (state.shop!.status == 'APPROVED') {
                return _buildApprovedUI();
              } else if (state.shop!.status == 'REJECTED') {
                // If rejected, we might show a message and the form below
                return Column(
                  children: [
                    _buildRejectedAlert(),
                    Expanded(child: _buildForm(isLoading: false)),
                  ],
                );
              }
            }
            // If shop is null, show form
            return _buildForm(isLoading: false);
          }

          if (state is ShopRegistrationLoading) {
            return _buildForm(isLoading: true);
          }

          if (state is ShopStatusCheckFailure) {
            // Assume no shop if error fetching
            return _buildForm(isLoading: false);
          }

          // Default fallback
          return _buildForm(isLoading: false);
        },
      ),
    );
  }

  Widget _buildPendingUI() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(20.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.hourglass_empty, size: 80.sp, color: Colors.orange),
            SizedBox(height: 16.h),
            Text(
              'Hồ sơ đang chờ duyệt',
              style: AppTextStyles.h2,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8.h),
            Text(
              'Yêu cầu đăng ký Shop của bạn đã được ghi nhận và đang chờ Admin xét duyệt. Vui lòng quay lại sau.',
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24.h),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                fixedSize: Size(double.infinity, 50.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
              ),
              child: const Text('Quay lại'),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildApprovedUI() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(20.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle, size: 80.sp, color: Colors.green),
            SizedBox(height: 16.h),
            Text('Cửa hàng đã được duyệt!', style: AppTextStyles.h2),
            SizedBox(height: 24.h),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                fixedSize: Size(double.infinity, 50.h),
              ),
              child: const Text('Quay lại trang cá nhân'),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildRejectedAlert() {
    return Container(
      width: double.infinity,
      color: Colors.red.shade50,
      padding: EdgeInsets.all(16.w),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              'Đơn đăng ký của bạn đã bị từ chối. Vui lòng kiểm tra lại thông tin và đăng ký lại.',
              style: AppTextStyles.bodyMedium.copyWith(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildForm({required bool isLoading}) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(20.w),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Thông tin Shop',
              style: AppTextStyles.h3.copyWith(color: AppColors.primaryBlue),
            ),
            SizedBox(height: 8.h),
            Text(
              'Vui lòng điền đầy đủ thông tin để xét duyệt.',
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
            ),
            SizedBox(height: 24.h),
            
            _buildTextField(
              controller: _nameController,
              label: 'Tên Shop *',
              hint: 'Nhập tên cửa hàng của bạn',
              icon: Icons.storefront,
              validator: (val) {
                if (val == null || val.trim().isEmpty) return 'Vui lòng nhập tên Shop';
                return null;
              },
            ),
            SizedBox(height: 16.h),
            
            _buildTextField(
              controller: _phoneController,
              label: 'Số điện thoại',
              hint: 'Nhập số điện thoại liên hệ',
              icon: Icons.phone,
              keyboardType: TextInputType.phone,
            ),
            SizedBox(height: 16.h),

            _buildTextField(
              controller: _emailController,
              label: 'Email',
              hint: 'Nhập email liên hệ',
              icon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
            ),
            SizedBox(height: 16.h),

            _buildTextField(
              controller: _addressController,
              label: 'Địa chỉ lấy hàng',
              hint: 'Nhập chính xác địa chỉ lấy hàng',
              icon: Icons.location_on_outlined,
            ),
            SizedBox(height: 16.h),

            _buildTextField(
              controller: _descController,
              label: 'Mô tả Shop',
              hint: 'Giới thiệu ngắn gọn về shop của bạn',
              icon: Icons.description_outlined,
              maxLines: 3,
            ),
            
            SizedBox(height: 32.h),

            ElevatedButton(
              onPressed: isLoading ? null : _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                padding: EdgeInsets.symmetric(vertical: 14.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
              ),
              child: isLoading
                  ? SizedBox(
                      width: 20.sp,
                      height: 20.sp,
                      child: const CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                  : Text(
                      'Đăng ký ngay',
                      style: AppTextStyles.h3.copyWith(color: Colors.white, fontSize: 16.sp),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: AppColors.primaryBlue),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.r),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.r),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.r),
          borderSide: const BorderSide(color: AppColors.primaryBlue),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }
}
