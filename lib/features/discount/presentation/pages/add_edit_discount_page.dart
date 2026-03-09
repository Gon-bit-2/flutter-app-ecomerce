import 'package:app_fe_ecomerce/core/styles/app_colors.dart';
import 'package:app_fe_ecomerce/core/styles/app_text_styles.dart';
import 'package:app_fe_ecomerce/features/discount/domain/entities/discount.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';

import '../bloc/seller_discount/seller_discount_bloc.dart';
import '../bloc/seller_discount/seller_discount_event.dart';
import '../bloc/seller_discount/seller_discount_state.dart';

class AddEditDiscountPage extends StatefulWidget {
  final Discount? discount; // Null if create, non-null if edit

  const AddEditDiscountPage({super.key, this.discount});

  @override
  State<AddEditDiscountPage> createState() => _AddEditDiscountPageState();
}

class _AddEditDiscountPageState extends State<AddEditDiscountPage> {
  final _formKey = GlobalKey<FormState>();
  late SellerDiscountBloc _bloc;

  bool get isEditing => widget.discount != null;

  late TextEditingController _nameController;
  late TextEditingController _codeController;
  late TextEditingController _valueController;
  late TextEditingController _minOrderValueController;
  late TextEditingController _maxUsesController;
  late TextEditingController _descController;
  late TextEditingController _maxDiscountController;

  String _type = 'PERCENTAGE';
  String _scope = 'SHOP';
  bool _isActive = true;
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    _bloc = GetIt.I<SellerDiscountBloc>();

    final d = widget.discount;
    _nameController = TextEditingController(text: d?.name ?? '');
    _codeController = TextEditingController(text: d?.code ?? '');
    _valueController = TextEditingController(text: d?.value.toString() ?? '');
    _minOrderValueController = TextEditingController(
      text: d?.minOrderValue.toString() ?? '',
    );
    _maxUsesController = TextEditingController(
      text: d?.maxTotalUses.toString() ?? '',
    );
    _descController = TextEditingController(text: d?.description ?? '');
    _maxDiscountController = TextEditingController(
      text: d?.maxDiscountValue?.toString() ?? '',
    );

    if (d != null) {
      _type = d.type.name;
      _scope = d.scope.name;
      _isActive = d.isActive;
      _startDate = d.startDate;
      _endDate = d.endDate;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _codeController.dispose();
    _valueController.dispose();
    _minOrderValueController.dispose();
    _maxUsesController.dispose();
    _descController.dispose();
    _maxDiscountController.dispose();
    super.dispose();
  }

