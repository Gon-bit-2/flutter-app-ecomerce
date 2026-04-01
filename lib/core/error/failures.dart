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
  final int? statusCode;

  const ServerFailure(super.message, [this.statusCode]);

  @override
  List<Object> get props => [message, if (statusCode != null) statusCode!];
}

// Lỗi mạng (không có internet, timeout...)
class NetworkFailure extends Failure {
  const NetworkFailure(super.message);
}

// Lỗi cache/local storage
class CacheFailure extends Failure {
  const CacheFailure(super.message);
}

// Lỗi parse dữ liệu từ API (response không đúng format mong đợi)
class ParsingFailure extends Failure {
  final dynamic rawData;

  const ParsingFailure(super.message, [this.rawData]);

  @override
  List<Object> get props => [message, if (rawData != null) rawData!];
}
