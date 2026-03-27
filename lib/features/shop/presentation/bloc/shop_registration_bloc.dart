import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../domain/repositories/shop_repository.dart';
import 'shop_registration_event.dart';
import 'shop_registration_state.dart';

@injectable
class ShopRegistrationBloc extends Bloc<ShopRegistrationEvent, ShopRegistrationState> {
  final ShopRepository repository;

  ShopRegistrationBloc(this.repository) : super(ShopRegistrationInitial()) {
    on<CheckShopStatus>((event, emit) async {
      emit(ShopStatusLoading());

      final result = await repository.getMyShop();

      result.fold(
        (failure) {
          // If the API returns a failure, it might be due to 404 Not Found (no shop),
          // or a real error. Often backends return 404 or just null data if no shop exists.
          // Assuming the repository returns a Failure with message, we can emit failure 
          // or treat as null if message implies not found. For safety, emit failure.
          emit(ShopStatusCheckFailure(message: failure.message));
        },
        (shop) => emit(ShopStatusLoaded(shop: shop)),
      );
    });

    on<RegisterShopSubmitted>((event, emit) async {
      emit(ShopRegistrationLoading());

      final result = await repository.registerShop(
        name: event.name,
        description: event.description,
        phoneNumber: event.phoneNumber,
        address: event.address,
        email: event.email,
      );

      result.fold(
        (failure) => emit(ShopRegistrationFailure(message: failure.message)),
        (_) => emit(ShopRegistrationSuccess()),
      );
    });
  }
}
