import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/discount/discount_bloc.dart';
import '../bloc/discount/discount_event.dart';
import '../bloc/discount/discount_state.dart';
import '../widgets/discount_card_widget.dart';
import 'package:get_it/get_it.dart';

class VoucherWalletPage extends StatefulWidget {
  const VoucherWalletPage({super.key});

  @override
  State<VoucherWalletPage> createState() => _VoucherWalletPageState();
}

class _VoucherWalletPageState extends State<VoucherWalletPage> {
  late DiscountBloc _discountBloc;

  @override
  void initState() {
    super.initState();
    _discountBloc = GetIt.I<DiscountBloc>();
    _discountBloc.add(const FetchMyVouchers());
  }

  @override
  void dispose() {
    _discountBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kho Voucher', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      backgroundColor: const Color(0xFFF5F5F5),
      body: BlocBuilder<DiscountBloc, DiscountState>(
        bloc: _discountBloc,
        builder: (context, state) {
          if (state is DiscountLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is DiscountError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Lỗi: ${state.message}',
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            );
          } else if (state is MyVouchersLoaded) {
            final vouchers = state.vouchers;

            if (vouchers.isEmpty) {
              return _buildEmptyState();
            }

            return RefreshIndicator(
              onRefresh: () async {
                _discountBloc.add(const FetchMyVouchers());
              },
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: vouchers.length,
                itemBuilder: (context, index) {
                  return DiscountCardWidget(
                    discount: vouchers[index],
                    // Trong ví voucher, tap vào có thể nhảy đi xem điều kiện áp dụng
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Chức năng xem chi tiết đang được cập nhật!',
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.local_activity_outlined,
            size: 80,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'Bạn chưa có mã giảm giá nào',
            style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Trở về trang trước hoặc đi mua sắm
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
            ),
            child: const Text(
              'Tiếp tục mua sắm',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
