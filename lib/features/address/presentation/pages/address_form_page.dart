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
  bool _isDefault = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.address?.name ?? '');
    _phoneController = TextEditingController(text: widget.address?.phone ?? '');
    _addressController = TextEditingController(
      text: widget.address?.address ?? '',
    );
    _isDefault = widget.address?.isDefault ?? false;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _submitData() {
    if (_formKey.currentState!.validate()) {
      if (widget.address == null) {
        context.read<AddressBloc>().add(
          CreateAddressEvent(
            name: _nameController.text.trim(),
            phone: _phoneController.text.trim(),
            address: _addressController.text.trim(),
            isDefault: _isDefault ? true : null,
          ),
        );
      } else {
        context.read<AddressBloc>().add(
          UpdateAddressEvent(
            addressId: widget.address!.id.toString(),
            name: _nameController.text.trim(),
            phone: _phoneController.text.trim(),
            address: _addressController.text.trim(),
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
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Họ và tên',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => value == null || value.isEmpty
                      ? 'Vui lòng nhập họ và tên'
                      : null,
                  enabled: !isLoading,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'Số điện thoại',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => value == null || value.isEmpty
                      ? 'Vui lòng nhập số điện thoại'
                      : null,
                  enabled: !isLoading,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _addressController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Địa chỉ cụ thể',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => value == null || value.isEmpty
                      ? 'Vui lòng nhập địa chỉ cụ thể'
                      : null,
                  enabled: !isLoading,
                ),
                const SizedBox(height: 16),
                if (widget.address?.isDefault !=
                    true) // Không cho huỷ mặc định trực tiếp ở đây (chỉ set qua API default)
                  SwitchListTile(
                    title: const Text('Đặt làm địa chỉ mặc định'),
                    value: _isDefault,
                    onChanged: isLoading
                        ? null
                        : (value) {
                            setState(() {
                              _isDefault = value;
                            });
                          },
                  ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: isLoading ? null : _submitData,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
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
                          'Lưu thông tin',
                          style: TextStyle(fontSize: 16),
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
