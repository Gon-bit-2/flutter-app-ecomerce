import 'dart:async';
import 'dart:io';
import 'package:app_links/app_links.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class DeepLinkService {
  final AppLinks _appLinks = AppLinks();
  StreamSubscription<Uri>? _sub;
  bool _initialized = false;

  // Controller để broadcast URI nhận được
  final _deepLinkController = StreamController<Uri>.broadcast();
  Stream<Uri> get deepLinkStream => _deepLinkController.stream;

  Future<void> init() async {
    // Tránh khởi tạo nhiều lần
    if (_initialized) return;
    _initialized = true;

    // Đăng ký Custom URL Scheme trên Windows (nếu đang chạy trên Windows)
    if (!kIsWeb && Platform.isWindows) {
      await _registerWindowsProtocol();
    }

    // 1. Xử lý link khi App được mở từ trạng thái terminated (Cold start)
    try {
      final initialUri = await _appLinks.getInitialLink();
      if (initialUri != null) {
        debugPrint('[DeepLink] Initial link received: $initialUri');
        _deepLinkController.add(initialUri);
      }
    } catch (e) {
      debugPrint('[DeepLink] Error getting initial link: $e');
    }

    // 2. Lắng nghe link khi App đang chạy (Background/Foreground)
    _sub = _appLinks.uriLinkStream.listen(
      (uri) {
        debugPrint('[DeepLink] Stream link received: $uri');
        _deepLinkController.add(uri);
      },
      onError: (err) {
        debugPrint('[DeepLink] Stream error: $err');
      },
    );
  }

  /// Đăng ký custom URL scheme "appecomerce" vào Windows Registry
  /// để trình duyệt biết cách mở app khi gặp link appecomerce://...
  Future<void> _registerWindowsProtocol() async {
    try {
      // Lấy đường dẫn tới file .exe đang chạy
      final exePath = Platform.resolvedExecutable;
      debugPrint('[DeepLink] Registering Windows protocol with exe: $exePath');

      // Tạo script PowerShell để đăng ký Registry
      // Sử dụng HKCU (Current User) để không cần quyền Admin
      final script = '''
\$scheme = "appecomerce"
\$exePath = "$exePath"

# Tạo key cho protocol
New-Item -Path "HKCU:\\Software\\Classes\\\$scheme" -Force | Out-Null
Set-ItemProperty -Path "HKCU:\\Software\\Classes\\\$scheme" -Name "(Default)" -Value "URL:\$scheme Protocol"
Set-ItemProperty -Path "HKCU:\\Software\\Classes\\\$scheme" -Name "URL Protocol" -Value ""

# Tạo key cho icon
New-Item -Path "HKCU:\\Software\\Classes\\\$scheme\\DefaultIcon" -Force | Out-Null
Set-ItemProperty -Path "HKCU:\\Software\\Classes\\\$scheme\\DefaultIcon" -Name "(Default)" -Value "\$exePath,1"

# Tạo key cho command (mở app khi click link)
New-Item -Path "HKCU:\\Software\\Classes\\\$scheme\\shell\\open\\command" -Force | Out-Null
Set-ItemProperty -Path "HKCU:\\Software\\Classes\\\$scheme\\shell\\open\\command" -Name "(Default)" -Value "`"\$exePath`" `"%1`""
''';

      final result = await Process.run(
        'powershell',
        ['-NoProfile', '-NonInteractive', '-Command', script],
      );

      if (result.exitCode == 0) {
        debugPrint('[DeepLink] Windows protocol "appecomerce" registered successfully!');
      } else {
        debugPrint('[DeepLink] Failed to register protocol: ${result.stderr}');
      }
    } catch (e) {
      debugPrint('[DeepLink] Error registering Windows protocol: $e');
    }
  }

  void dispose() {
    _sub?.cancel();
    _deepLinkController.close();
  }
}
