import 'package:app_fe_ecomerce/core/constants/app_constants.dart';
import 'package:app_fe_ecomerce/core/styles/app_colors.dart';
import 'package:app_fe_ecomerce/core/styles/app_text_styles.dart';
import 'package:app_fe_ecomerce/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:app_fe_ecomerce/features/payment/domain/entities/payment_config_entity.dart';
import 'package:app_fe_ecomerce/features/payment/domain/usecases/get_payment_config_usecase.dart';

import 'package:app_fe_ecomerce/features/order/domain/usecases/get_order_detail_usecase.dart';
import 'package:app_fe_ecomerce/core/usecase/usecase.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get_it/get_it.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'package:app_fe_ecomerce/core/common/widgets/app_network_image.dart';
import 'package:app_fe_ecomerce/core/network/dio_client.dart';

class PaymentQRPage extends StatefulWidget {
  final int paymentId;
  final num totalAmount;
  final int? orderId;
  final bool isTestingMode; // cờ chặn socket connection trong widget test

  const PaymentQRPage({
    super.key,
    required this.paymentId,
    required this.totalAmount,
    this.orderId,
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
  bool _isCheckingPayment = false;
  bool _isExpired = false;

  @override
  void initState() {
    super.initState();
    _checkOrderValidity();
    _fetchConfig();
    _initSocket();
  }

  Future<void> _checkOrderValidity() async {
    if (widget.orderId == null) return;
    try {
      final getOrderDetail = GetIt.I<GetOrderDetailUseCase>();
      final result = await getOrderDetail(widget.orderId!);
      result.fold(
        (l) => null, // ignore error
        (order) {
          if (mounted && order.status == 'CANCELLED') {
            setState(() {
              _isExpired = true;
            });
          }
        }
      );
    } catch (_) {}
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

  Future<void> _initSocket() async {
    if (widget.isTestingMode) {
      return; // Prevent connecting real socket during testing
    }

    // Lấy accessToken để xác thực socket
    final authLocal = GetIt.I<AuthLocalDataSource>();
    final accessToken = await authLocal.getAccessToken();

    // Assuming backend endpoint is baseUrl without trailing slash
    final socketUrl =
        '${AppConstants.baseUrl}${AppConstants.paymentSocketNamespace}';

    _socket = io.io(
      socketUrl,
      io.OptionBuilder()
          // Chỉ sử dụng websocket transport để tránh lỗi timeout khi polling trên mobile
          .setTransports(['websocket'])
          .disableMultiplex() // Force a new manager connection
          .setExtraHeaders({
            if (accessToken != null)
              'Authorization': 'Bearer $accessToken',
          })
          .setQuery({
            if (accessToken != null)
              'token': accessToken,
          })
          .setAuth({
            if (accessToken != null)
              'token': accessToken,
          })
          .enableAutoConnect()
          .enableReconnection()
          .build(),
    );

    _socket.onConnect((_) {
      debugPrint('Connected to payment socket');
    });

    _socket.onAny((event, data) {
      debugPrint('Payment Socket received event: $event, data: $data');
      if (event == 'payment' || event == 'payment_success' || event == 'paymentSuccess') {
        _handlePaymentPush(event, data);
      }
    });

    _socket.onDisconnect((_) {
      debugPrint('Disconnected from payment socket');
    });

    _socket.onConnectError((err) {
      debugPrint('Payment socket connection error: $err');
    });
  }

  void _handlePaymentPush(String event, dynamic data) {
    debugPrint('Handling payment push event: $event, data: $data');
    
    // Nếu event đã tường minh là thành công
    if (event == 'payment_success' || event == 'paymentSuccess') {
      _triggerSuccess();
      return;
    }

    if (data != null) {
      if (data is Map) {
        final status = data['status']?.toString().toLowerCase();
        // Chấp nhận 'success' hoặc 'paid'
        if (status != 'success' && status != 'paid') return;
        
        // Kiểm tra paymentId nếu có
        if (data['paymentId'] != null) {
          final pId = int.tryParse(data['paymentId'].toString());
          if (pId != null && pId != widget.paymentId) {
             debugPrint('PaymentId mismatch: $pId != ${widget.paymentId}');
             return;
          }
        }
      } else if (data is String) {
        final lower = data.toLowerCase();
        if (!lower.contains('success') && !lower.contains('paid')) return;
      }
    }
    
    _triggerSuccess();
  }

  void _triggerSuccess() {
    if (mounted && !_isPaymentSuccess) {
      setState(() {
        _isPaymentSuccess = true;
      });
      
      // Auto redirect sau 2s khi success
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          Navigator.of(context).popUntil((route) => route.isFirst);
        }
      });
    }
  }

