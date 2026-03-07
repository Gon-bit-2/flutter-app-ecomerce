import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/address_bloc.dart';
import '../bloc/address_event.dart';
import '../bloc/address_state.dart';

class AddressListPage extends StatefulWidget {
  const AddressListPage({super.key});

  @override
  State<AddressListPage> createState() => _AddressListPageState();
}

class _AddressListPageState extends State<AddressListPage> {
  @override
  void initState() {
    super.initState();
    context.read<AddressBloc>().add(GetAddressesEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý địa chỉ'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              // TODO: Navigate to AddressFormPage
            },
          ),
        ],
      ),
      body: BlocConsumer<AddressBloc, AddressState>(
        listener: (context, state) {
          if (state is AddressActionSuccess) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
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
          if (state is AddressLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is AddressesLoaded) {
            final addresses = state.addresses;
            if (addresses.isEmpty) {
              return const Center(child: Text('Chưa có địa chỉ nào'));
            }
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: addresses.length,
              itemBuilder: (context, index) {
                final address = addresses[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          address.name,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        if (address.isDefault)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(
                                0xFF1A94FF,
                              ).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                color: const Color(0xFF1A94FF),
                              ),
                            ),
                            child: const Text(
                              'Mặc định',
                              style: TextStyle(
                                color: Color(0xFF1A94FF),
                                fontSize: 12,
                              ),
                            ),
                          ),
                      ],
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 8),
                        Text(address.phone),
                        const SizedBox(height: 4),
                        Text(address.address),
                      ],
                    ),
                    trailing: PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == 'edit') {
                          // TODO: Navigate to AddressFormPage
                        } else if (value == 'delete') {
                          context.read<AddressBloc>().add(
                            DeleteAddressEvent(
                              addressId: address.id.toString(),
                            ),
                          );
                        } else if (value == 'set_default') {
                          context.read<AddressBloc>().add(
                            SetDefaultAddressEvent(
                              addressId: address.id.toString(),
                            ),
                          );
                        }
                      },
                      itemBuilder: (context) => [
                        if (!address.isDefault)
                          const PopupMenuItem(
                            value: 'set_default',
                            child: Text('Đặt làm mặc định'),
                          ),
                        const PopupMenuItem(value: 'edit', child: Text('Sửa')),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Text(
                            'Xóa',
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}