  Future<void> _pickDate(BuildContext context, bool isStart) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isStart
          ? (_startDate ?? DateTime.now())
          : (_endDate ?? DateTime.now()),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        if (isStart)
          _startDate = picked;
        else
          _endDate = picked;
      });
    }
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final data = <String, dynamic>{
      'name': _nameController.text.trim(),
      'code': _codeController.text.trim(),
      'value': num.tryParse(_valueController.text.trim()) ?? 0,
      'type': _type,
      'scope': _scope,
      'isActive': _isActive,
      'description': _descController.text.trim(),
    };

    if (_maxDiscountController.text.isNotEmpty &&
        (_type == 'PERCENTAGE' || _type == 'SHIPPING')) {
      data['maxDiscountValue'] = num.tryParse(
        _maxDiscountController.text.trim(),
      );
    }

    if (_minOrderValueController.text.isNotEmpty) {
      data['minOrderValue'] = num.tryParse(
        _minOrderValueController.text.trim(),
      );
    }
    if (_maxUsesController.text.isNotEmpty) {
      data['maxTotalUses'] = int.tryParse(_maxUsesController.text.trim());
    }
    if (_startDate != null) {
      data['startDate'] = _startDate!.toUtc().toIso8601String();
    }
    if (_endDate != null) {
      data['endDate'] = _endDate!.toUtc().toIso8601String();
    }

    // Hardcoded shopId = 1 for Seller (Ideally drawn from User Session)
    if (!isEditing) {
      data['shopId'] = 1;
      data['applyTo'] = 'ALL';
      data['maxUsesPerUser'] = 1;
    }

    if (isEditing) {
      _bloc.add(
        UpdateExistingDiscount(discountId: widget.discount!.id, data: data),
      );
    } else {
      _bloc.add(CreateNewDiscount(data: data));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _bloc,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F5F5),
        appBar: AppBar(
          backgroundColor: AppColors.primaryBlue,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            isEditing ? 'Sửa Mã Giảm Giá' : 'Thêm Mã Mới',
            style: AppTextStyles.h3.copyWith(color: Colors.white),
          ),
        ),
        bottomNavigationBar: SafeArea(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: _submit,
              child: Text(
                isEditing ? 'LƯU THAY ĐỔI' : 'TẠO MÃ GIẢM GIÁ',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
        body: BlocListener<SellerDiscountBloc, SellerDiscountState>(
          listener: (context, state) {
            if (state is SellerDiscountError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: AppColors.error,
                ),
              );
            } else if (state is SellerDiscountOperationSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: AppColors.success,
                ),
              );
              Navigator.pop(context, true); // Return true to trigger reload
            }
          },
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildCardSection(
                    title: 'Thông tin cơ bản',
                    children: [
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Tên chiến dịch *',
                          hintText: 'VD: Khuyến mãi Hè',
                        ),
                        validator: (val) => val == null || val.isEmpty
                            ? 'Không được để trống'
                            : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _codeController,
                        decoration: const InputDecoration(
                          labelText: 'Mã Code *',
                          hintText: 'VD: SUMMER10 (chỉ viết hoa, không dấu)',
                        ),
                        validator: (val) => val == null || val.isEmpty
                            ? 'Không được để trống'
                            : null,
                        enabled:
                            !isEditing, // Thường không cho đổi mã code sau khi tạo
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _descController,
                        decoration: const InputDecoration(
                          labelText: 'Mô tả chi tiết *',
                          hintText: 'VD: Khuyến mãi mua sắm thả ga',
                        ),
                        maxLines: 2,
                        validator: (val) => val == null || val.isEmpty
                            ? 'Không được để trống'
                            : null,
                      ),
                    ],
                  ),

                  _buildCardSection(
                    title: 'Thiết lập mã giảm giá',
                    children: [
                      DropdownButtonFormField<String>(
                        value: _type,
                        decoration: const InputDecoration(
                          labelText: 'Loại giảm giá *',
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: 'PERCENTAGE',
                            child: Text('Giảm theo phần trăm (%)'),
                          ),
                          DropdownMenuItem(
                            value: 'FIXED_AMOUNT',
                            child: Text('Giảm số tiền cố định (đ)'),
                          ),
                          DropdownMenuItem(
                            value: 'SHIPPING',
                            child: Text('Miễn phí vận chuyển (đ)'),
                          ),
                        ],
                        onChanged: (val) {
                          if (val != null) setState(() => _type = val);
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _valueController,
                        decoration: InputDecoration(
                          labelText: 'Mức giảm *',
                          suffixText: _type == 'PERCENTAGE' ? '%' : 'đ',
                        ),
                        keyboardType: TextInputType.number,
                        validator: (val) => val == null || val.isEmpty
                            ? 'Không được để trống'
                            : null,
                      ),
                      if (_type == 'PERCENTAGE' || _type == 'SHIPPING') ...[
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _maxDiscountController,
                          decoration: const InputDecoration(
                            labelText: 'Giảm tối đa (Đóng khung giới hạn)',
                            suffixText: 'đ',
                          ),
                          keyboardType: TextInputType.number,
                        ),
                      ],
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _minOrderValueController,
                        decoration: const InputDecoration(
                          labelText: 'Giá trị đơn hàng tối thiểu',
                          suffixText: 'đ',
                        ),
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _maxUsesController,
                        decoration: const InputDecoration(
                          labelText: 'Tổng lượt sử dụng tối đa',
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ],
                  ),

                  _buildCardSection(
                    title: 'Thời gian áp dụng',
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: InkWell(
                              onTap: () => _pickDate(context, true),
                              child: InputDecorator(
                                decoration: const InputDecoration(
                                  labelText: 'Từ ngày *',
                                  suffixIcon: Icon(
                                    Icons.calendar_month,
                                    color: Colors.grey,
                                  ),
                                ),
                                child: Text(
                                  _startDate == null
                                      ? 'Chọn ngày'
                                      : DateFormat(
                                          'dd/MM/yyyy',
                                        ).format(_startDate!),
                                  style: TextStyle(
                                    color: _startDate == null
                                        ? Colors.grey
                                        : Colors.black87,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: InkWell(
                              onTap: () => _pickDate(context, false),
                              child: InputDecorator(
                                decoration: const InputDecoration(
                                  labelText: 'Đến ngày *',
                                  suffixIcon: Icon(
                                    Icons.calendar_month,
                                    color: Colors.grey,
                                  ),
                                ),
                                child: Text(
                                  _endDate == null
                                      ? 'Chọn ngày'
                                      : DateFormat(
                                          'dd/MM/yyyy',
                                        ).format(_endDate!),
                                  style: TextStyle(
                                    color: _endDate == null
                                        ? Colors.grey
                                        : Colors.black87,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text(
                          'Kích hoạt mã ngay sau khi lưu',
                          style: TextStyle(fontSize: 14),
                        ),
                        value: _isActive,
                        activeColor: Theme.of(context).primaryColor,
                        onChanged: (val) => setState(() => _isActive = val),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCardSection({
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }
}
