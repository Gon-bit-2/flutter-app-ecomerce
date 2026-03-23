import 'dart:async';
import 'package:app_fe_ecomerce/core/constants/app_constants.dart';
import 'package:app_fe_ecomerce/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:app_fe_ecomerce/features/chat/data/models/message_model.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

/// Service quản lý kết nối WebSocket cho real-time chat.
/// Tách biệt với payment socket (namespace /payment).
/// Chat socket sử dụng namespace mặc định (/) theo tài liệu API.
@lazySingleton
class ChatSocketService {
  final AuthLocalDataSource _authLocalDataSource;

  io.Socket? _socket;
  final _messageController = StreamController<MessageModel>.broadcast();

  /// Stream tin nhắn real-time từ WebSocket
  Stream<MessageModel> get messageStream => _messageController.stream;

  bool _isConnected = false;
  bool get isConnected => _isConnected;

  ChatSocketService(this._authLocalDataSource);

  /// Kết nối đến WebSocket server
  Future<void> connect() async {
    if (_isConnected && _socket != null) return;

    final token = await _authLocalDataSource.getAccessToken();
    if (token == null || token.isEmpty) {
      debugPrint('[ChatSocket] Không có token, bỏ qua kết nối');
      return;
    }

    final socketUrl = AppConstants.baseUrl;

    _socket = io.io(
      socketUrl,
      io.OptionBuilder()
          .setTransports(['websocket'])
          .setExtraHeaders({'Authorization': 'Bearer $token'})
          .enableAutoConnect()
          .enableReconnection()
          .build(),
    );

    _socket!.onConnect((_) {
      debugPrint('[ChatSocket] Đã kết nối thành công');
      _isConnected = true;
    });

    _socket!.on(AppConstants.chatSocketEvent, (data) {
      debugPrint('[ChatSocket] Nhận tin nhắn mới: $data');
      try {
        if (data is Map<String, dynamic>) {
          final message = MessageModel.fromJson(data);
          _messageController.add(message);
        }
      } catch (e) {
        debugPrint('[ChatSocket] Lỗi parse tin nhắn: $e');
      }
    });

    _socket!.onDisconnect((_) {
      debugPrint('[ChatSocket] Đã ngắt kết nối');
      _isConnected = false;
    });

    _socket!.onConnectError((error) {
      debugPrint('[ChatSocket] Lỗi kết nối: $error');
      _isConnected = false;
    });

    _socket!.onError((error) {
      debugPrint('[ChatSocket] Lỗi socket: $error');
    });
  }

  /// Ngắt kết nối WebSocket
  void disconnect() {
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
    _isConnected = false;
    debugPrint('[ChatSocket] Đã ngắt kết nối và dispose');
  }

  /// Dispose service (gọi khi app tắt)
  @disposeMethod
  void dispose() {
    disconnect();
    _messageController.close();
  }
}
