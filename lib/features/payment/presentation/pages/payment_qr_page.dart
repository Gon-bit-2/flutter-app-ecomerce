import 'package:app_fe_ecomerce/core/constants/app_constants.dart';
import 'package:app_fe_ecomerce/core/styles/app_colors.dart';
import 'package:app_fe_ecomerce/core/styles/app_text_styles.dart';
import 'package:app_fe_ecomerce/features/payment/domain/entities/payment_config_entity.dart';
import 'package:app_fe_ecomerce/features/payment/domain/usecases/get_payment_config_usecase.dart';
import 'package:app_fe_ecomerce/core/usecase/usecase.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get_it/get_it.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

class PaymentQRPage extends StatefulWidget {
  final int paymentId;
  final num totalAmount;
  final bool isTestingMode; // cờ chặn socket connection trong widget test

  const PaymentQRPage({
    super.key,
    required this.paymentId,
    required this.totalAmount,
    this.isTestingMode = false,
  });

  @override
  State<PaymentQRPage> createState() => _PaymentQRPageState();
}

class _PaymentQRPageState extends State<PaymentQRPage> {
  PaymentConfigEntity? _config;
  bool _isLoading = true;
  String? _error;
  late io.Socket _socket;
  bool _isPaymentSuccess = false;

  @override
  void initState() {
    super.initState();
    _fetchConfig();
    _initSocket();
  }

  Future<void> _fetchConfig() async {
    final useCase = GetIt.I<GetPaymentConfigUseCase>();
    final result = await useCase(NoParams());

    result.fold(
      (failure) {
        if (mounted) {
          setState(() {
            _error = failure.message;
            _isLoading = false;
          });
        }
      },
      (config) {
        if (mounted) {
          setState(() {
            _config = config;
            _isLoading = false;
          });
        }
      },
    );
  }

  void _initSocket() {
    if (widget.isTestingMode) {
      return; // Prevent connecting real socket during testing
    }

    // Assuming backend endpoint is baseUrl without trailing slash
    final socketUrl =
        '${AppConstants.baseUrl}${AppConstants.paymentSocketNamespace}';

    _socket = io.io(
      socketUrl,
      io.OptionBuilder()
          .setTransports(['websocket'])
          // TODO: Implement token retrieval for socket authentication if needed based on FRONTEND_GUIDE (extraHeaders: Authorization)
          // Usually would fetch token from SharedPreferences here
          .build(),
    );

    _socket.onConnect((_) {
      debugPrint('Connected to payment socket');
    });

    _socket.on('payment', (data) {
      if (data != null && data['status'] == 'success') {
        if (mounted) {
          setState(() {
            _isPaymentSuccess = true;
          });
          _showPaymentSuccessDialog();
        }
      }
    });

    _socket.onDisconnect((_) {
      debugPrint('Disconnected from payment socket');
    });
  }

  void _showPaymentSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle, color: AppColors.success, size: 60.sp),
            SizedBox(height: 16.h),
            Text(
              'Thanh toán thành công!',
              style: AppTextStyles.h3,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8.h),
            Text(
              'Đơn hàng của bạn đã được xác nhận thanh toán qua SePay.',
              style: AppTextStyles.bodyMedium,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24.h),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                ),
                child: Text('Tuyệt vời', style: AppTextStyles.buttonText),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    if (!widget.isTestingMode) {
      _socket.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Thanh toán mã QR',
          style: AppTextStyles.h3.copyWith(color: Colors.white),
        ),
        backgroundColor: AppColors.primaryBlue,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            // Provide option to cancel and go back
            Navigator.pop(context);
          },
        ),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(
              child: Text(
                'Lỗi: $_error',
                style: TextStyle(color: AppColors.error),
              ),
            )
          : _buildQRContent(),
    );
  }

  Widget _buildQRContent() {
    if (_config == null) return const SizedBox.shrink();

    final transferContent = '${_config!.prefix}${widget.paymentId}';
    final qrUrl =
        'https://qr.sepay.vn/img?acc=${_config!.accountNumber}&bank=${_config!.bankCode}&amount=${widget.totalAmount}&des=$transferContent';

    return SingleChildScrollView(
      padding: EdgeInsets.all(24.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text('Quét mã QR để thanh toán', style: AppTextStyles.h2),
          SizedBox(height: 8.h),
          Text(
            'Mở ứng dụng ngân hàng và quét mã để thanh toán tự động.',
            style: AppTextStyles.bodyMedium,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 32.h),

          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: widget.isTestingMode
                ? SizedBox(
                    width: 250.w,
                    height: 250.w,
                    child: const Center(child: Icon(Icons.qr_code, size: 100)),
                  )
                : Image.network(
                    qrUrl,
                    width: 250.w,
                    height: 250.w,
                    fit: BoxFit.contain,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return SizedBox(
                        width: 250.w,
                        height: 250.w,
                        child: const Center(child: CircularProgressIndicator()),
                      );
                    },
                  ),
          ),

          SizedBox(height: 32.h),

          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: AppColors.inputBackground,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Column(
              children: [
                _buildInfoRow('Ngân hàng', _config!.bankCode),
                const Divider(),
                _buildInfoRow('Số tài khoản', _config!.accountNumber),
                const Divider(),
                _buildInfoRow(
                  'Số tiền',
                  '${widget.totalAmount} đ',
                  isHighlight: true,
                ),
                const Divider(),
                _buildInfoRow(
                  'Nội dung chuyển khoản',
                  transferContent,
                  isHighlight: true,
                ),
              ],
            ),
          ),

          SizedBox(height: 16.h),
          Text(
            'Lưu ý: Bạn phải CẦN NHẬP ĐÚNG "Nội dung chuyển khoản" để hệ thống xác nhận thanh toán tự động.',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.error,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 32.h),

          if (_isPaymentSuccess)
            Text(
              'Thanh toán thành công. Đang xử lý...',
              style: AppTextStyles.bodyLarge.copyWith(color: AppColors.success),
            )
          else
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 20.w,
                  height: 20.w,
                  child: const CircularProgressIndicator(strokeWidth: 2),
                ),
                SizedBox(width: 12.w),
                Text(
                  'Đang chờ thanh toán...',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isHighlight = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTextStyles.bodyMedium),
          Text(
            value,
            style: isHighlight
                ? AppTextStyles.bodyLarge.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryBlue,
                  )
                : AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
          ),
        ],
      ),
    );
  }
}
