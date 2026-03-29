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
  final int? shopId; // Lấy từ màn hình cha (seller)
  final bool
  isAdmin; // true = Admin tạo mã toàn sàn, false = Seller tạo mã shop

  const AddEditDiscountPage({
    super.key,
    this.discount,
    this.shopId,
    this.isAdmin = false,
  });

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
  late TextEditingController _maxUsesPerUserController;

  String _type = 'PERCENTAGE';
  String _scope = 'SHOP';
  String _applyTo = 'ALL';
  bool _isActive = true;
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    _bloc = GetIt.I<SellerDiscountBloc>();

    // Admin mặc định scope PLATFORM, Seller mặc định scope SHOP
    if (widget.isAdmin) {
      _scope = 'PLATFORM';
    }

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
    _maxUsesPerUserController = TextEditingController(
      text: d?.maxUsesPerUser.toString() ?? '1',
    );

    if (d != null) {
      _type = d.type.name;
      _scope = d.scope.name;
      _applyTo = d.applyTo.name;
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
    _maxUsesPerUserController.dispose();
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
        if (isStart) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    // Validate ngày bắt buộc
    if (_startDate == null || _endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng chọn ngày bắt đầu và ngày kết thúc'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final data = <String, dynamic>{
      'name': _nameController.text.trim(),
      'code': _codeController.text.trim(),
      'value': num.tryParse(_valueController.text.trim()) ?? 0,
      'type': _type,
      'scope': _scope,
      'isActive': _isActive,
      'description': _descController.text.trim(),
      // Các trường bắt buộc theo API - luôn gửi
      'startDate': _startDate!.toUtc().toIso8601String(),
      'endDate': _endDate!.toUtc().toIso8601String(),
      'minOrderValue': num.tryParse(_minOrderValueController.text.trim()) ?? 0,
      'maxTotalUses': int.tryParse(_maxUsesController.text.trim()) ?? 100,
      'maxUsesPerUser':
          int.tryParse(_maxUsesPerUserController.text.trim()) ?? 1,
      'applyTo': _applyTo,
    };

    if (_maxDiscountController.text.isNotEmpty &&
        (_type == 'PERCENTAGE' || _type == 'SHIPPING')) {
      data['maxDiscountValue'] = num.tryParse(
        _maxDiscountController.text.trim(),
      );
    }

    // Luôn gửi productIds và categoryIds (mảng rỗng khi applyTo = ALL)
    data['productIds'] = <int>[];
    data['categoryIds'] = <int>[];

    if (!isEditing) {
      if (widget.isAdmin) {
        // Admin tạo mã toàn sàn: scope = PLATFORM, không cần shopId
        // Backend sẽ lưu shopId = null cho voucher PLATFORM
        if (_scope == 'PLATFORM') {
          // Không gửi shopId cho mã toàn sàn
        } else {
          // Admin cũng có thể tạo mã cho shop cụ thể nếu muốn
          if (widget.shopId != null) {
            data['shopId'] = widget.shopId;
          }
        }
      } else {
        // Seller: luôn gửi shopId, backend kiểm tra quyền sở hữu
        data['shopId'] = widget.shopId;
      }
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
    final String pageTitle;
    if (isEditing) {
      pageTitle = 'Sửa Mã Giảm Giá';
    } else if (widget.isAdmin) {
      pageTitle = 'Tạo Mã Toàn Sàn';
    } else {
      pageTitle = 'Tạo Mã Shop';
    }

    return BlocProvider.value(
      value: _bloc,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F5F5),
        appBar: AppBar(
          backgroundColor: widget.isAdmin
              ? AppColors.error.withOpacity(0.85)
              : AppColors.primaryBlue,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            pageTitle,
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
                backgroundColor: widget.isAdmin
                    ? AppColors.error.withOpacity(0.85)
                    : AppColors.primaryBlue,
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
                  // Banner hiển thị loại mã đang tạo
                  if (!isEditing)
                    Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      color: widget.isAdmin
                          ? Colors.red.shade50
                          : Colors.blue.shade50,
                      child: Row(
                        children: [
                          Icon(
                            widget.isAdmin ? Icons.public : Icons.storefront,
                            color: widget.isAdmin
                                ? Colors.red.shade700
                                : Colors.blue.shade700,
                            size: 20,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              widget.isAdmin
                                  ? 'Bạn đang tạo mã giảm giá áp dụng toàn sàn (PLATFORM)'
                                  : 'Bạn đang tạo mã giảm giá cho Shop của bạn',
                              style: TextStyle(
                                fontSize: 13,
                                color: widget.isAdmin
                                    ? Colors.red.shade700
                                    : Colors.blue.shade700,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

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
                    title: 'Phạm vi áp dụng',
                    children: [
                      // Scope: Admin có thể chọn PLATFORM/SHOP, Seller bị khóa ở SHOP
                      DropdownButtonFormField<String>(
                        initialValue: _scope,
                        decoration: const InputDecoration(
                          labelText: 'Phạm vi mã *',
                        ),
                        items: widget.isAdmin
                            ? const [
                                DropdownMenuItem(
                                  value: 'PLATFORM',
                                  child: Text('🌐  Toàn sàn (Platform)'),
                                ),
                                DropdownMenuItem(
                                  value: 'SHOP',
                                  child: Text('🏪  Shop cụ thể'),
                                ),
                              ]
                            : const [
                                DropdownMenuItem(
                                  value: 'SHOP',
                                  child: Text('🏪  Shop của tôi'),
                                ),
                              ],
                        onChanged: widget.isAdmin
                            ? (val) {
                                if (val != null) setState(() => _scope = val);
                              }
                            : null, // Seller không được đổi scope
                      ),
                      const SizedBox(height: 16),
                      // ApplyTo selector
                      DropdownButtonFormField<String>(
                        initialValue: _applyTo,
                        decoration: const InputDecoration(
                          labelText: 'Áp dụng cho *',
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: 'ALL',
                            child: Text('Tất cả sản phẩm'),
                          ),
                          DropdownMenuItem(
                            value: 'SPECIFIC',
                            child: Text('Sản phẩm/danh mục cụ thể'),
                          ),
                        ],
                        onChanged: (val) {
                          if (val != null) setState(() => _applyTo = val);
                        },
                      ),
                    ],
                  ),

                  _buildCardSection(
                    title: 'Thiết lập mã giảm giá',
                    children: [
                      DropdownButtonFormField<String>(
                        initialValue: _type,
                        decoration: const InputDecoration(
                          labelText: 'Loại giảm giá *',
                        ),
                        items: [
                          const DropdownMenuItem(
                            value: 'PERCENTAGE',
                            child: Text('Giảm theo phần trăm (%)'),
                          ),
                          const DropdownMenuItem(
                            value: 'FIXED_AMOUNT',
                            child: Text('Giảm số tiền cố định (đ)'),
                          ),
                          const DropdownMenuItem(
                            value: 'SHIPPING',
                            child: Text('Miễn phí vận chuyển'),
                          ),
                          if (widget.isAdmin)
                            const DropdownMenuItem(
                              value: 'COIN_CASHBACK',
                              child: Text('Hoàn xu (Coin Cashback)'),
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
                          helperText: _type == 'SHIPPING'
                              ? 'Nhập 100 = miễn phí ship, < 100 = giảm % ship'
                              : null,
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
                            labelText: 'Giảm tối đa',
                            suffixText: 'đ',
                            helperText: 'Số tiền giảm cao nhất. VD: Giảm 50% nhưng tối đa 100.000đ',
                            helperMaxLines: 2,
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
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _maxUsesController,
                              decoration: const InputDecoration(
                                labelText: 'Tổng số lượng mã',
                                helperText: 'Số lần mã có thể được dùng',
                              ),
                              keyboardType: TextInputType.number,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: _maxUsesPerUserController,
                              decoration: const InputDecoration(
                                labelText: 'Mỗi khách dùng tối đa',
                                helperText: 'Số lần mỗi khách được dùng',
                              ),
                              keyboardType: TextInputType.number,
                            ),
                          ),
                        ],
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
                        activeThumbColor: Theme.of(context).primaryColor,
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
