// lib/core/network/network_info.dart

import 'package:injectable/injectable.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

// Interface (Abstraction)
abstract class NetworkInfo {
  Future<bool> get isConnected;
}

// Implementation
@LazySingleton(as: NetworkInfo)
class NetworkInfoImpl implements NetworkInfo {
  final Connectivity _connectivity;

  NetworkInfoImpl(this._connectivity);

  @override
  Future<bool> get isConnected async {
    final result = await _connectivity.checkConnectivity();

    // Kiểm tra nếu có kết nối (wifi, mobile data, ethernet...)
    return result.contains(ConnectivityResult.mobile) ||
        result.contains(ConnectivityResult.wifi) ||
        result.contains(ConnectivityResult.ethernet);
  }
}
