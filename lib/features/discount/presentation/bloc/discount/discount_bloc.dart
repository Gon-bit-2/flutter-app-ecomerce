import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/usecases/get_my_vouchers.dart';
import '../../../domain/usecases/get_available_discounts.dart';
import '../../../domain/usecases/preview_discount.dart';
import '../../../domain/usecases/save_discount.dart';
import 'discount_event.dart';
import 'discount_state.dart';
import 'package:injectable/injectable.dart';

@injectable
class DiscountBloc extends Bloc<DiscountEvent, DiscountState> {
  final GetMyVouchers getMyVouchers;
  final GetAvailableDiscounts getAvailableDiscounts;
  final PreviewDiscount previewDiscount;
  final SaveDiscount saveDiscount;

  DiscountBloc({
    required this.getMyVouchers,
    required this.getAvailableDiscounts,
    required this.previewDiscount,
    required this.saveDiscount,
  }) : super(DiscountInitial()) {
    on<FetchMyVouchers>(_onFetchMyVouchers);
    on<FetchAvailableDiscounts>(_onFetchAvailableDiscounts);
    on<DoPreviewDiscount>(_onDoPreviewDiscount);
    on<SaveVoucherRequested>(_onSaveVoucherRequested);
  }

  Future<void> _onFetchMyVouchers(
    FetchMyVouchers event,
    Emitter<DiscountState> emit,
  ) async {
    emit(DiscountLoading());
    final failureOrVouchers = await getMyVouchers.call(
      page: event.page,
      limit: event.limit,
    );
    failureOrVouchers.fold(
      (failure) => emit(DiscountError(message: failure.message)),
      (vouchers) => emit(MyVouchersLoaded(vouchers: vouchers)),
    );
  }

  Future<void> _onFetchAvailableDiscounts(
    FetchAvailableDiscounts event,
    Emitter<DiscountState> emit,
  ) async {
    emit(DiscountLoading());
    final failureOrVouchers = await getAvailableDiscounts.call(
      page: event.page,
      limit: event.limit,
    );
    failureOrVouchers.fold(
      (failure) => emit(DiscountError(message: failure.message)),
      (vouchers) => emit(AvailableDiscountsLoaded(vouchers: vouchers)),
    );
  }

  Future<void> _onDoPreviewDiscount(
    DoPreviewDiscount event,
    Emitter<DiscountState> emit,
  ) async {
    emit(DiscountPreviewLoading());
    final failureOrResult = await previewDiscount.call(
      code: event.code,
      orderValue: event.orderValue,
      shippingFee: event.shippingFee,
      userId: event.userId,
      shopId: event.shopId,
      items: event.items,
    );
    failureOrResult.fold(
      (failure) => emit(DiscountError(message: failure.message)),
      (previewData) => emit(DiscountPreviewLoaded(previewData: previewData)),
    );
  }

  Future<void> _onSaveVoucherRequested(
    SaveVoucherRequested event,
    Emitter<DiscountState> emit,
  ) async {
    emit(SaveVoucherLoading());
    final failureOrSuccess = await saveDiscount.call(event.discountId);
    
    failureOrSuccess.fold(
      (failure) => emit(DiscountError(message: failure.message)),
      (_) {
        emit(SaveVoucherSuccess(discountId: event.discountId));
        // Mặc định sau khi lưu thành công, tải lại danh sách voucher của tôi
        add(const FetchMyVouchers());
      },
    );
  }
}
