import 'package:equatable/equatable.dart';

class PaymentConfigEntity extends Equatable {
  final String accountNumber;
  final String bankCode;
  final String prefix;

  const PaymentConfigEntity({
    required this.accountNumber,
    required this.bankCode,
    required this.prefix,
  });

  @override
  List<Object?> get props => [accountNumber, bankCode, prefix];
}
