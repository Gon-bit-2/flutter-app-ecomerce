import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../../domain/usecases/get_admin_discounts_usecase.dart';
import '../../../domain/usecases/create_discount_usecase.dart';
import '../../../domain/usecases/update_discount_usecase.dart';
import '../../../domain/usecases/delete_discount_usecase.dart';
import 'seller_discount_event.dart';
import 'seller_discount_state.dart';

@injectable
class SellerDiscountBloc
    extends Bloc<SellerDiscountEvent, SellerDiscountState> {
  final GetAdminDiscountsUseCase _getAdminDiscountsUseCase;
  final CreateDiscountUseCase _createDiscountUseCase;
  final UpdateDiscountUseCase _updateDiscountUseCase;
  final DeleteDiscountUseCase _deleteDiscountUseCase;

  SellerDiscountBloc(
    this._getAdminDiscountsUseCase,
    this._createDiscountUseCase,
    this._updateDiscountUseCase,
    this._deleteDiscountUseCase,
  ) : super(SellerDiscountInitial()) {
    on<FetchSellerDiscounts>(_onFetchSellerDiscounts);
    on<CreateNewDiscount>(_onCreateDiscount);
    on<UpdateExistingDiscount>(_onUpdateDiscount);
    on<DeleteExistingDiscount>(_onDeleteDiscount);
  }

  Future<void> _onFetchSellerDiscounts(
    FetchSellerDiscounts event,
    Emitter<SellerDiscountState> emit,
  ) async {
    emit(SellerDiscountLoading());
    final result = await _getAdminDiscountsUseCase(
      GetAdminDiscountsParams(
        page: event.page,
        limit: event.limit,
        shopId: event.shopId,
        type: event.type,
        scope: event.scope,
        isActive: event.isActive,
        search: event.search,
      ),
    );

    result.fold(
      (failure) => emit(SellerDiscountError(message: failure.message)),
      (discounts) => emit(SellerDiscountsLoaded(discounts: discounts)),
    );
  }

  Future<void> _onCreateDiscount(
    CreateNewDiscount event,
    Emitter<SellerDiscountState> emit,
  ) async {
    emit(SellerDiscountLoading());
    final result = await _createDiscountUseCase(
      CreateDiscountParams(data: event.data),
    );

    result.fold(
      (failure) => emit(SellerDiscountError(message: failure.message)),
      (_) => emit(
        const SellerDiscountOperationSuccess(message: 'Tạo mã thành công'),
      ),
    );
  }

  Future<void> _onUpdateDiscount(
    UpdateExistingDiscount event,
    Emitter<SellerDiscountState> emit,
  ) async {
    emit(SellerDiscountLoading());
    final result = await _updateDiscountUseCase(
      UpdateDiscountParams(discountId: event.discountId, data: event.data),
    );

    result.fold(
      (failure) => emit(SellerDiscountError(message: failure.message)),
      (_) => emit(
        const SellerDiscountOperationSuccess(message: 'Cập nhật mã thành công'),
      ),
    );
  }

  Future<void> _onDeleteDiscount(
    DeleteExistingDiscount event,
    Emitter<SellerDiscountState> emit,
  ) async {
    emit(SellerDiscountLoading());
    final result = await _deleteDiscountUseCase(
      DeleteDiscountParams(discountId: event.discountId),
    );

    result.fold(
      (failure) => emit(SellerDiscountError(message: failure.message)),
      (_) => emit(
        const SellerDiscountOperationSuccess(message: 'Xoá mã thành công'),
      ),
    );
  }
}