  Future<void> _verifyPaymentManual() async {
    if (_isCheckingPayment) return;
    setState(() => _isCheckingPayment = true);

    try {
      final dioClient = GetIt.I<DioClient>();
      bool isSuccess = false;
      String lastStatus = 'PENDING';

      // Thử tối đa 3 lần, mỗi lần cách nhau 2 giây (tổng ~6s)
      for (int i = 0; i < 3; i++) {
        final response = await dioClient.get('/payment/${widget.paymentId}/status');
        
        final data = response.data;
        debugPrint('--- MANUAL CHECK RESPONSE PING $i ---');
        debugPrint(data.toString());
        
        if (data != null) {
          // Xử lý cả trường hợp response bọc trong { "data": { "status": "..." } }
          final payload = data['data'] != null ? data['data'] : data;
          
          if (payload['status'] != null) {
            lastStatus = payload['status'].toString().toUpperCase();
            if (lastStatus == 'SUCCESS' || lastStatus == 'PAID') {
              isSuccess = true;
              break;
            }
          }
        }
        
        // Nghỉ 2s trước khi thử lại nếu chưa thành công (trừ lần cuối cùng)
        if (i < 2) {
          await Future.delayed(const Duration(seconds: 2));
        }
      }

      if (isSuccess) {
        _triggerSuccess();
      } else {
        _showSnackBar(
          'Giao dịch đang xử lý hoặc chưa nhận được tiền (Trạng thái: $lastStatus). '
          'Quá trình này có thể mất 1-5 phút. Vui lòng chờ và thử lại sau.',
        );
      }
    } catch (e) {
      _showSnackBar('Lỗi khi kiểm tra thanh toán. Vui lòng thử lại sau.', isError: true);
      debugPrint('Error manually checking payment status: $e');
    } finally {
      if (mounted) setState(() => _isCheckingPayment = false);
    }
  }

  void _showSnackBar(String msg, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError ? AppColors.error : AppColors.textPrimary,
        duration: const Duration(seconds: 2),
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
    if (_isExpired) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.cancel_outlined, size: 80.sp, color: AppColors.error),
              SizedBox(height: 16.h),
              Text(
                'Đơn hàng đã hết hạn thanh toán',
                style: AppTextStyles.h3.copyWith(color: AppColors.error),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8.h),
              Text(
                'Quá thời gian chờ thanh toán, đơn hàng đã bị huỷ. Vui lòng quay lại và đặt lại đơn hàng mới.',
                style: AppTextStyles.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ]
          )
        )
      );
    }

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
                : AppNetworkImage(
                    imageUrl: qrUrl, 
                    width: 250.w,
                    height: 250.w,
                    fit: BoxFit.contain,
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
                _buildInfoRowWithCopy('Số tài khoản', _config!.accountNumber, _config!.accountNumber),
                const Divider(),
                _buildInfoRow('Số tiền', '${widget.totalAmount} đ', isHighlight: true),
                const Divider(),
                _buildInfoRowWithCopy(
                  'Nội dung chuyển khoản', 
                  transferContent,
                  transferContent,
                  isHighlight: true
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
            Column(
              children: [
                Icon(Icons.check_circle, color: AppColors.success, size: 60.sp),
                SizedBox(height: 16.h),
                Text(
                  'Thanh toán thành công. Đang chuyển hướng...',
                  style: AppTextStyles.bodyLarge.copyWith(color: AppColors.success),
                  textAlign: TextAlign.center,
                ),
              ],
            )
          else
            Column(
              children: [
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
                SizedBox(height: 16.h),
                OutlinedButton(
                  onPressed: _isCheckingPayment ? null : _verifyPaymentManual,
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.primaryBlue),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                  ),
                  child: _isCheckingPayment 
                      ? SizedBox(
                          width: 20.w, 
                          height: 20.w, 
                          child: const CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation(AppColors.primaryBlue))
                        )
                      : Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.refresh, color: AppColors.primaryBlue, size: 20.sp),
                            SizedBox(width: 8.w),
                            Text('Tôi đã thanh toán', style: AppTextStyles.buttonText.copyWith(color: AppColors.primaryBlue)),
                          ],
                        ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildInfoRowWithCopy(String label, String displayValue, String copyValue, {bool isHighlight = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(flex: 3, child: Text(label, style: AppTextStyles.bodyMedium)),
          Expanded(
            flex: 5,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Flexible(
                  child: Text(
                    displayValue,
                    style: isHighlight
                        ? AppTextStyles.bodyLarge.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryBlue,
                          )
                        : AppTextStyles.bodyMedium.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    textAlign: TextAlign.right,
                  ),
                ),
                SizedBox(width: 8.w),
                InkWell(
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: copyValue));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Đã sao chép $label'),
                        duration: const Duration(seconds: 1),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  child: Padding(
                    padding: EdgeInsets.all(4.w),
                    child: Icon(Icons.copy, size: 20.sp, color: AppColors.primaryBlue),
                  ),
                ),
              ],
            ),
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
