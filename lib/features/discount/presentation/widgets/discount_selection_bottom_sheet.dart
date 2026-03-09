import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/discount.dart';
import '../bloc/discount/discount_bloc.dart';
import '../bloc/discount/discount_event.dart';
import '../bloc/discount/discount_state.dart';
import 'discount_card_widget.dart';
import 'package:get_it/get_it.dart';

class DiscountSelectionBottomSheet extends StatefulWidget {
  final Discount? currentSelectedDiscount;
  final Function(Discount discount) onDiscountSelected;
  final VoidCallback onClearDiscount;

  const DiscountSelectionBottomSheet({
    Key? key,
    this.currentSelectedDiscount,
    required this.onDiscountSelected,
    required this.onClearDiscount,
  }) : super(key: key);

  static Future<void> show(
    BuildContext context, {
    Discount? currentSelectedDiscount,
    required Function(Discount discount) onDiscountSelected,
    required VoidCallback onClearDiscount,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DiscountSelectionBottomSheet(
        currentSelectedDiscount: currentSelectedDiscount,
        onDiscountSelected: onDiscountSelected,
        onClearDiscount: onClearDiscount,
      ),
    );
  }

  @override
  State<DiscountSelectionBottomSheet> createState() =>
      _DiscountSelectionBottomSheetState();
}

class _DiscountSelectionBottomSheetState
    extends State<DiscountSelectionBottomSheet> {
  final TextEditingController _codeController = TextEditingController();
  Discount? _tempSelectedDiscount;
  late DiscountBloc _discountBloc;

  @override
  void initState() {
    super.initState();
    _tempSelectedDiscount = widget.currentSelectedDiscount;
    _discountBloc = GetIt.I<DiscountBloc>();
    _discountBloc.add(const FetchMyVouchers());
  }

  @override
  void dispose() {
    _codeController.dispose();
    _discountBloc.close();
    super.dispose();
  }

  void _applySelection() {
    if (_codeController.text.isNotEmpty) {
      // Logic for manual code input could be extended here
      // i.e creating a dummy object or calling api to check first.
    } else if (_tempSelectedDiscount != null) {
      widget.onDiscountSelected(_tempSelectedDiscount!);
    } else {
      widget.onClearDiscount();
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Color(0xFFF5F5F5), // Shopee/Tiki often use gray background
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Chọn Voucher',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          // Input code section
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _codeController,
                    onChanged: (val) => setState(() {}),
                    decoration: InputDecoration(
                      hintText: 'Nhập mã voucher (VD: SUMMER10)',
                      prefixIcon: Icon(
                        Icons.confirmation_num_outlined,
                        color: Colors.grey.shade400,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 0,
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: _codeController.text.isNotEmpty
                      ? () {
                          // For now, manual apply goes to action
                          _applySelection();
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    disabledBackgroundColor: Colors.grey.shade200,
                    disabledForegroundColor: Colors.grey.shade400,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 14,
                    ),
                  ),
                  child: const Text(
                    'ÁP DỤNG',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Voucher List
          Expanded(
            child: BlocBuilder<DiscountBloc, DiscountState>(
              bloc: _discountBloc,
              builder: (context, state) {
                if (state is DiscountLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is DiscountError) {
                  return Center(
                    child: Text(
                      'Lỗi: ${state.message}',
                      style: const TextStyle(color: Colors.red),
                    ),
                  );
                } else if (state is MyVouchersLoaded) {
                  final vouchers = state.vouchers;

                  if (vouchers.isEmpty) {
                    return const Center(
                      child: Text('Bạn chưa có voucher nào.'),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: vouchers.length,
                    itemBuilder: (context, index) {
                      final discount = vouchers[index];
                      final isSelected =
                          _tempSelectedDiscount?.id == discount.id;

                      return DiscountCardWidget(
                        discount: discount,
                        isSelected: isSelected,
                        onTap: () {
                          setState(() {
                            if (isSelected) {
                              _tempSelectedDiscount = null; // Unselect
                            } else {
                              _tempSelectedDiscount = discount; // Select
                            }
                          });
                        },
                      );
                    },
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),

          // Bottom Button Layer
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: SafeArea(
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _applySelection,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Đồng ý',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
