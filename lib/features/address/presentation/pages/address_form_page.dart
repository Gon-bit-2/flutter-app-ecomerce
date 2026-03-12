import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/address_entity.dart';
import '../bloc/address_bloc.dart';
import '../bloc/address_event.dart';
import '../bloc/address_state.dart';

class AddressFormPage extends StatefulWidget {
  final AddressEntity? address;

  const AddressFormPage({super.key, this.address});

  @override
  State<AddressFormPage> createState() => _AddressFormPageState();
}

class _AddressFormPageState extends State<AddressFormPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  late TextEditingController _cityController;
  late TextEditingController _districtController;
  late TextEditingController _wardController;
  bool _isDefault = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.address?.name ?? '');
    _phoneController = TextEditingController(text: widget.address?.phone ?? '');

    // Parse address if it has commas
    String street = widget.address?.address ?? '';
    String ward = '';
    String district = '';
    String city = '';

    if (street.isNotEmpty && street.contains(',')) {
      List<String> parts = street.split(',').map((e) => e.trim()).toList();
      if (parts.length >= 4) {
        city = parts.last;
        district = parts[parts.length - 2];
        ward = parts[parts.length - 3];
        parts.removeRange(parts.length - 3, parts.length);
        street = parts.join(', ');
      }
    }

    _addressController = TextEditingController(text: street);
    _cityController = TextEditingController(text: city);
    _districtController = TextEditingController(text: district);
    _wardController = TextEditingController(text: ward);
    _isDefault = widget.address?.isDefault ?? false;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _districtController.dispose();
    _wardController.dispose();
    super.dispose();
  }

  void _submitData() {
    if (_formKey.currentState!.validate()) {
      // Merge address
      final fullAddress =
          '${_addressController.text.trim()}, '
          '${_wardController.text.trim()}, '
          '${_districtController.text.trim()}, '
          '${_cityController.text.trim()}';

      if (widget.address == null) {
        context.read<AddressBloc>().add(
          CreateAddressEvent(
            name: _nameController.text.trim(),
            phone: _phoneController.text.trim(),
            address: fullAddress,
            isDefault: _isDefault ? true : null,
          ),
        );
      } else {
        context.read<AddressBloc>().add(
          UpdateAddressEvent(
            addressId: widget.address!.id.toString(),
            name: _nameController.text.trim(),
            phone: _phoneController.text.trim(),
            address: fullAddress,
            isDefault: _isDefault ? true : null,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.address == null ? 'Thêm địa chỉ mới' : 'Cập nhật địa chỉ',
        ),
      ),
      body: BlocConsumer<AddressBloc, AddressState>(
        listener: (context, state) {
          if (state is AddressActionSuccess) {
            Navigator.pop(context);
          } else if (state is AddressError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is AddressLoading;

          return Form(
            key: _formKey,
            child: Column(
              children: [
                Expanded(
                  child: ListView(
                    children: [
                      Container(
                        color: Colors.white,
                        padding: const EdgeInsets.only(left: 16),
                        margin: const EdgeInsets.only(bottom: 8),
                        child: Column(
                          children: [
                            _buildTextField(
                              controller: _nameController,
                              label: 'Họ và tên',
                              isLoading: isLoading,
                              validator: (value) =>
                                  value == null || value.isEmpty
                                  ? 'Vui lòng nhập họ và tên'
                                  : null,
                            ),
                            const Divider(height: 1, color: Color(0xFFEEEEEE)),
                            _buildTextField(
                              controller: _phoneController,
                              label: 'Số điện thoại',
                              keyboardType: TextInputType.phone,
                              isLoading: isLoading,
                              validator: (value) =>
                                  value == null || value.isEmpty
                                  ? 'Vui lòng nhập số điện thoại'
                                  : null,
                            ),
                          ],
                        ),
                      ),
                      Container(
                        color: Colors.white,
                        padding: const EdgeInsets.only(left: 16),
                        margin: const EdgeInsets.only(bottom: 8),
                        child: Column(
                          children: [
                            _buildTextField(
                              controller: _cityController,
                              label: 'Tỉnh/Thành phố',
                              isLoading: isLoading,
                              validator: (value) =>
                                  value == null || value.isEmpty
                                  ? 'Vui lòng nhập Tỉnh/Thành phố'
                                  : null,
                            ),
                            const Divider(height: 1, color: Color(0xFFEEEEEE)),
                            _buildTextField(
                              controller: _districtController,
                              label: 'Quận/Huyện',
                              isLoading: isLoading,
                              validator: (value) =>
                                  value == null || value.isEmpty
                                  ? 'Vui lòng nhập Quận/Huyện'
                                  : null,
                            ),
                            const Divider(height: 1, color: Color(0xFFEEEEEE)),
                            _buildTextField(
                              controller: _wardController,
                              label: 'Phường/Xã',
                              isLoading: isLoading,
                              validator: (value) =>
                                  value == null || value.isEmpty
                                  ? 'Vui lòng nhập Phường/Xã'
                                  : null,
                            ),
                            const Divider(height: 1, color: Color(0xFFEEEEEE)),
                            _buildTextField(
                              controller: _addressController,
                              label: 'Tên đường, Tòa nhà, Số nhà',
                              isLoading: isLoading,
                              maxLines: 2,
                              validator: (value) =>
                                  value == null || value.isEmpty
                                  ? 'Vui lòng nhập Tên đường, Tòa nhà, Số nhà'
                                  : null,
                            ),
                          ],
                        ),
                      ),
                      if (widget.address?.isDefault != true)
                        Container(
                          color: Colors.white,
                          child: SwitchListTile(
                            title: const Text(
                              'Đặt làm địa chỉ mặc định',
                              style: TextStyle(fontSize: 14),
                            ),
                            activeThumbColor: const Color(
                              0xFFEE4D2D,
                            ), // Shopee orange
                            value: _isDefault,
                            onChanged: isLoading
                                ? null
                                : (value) {
                                    setState(() {
                                      _isDefault = value;
                                    });
                                  },
                          ),
                        ),
                    ],
                  ),
                ),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    border: Border(top: BorderSide(color: Color(0xFFEEEEEE))),
                  ),
                  child: ElevatedButton(
                    onPressed: isLoading ? null : _submitData,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFEE4D2D), // Shopee orange
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    child: isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            'HOÀN THÀNH',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required bool isLoading,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.grey.shade600, fontSize: 14),
        border: InputBorder.none,
        contentPadding: const EdgeInsets.symmetric(
          vertical: 12,
          horizontal: 16,
        ).copyWith(left: 0),
      ),
      validator: validator,
      enabled: !isLoading,
    );
  }
}
