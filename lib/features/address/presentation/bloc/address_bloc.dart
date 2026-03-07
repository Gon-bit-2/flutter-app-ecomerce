import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/usecase/usecase.dart';
import '../../domain/usecases/create_address_usecase.dart';
import '../../domain/usecases/delete_address_usecase.dart';
import '../../domain/usecases/get_addresses_usecase.dart';
import '../../domain/usecases/set_default_address_usecase.dart';
import '../../domain/usecases/update_address_usecase.dart';
import 'address_event.dart';
import 'address_state.dart';

@injectable
class AddressBloc extends Bloc<AddressEvent, AddressState> {
  final GetAddressesUseCase getAddressesUseCase;
  final CreateAddressUseCase createAddressUseCase;
  final UpdateAddressUseCase updateAddressUseCase;
  final DeleteAddressUseCase deleteAddressUseCase;
  final SetDefaultAddressUseCase setDefaultAddressUseCase;

  AddressBloc({
    required this.getAddressesUseCase,
    required this.createAddressUseCase,
    required this.updateAddressUseCase,
    required this.deleteAddressUseCase,
    required this.setDefaultAddressUseCase,
  }) : super(AddressInitial()) {
    on<GetAddressesEvent>(_onGetAddresses);
    on<CreateAddressEvent>(_onCreateAddress);
    on<UpdateAddressEvent>(_onUpdateAddress);
    on<DeleteAddressEvent>(_onDeleteAddress);
    on<SetDefaultAddressEvent>(_onSetDefaultAddress);
  }

  Future<void> _onGetAddresses(
    GetAddressesEvent event,
    Emitter<AddressState> emit,
  ) async {
    emit(AddressLoading());
    final result = await getAddressesUseCase(NoParams());
    result.match(
      (failure) => emit(AddressError(message: failure.message)),
      (addresses) => emit(AddressesLoaded(addresses: addresses)),
    );
  }

  Future<void> _onCreateAddress(
    CreateAddressEvent event,
    Emitter<AddressState> emit,
  ) async {
    emit(AddressLoading());
    final result = await createAddressUseCase(
      CreateAddressParams(
        name: event.name,
        phone: event.phone,
        address: event.address,
        isDefault: event.isDefault,
      ),
    );
    result.match((failure) => emit(AddressError(message: failure.message)), (
      _,
    ) {
      emit(const AddressActionSuccess(message: 'Thêm địa chỉ thành công'));
      add(GetAddressesEvent()); // Reload list after create
    });
  }

  Future<void> _onUpdateAddress(
    UpdateAddressEvent event,
    Emitter<AddressState> emit,
  ) async {
    emit(AddressLoading());
    final result = await updateAddressUseCase(
      UpdateAddressParams(
        addressId: event.addressId,
        name: event.name,
        phone: event.phone,
        address: event.address,
        isDefault: event.isDefault,
      ),
    );
    result.match((failure) => emit(AddressError(message: failure.message)), (
      _,
    ) {
      emit(const AddressActionSuccess(message: 'Cập nhật địa chỉ thành công'));
      add(GetAddressesEvent()); // Reload list after update
    });
  }

  Future<void> _onDeleteAddress(
    DeleteAddressEvent event,
    Emitter<AddressState> emit,
  ) async {
    emit(AddressLoading());
    final result = await deleteAddressUseCase(
      DeleteAddressParams(addressId: event.addressId),
    );
    result.match((failure) => emit(AddressError(message: failure.message)), (
      _,
    ) {
      emit(const AddressActionSuccess(message: 'Xóa địa chỉ thành công'));
      add(GetAddressesEvent()); // Reload list after delete
    });
  }

  Future<void> _onSetDefaultAddress(
    SetDefaultAddressEvent event,
    Emitter<AddressState> emit,
  ) async {
    emit(AddressLoading());
    final result = await setDefaultAddressUseCase(
      SetDefaultAddressParams(addressId: event.addressId),
    );
    result.match((failure) => emit(AddressError(message: failure.message)), (
      _,
    ) {
      emit(const AddressActionSuccess(message: 'Đặt làm mặc định thành công'));
      add(GetAddressesEvent()); // Reload list
    });
  }
}
