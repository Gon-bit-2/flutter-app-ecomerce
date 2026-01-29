import 'dart:async';
import 'package:app_links/app_links.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class DeepLinkService {
  final AppLinks _appLinks = AppLinks();
  StreamSubscription<Uri>? _sub;

  // Controller để broadcast URI nhận được
  final _deepLinkController = StreamController<Uri>.broadcast();
  Stream<Uri> get deepLinkStream => _deepLinkController.stream;

  Future<void> init() async {
    // 1. Xử lý link khi App được mở từ trạng thái terminated (Cold start)
    try {
      final initialUri = await _appLinks.getInitialLink();
      if (initialUri != null) {
        _deepLinkController.add(initialUri);
      }
    } catch (e) {
      // Ignore error
    }

    // 2. Lắng nghe link khi App đang chạy (Background/Foreground)
    _sub = _appLinks.uriLinkStream.listen(
      (uri) {
        _deepLinkController.add(uri);
      },
      onError: (err) {
        // Ignore error
      },
    );
  }

  void dispose() {
    _sub?.cancel();
    _deepLinkController.close();
  }
}
