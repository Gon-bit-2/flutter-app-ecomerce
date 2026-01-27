// lib/core/error/failures.dart

import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;

  const Failure(this.message);

  @override
  List<Object> get props => [message];
}

// Lỗi server (400, 500...)
class ServerFailure extends Failure {
  const ServerFailure(super.message);
}

// Lỗi mạng (không có internet, timeout...)
class NetworkFailure extends Failure {
  const NetworkFailure(super.message);
}

// Lỗi cache/local storage
class CacheFailure extends Failure {
  const CacheFailure(super.message);
}
