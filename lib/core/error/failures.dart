import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;
  const Failure(this.message);

  @override
  List<Object> get props => [message];
}

// Lỗi từ Server (VD: Sai pass, Mất mạng)
class ServerFailure extends Failure {
  const ServerFailure(super.message);
}

// Lỗi từ Cache (VD: Không tìm thấy token cũ)
class CacheFailure extends Failure {
  const CacheFailure(super.message);
}
