
import 'package:app_fe_ecomerce/core/styles/app_colors.dart';
import 'package:app_fe_ecomerce/core/styles/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app_fe_ecomerce/features/auth/presentation/bloc/auth/auth_bloc.dart';

class GoogleLoginWebView extends StatefulWidget {
  final String url;

  const GoogleLoginWebView({super.key, required this.url});

  @override
  State<GoogleLoginWebView> createState() => _GoogleLoginWebViewState();
}

class _GoogleLoginWebViewState extends State<GoogleLoginWebView> {
  late final WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            setState(() {
              _isLoading = true;
            });
          },
          onPageFinished: (String url) {
            setState(() {
              _isLoading = false;
            });
          },
          onNavigationRequest: (NavigationRequest request) {
            // Chặn intercept URL bắt đầu bằng localhost hoặc 10.0.2.2/auth/google/callback
            if (request.url.contains('/auth/google/callback')) {
              final uri = Uri.parse(request.url);
              final code = uri.queryParameters['code'];
              final state = uri.queryParameters['state'];

              if (code != null && state != null) {
                // Gọi event gửi code lên backend
                context.read<AuthBloc>().add(
                      AuthGoogleCallbackReceived(code: code, state: state),
                    );
                // Đóng WebView và trở lại màn hình đăng nhập
                Navigator.of(context).pop();
                return NavigationDecision.prevent;
              }
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      // Cấu hình custom User-Agent đôi khi cần thiết để Google không block WebView nội bộ
      ..setUserAgent(
        "Mozilla/5.0 (Linux; Android 10; SM-G960F) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/92.0.4515.159 Mobile Safari/537.36",
      );

    // Chỉnh sửa URL để ép Google luôn hiện bảng chọn tài khoản thay vì tự đăng nhập vào tài khoản cũ
    final initialUri = Uri.parse(widget.url);
    final modifiedQuery = Map<String, dynamic>.from(initialUri.queryParameters);
    modifiedQuery['prompt'] = 'select_account';
    final finalUri = initialUri.replace(queryParameters: modifiedQuery);

    _controller.loadRequest(finalUri);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Đăng nhập với Google",
          style: AppTextStyles.h3.copyWith(color: AppColors.primaryBlue),
        ),
        backgroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}
